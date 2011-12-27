var Util = require('util');
var FS   = require('fs');
var Process = require('child_process');

var RPC = {
  /* fs functions */
  fs_open: FS.openSync,
  fs_read: function(fd,position,length) {
    var buffer = new Buffer();

    FS.readSync(fd,buffer,length);
    return buffer;
  },
  fs_write: function(fd,position,data) {
    var buffer = new Buffer(data);

    return FS.writeSync(fd,buffer,0,buffer.length,position);
  },
  fs_close:  FS.closeSync,
  fs_move:   FS.renameSync,
  fs_unlink: FS.unlinkSync,
  fs_rmdir:  FS.rmdirSync,
  fs_mkdir:  FS.mkdirSync,
  fs_chmod:  FS.chmodSync,
  fs_stat:   FS.statSync,
  fs_link:   FS.symlinkSync,

  /* process functions */
  process_getpid:    function() { return process.pid; },
  process_getcwd: process.cwd,
  process_chdir:  process.chdir,
  process_getuid: process.getuid,
  process_setuid: process.setuid,
  process_getgid: process.getgid,
  process_setgid: process.setgid,
  process_getenv: function(name) { return process.env[name]; },
  process_setenv: function(name,value) {
    return process.env[name] = value;
  },
  process_unsetenv: function(name) {
    var value = process.env[name];

    delete process.env[name];
    return value
  },
  process_time: function() { return new Date().getTime(); },
  process_kill: process.kill,
  process_exit: process.exit,

  Shell: {
    commands: {},

    command: function(pid) {
      var process = RPC.Shell.commands[pid];

      if (process == undefined) {
        throw("unknown command PID: " + pid);
      }

      return process;
    }
  },

  shell_exec: function() {
    process = Process.exec(arguments.join(' '));

    RPC.Shell.commands[process.pid] = process;
    return process.pid;
  },
  shell_read: function(pid,length) {
    var process = RPC.Shell.command(pid);

    process.stdin.resume();
  },
  shell_write: function(pid,data) {
    var process = RPC.Shell.command(pid);

    process.stdout.write(data);
    return data.length;
  },
  shell_close: function(pid) {
    var process = RPC.Shell.command(pid);

    process.destroy();
    delete RPC.Shell.commands[pid];
    return true;
  }
};

RPC.Transport = function() {}
RPC.Transport.prototype.start = function() {}
RPC.Transport.prototype.stop = function() {}

RPC.Transport.prototype.lookup = function(name) {
  return RPC[name];
}

RPC.Transport.prototype.dispatch = function(name,args) {
  var func = this.lookup(name);

  if (func == undefined) {
    return this.error_message("unknown function: " + name);
  }

  try {
    return this.return_message(func.apply(this,args));
  } catch(error) {
    return this.error_message(error.toString());
  }
}

RPC.Transport.prototype.return_message = function(data) {
  return {'return': data};
}

RPC.Transport.prototype.error_message = function(message) {
  return {'exception': message};
}

/*
 * The default data serialization function.
 */
RPC.Transport.prototype.serialize = function(data) {
  return new Buffer(JSON.stringify(data)).toString('base64');
}

/*
 * The default data deserialization function.
 */
RPC.Transport.prototype.deserialize = function(data) {
  return JSON.parse(new Buffer(data,'base64'));
}

var HTTP = require('http');
var URL  = require('url');

RPC.HTTP = function(port,host) {
  this.port = port;
  this.host = (host ? host : '0.0.0.0');
}

RPC.HTTP.prototype = new RPC.Transport();

RPC.HTTP.prototype.start = function(callback) {
  var self = this;

  this.server = HTTP.createServer(function(request,response) {
    var url  = URL.parse(request.url);
    var name = url.pathname.slice(1,request.url.length).replace('/','_');
    var args = (url.query ? self.deserialize(url.query) : []);

    response.write(self.serialize(self.dispatch(name,args)));
    response.end();
  });

  this.server.listen(this.port,this.host, function() {
    console.log("Listening on " + self.host + ":" + self.port);
  });
}

RPC.HTTP.prototype.stop = function() {
  this.server.close();
}

var rpc = new RPC.HTTP(process.argv[2],process.argv[3]);

rpc.start();
