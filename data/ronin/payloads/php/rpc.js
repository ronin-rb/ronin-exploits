var PHP_RPC = {
  requestMethod: "GET",

  serverURL: window.location.href,

  cwd: null,
  env: {},

  encodeRequest: function(request) {
    return window.atob($.toJSON(request));
  },

  decodeResponse: function(body) {
    var extractor = new RegExp("<rpc-response>([^<]+)<\/rpc-response>");
    var match     = body.match(extractor);

    if (match == null || match[1] == null) {
      throw "PHP-RPC Response missing";
    }

    var response = $.parseJSON(window.btoa(match[1]));

    if (response == null) {
      throw "Invalid PHP-RPC Response";
    }

    if (response.exception) { throw response.exception; }
    else                    { return response.value;    }
  },

  call: function(method,args,callback) {
    var request = {
      'method':    method,
      'arguments': (args || [])
    };

    if (PHP_RPC.cwd)        { request['cwd'] = PHP_RPC.cwd; }
    if (PHP_RPC.env.length) { request['env'] = PHP_RPC.env; }

    var value = null;

    $.ajax({
      type: PHP_RPC.requestMethod,
      data: {rpc_request: encodeRequest(request)},

      success: function(data) {
        value = decodeResponse(data);
        if (callback) { callback(value); }
      },

      error:   function(xhr,type) {
        throw "PHP-RPC Request failed to complete: " + type;
      }
    });

    return value;
  },

  FS: {
    files:   [],

    open: function(path,mode) {
      // TODO: parse mode
      files.push({path: path, pos: 0, buffer: ''});
      return files.length - 1;
    },

    read: function(fd,length) {
      var file = PHP_RPC.FS.files[fd];

      if (file == null) { throw "Invalid file-descriptor"; }

      while (file.buffer.length < length) {
        var chunk = PHP_RPC.call('fs_read',file.path,file.pos);

        if (chunk.length == 0) { break; }

        file.pos    += chunk.length;
        file.buffer += chunk;
      }

      var data = file.buffer.slice(0,length);

      file.buffer = file.buffer.slice(length,file.buffer.length);
      return data;
    }

    write: function(fd,data) {
      var file   = PHP_RPC.FS.files[fd];

      if (file == null) { throw "Invalid file-descriptor"; }

      var length = PHP_RPC.call('fs_write',file.path,file.pos,data);

      file.pos += length;
      return length;
    },

    close: function(fd) {
      if (fds[fd] == null) {
        return false;
      }

      fds[fd] = null;
      return true;
    },

    stat: function(path) { return PHP_RPC.call('fs_stat',arguments); },
    getcwd: function()   {
      return (PHP_RPC.cwd = PHP_RPC.call('fs_getcwd'));
    },
    chdir: function(path) {
      return (PHP_RPC.cwd = PHP_RPC.call('fs_chdir',arguments));
    },
    glob: function(pattern) { return PHP_RPC.call('fs_glob',arguments); },
    mktemp: function(name)  { return PHP_RPC.call('fs_mktemp',arguments); },
    mkdir: function(path) { return PHP_RPC.call('fs_mkdir',arguments); },
    copy: function(src,dest) { return PHP_RPC.call('fs_copy',arguments); },
    unlink: function(path) { return PHP_RPC.call('fs_unlink',arguments); },
    rmdir: function(path) { return PHP_RPC.call('fs_rmdir',arguments); },
    move: function(src,dest) { return PHP_RPC.call('fs_move',arguments); },
    link: function(src,dest) { return PHP_RPC.call('fs_link',arguments); },
    chown: function(user,paths) { return PHP_RPC.call('fs_chown',arguments); },
    chgrp: function(group,paths) { return PHP_RPC.call('fs_chgrp',arguments); },
    chmod: function(perms,paths) { return PHP_RPC.call('fs_chmod',arguments); }
  },

  Process: {
    getpid: function() { return PHP_RPC.call('process_getpid'); },
    getppid: function() { return PHP_RPC.call('process_getpid'); },
    getuid: function() { return PHP_RPC.call('process_getuid'); },
    setuid: function(uid) { return PHP_RPC.call('process_setuid',arguments); },
    geteuid: function() { return PHP_RPC.call('process_geteuid',arguments); },
    seteuid: function(euid) { return PHP_RPC.call('process_seteuid',arguments); },
    getgid: function() { return PHP_RPC.call('process_getgid',arguments); },
    setgid: function(gid) { return PHP_RPC.call('process_setgid',arguments); },
    getegid: function() { return PHP_RPC.call('process_getegid',arguments); },
    setegid: function(egid) { return PHP_RPC.call('process_setegid',arguments); },
    getsid: function() { return PHP_RPC.call('process_getsid',arguments); },
    setsid: function() { return PHP_RPC.call('process_setsid',arguments); },

    spawn: function(program,args) {
      return PHP_RPC.call('process_spawn',arguments);
    },
    kill: function(pid,signal) {
      return PHP_RPC.call('process_kill',arguments);
    },

    getcwd: function() {
      return (PHP_RPC.cwd = PHP_RPC.call('process_getcwd'));
    },
    chdir: function(path) {
      return (PHP_RPC.cwd = PHP_RPC.call('process_chdir',arguments));
    },

    // TODO: convert unix timestamp to Date object
    time: function() { return PHP_RPC.call('process_time'); }
  },

  Shell: {
    exec: function(program,args) {
      var result = PHP_RPC.call('shell_exec',arguments);

      if (result.env) { PHP_RPC.env = $.extend(result.env,PHP_RPC.env); }

      return result.output;
    }
  }
};
