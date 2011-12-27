var Util    = require('util');
var FS      = require('fs');
var Process = require('child_process');
var Main    = this;

var RPC = {
  /* fs functions */
  fs: {
    open: FS.openSync,
    read: function(fd,position,length) {
      var buffer = new Buffer();

      FS.readSync(fd,buffer,length);
      return buffer;
    },
    write: function(fd,position,data) {
      var buffer = new Buffer(data);

      return FS.writeSync(fd,buffer,0,buffer.length,position);
    },
    close:  FS.closeSync,

    readdir: function(path) {
      var entries = FS.readdirSync();

      entries.unshift('.','..');
      return entries;
    },

    move:    FS.renameSync,
    unlink:  FS.unlinkSync,
    rmdir:   FS.rmdirSync,
    mkdir:   FS.mkdirSync,
    chmod:   FS.chmodSync,
    stat:    FS.statSync,
    link:    FS.symlinkSync
  },

  /* process functions */
  process: {
    getpid: function() { return process.pid; },
    getcwd: process.cwd,
    chdir:  process.chdir,
    getuid: process.getuid,
    setuid: process.setuid,
    getgid: process.getgid,
    setgid: process.setgid,
    getenv: function(name)       { return process.env[name];         },
    setenv: function(name,value) { return process.env[name] = value; },
    unsetenv: function(name) {
      var value = process.env[name];

      delete process.env[name];
      return value
    },
    time: function() { return new Date().getTime(); },
    kill: process.kill,
    exit: process.exit
  },

  /* shell functions */
  shell: {
    _commands: {},
    _command: function(pid) {
      var process = RPC.shell._commands[pid];

      if (process == undefined) {
        throw("unknown command PID: " + pid);
      }

      return process;
    },

    exec: function() {
      process = Process.exec(arguments.join(' '));

      RPC.shell._commands[process.pid] = process;
      return process.pid;
    },
    read: function(pid,length) {
      var process = RPC.shell._command(pid);

      process.stdin.resume();
    },
    write: function(pid,data) {
      var process = RPC.shell._command(pid);

      process.stdout.write(data);
      return data.length;
    },
    close: function(pid) {
      var process = RPC.shell._command(pid);

      process.destroy();
      delete RPC.shell._commands[pid];
      return true;
    }
  },

  js: {
    eval:   function(code) { return eval(code); },
    define: function(name,args,code) {
      RPC.js[name] = eval("(function(" + args.join(',') + ") { " + code + "})");
      return true;
    }
  }
};

RPC.lookup = function(names) {
  var scope = RPC;
  var index;

  for (index=0; index<names.length; index++) {
    scope = scope[names[index]];

    if (scope == undefined) { return; }
  }

  return scope;
}

RPC.Transport = function() {}
RPC.Transport.prototype.start    = function() {}
RPC.Transport.prototype.stop     = function() {}
RPC.Transport.prototype.lookup   = function(name) { return RPC.lookup([name]); }
RPC.Transport.prototype.call     = function(name,args) {
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

RPC.Transport.prototype.serialize = function(data) {
  return new Buffer(JSON.stringify(data)).toString('base64');
}

RPC.Transport.prototype.deserialize = function(data) {
  return JSON.parse(new Buffer(data,'base64'));
}

var HTTP = require('http');
var URL  = require('url');

RPC.HTTP = function(port,host) {
  this.port = port;
  this.host = (host ? host : '0.0.0.0');
}

RPC.HTTP.start = function(port,host) {
  var server = new RPC.HTTP(port,host);

  server.start();
}

RPC.HTTP.prototype = new RPC.Transport();

RPC.HTTP.prototype.lookup = function(path) {
  return RPC.lookup(path.slice(1,path.length).split('/'));
}

RPC.HTTP.prototype.start = function() {
  var self = this;

  this.server = HTTP.createServer(function(request,response) {
    var url  = URL.parse(request.url);
    var name = url.pathname;
    var args = (url.query ? self.deserialize(url.query) : []);

    response.write(self.serialize(self.call(name,args)));
    response.end();
  });

  this.server.listen(this.port,this.host, function() {
    console.log("Listening on " + self.host + ":" + self.port);
  });
}

RPC.HTTP.prototype.stop = function() { this.server.close(); }

if (process.argv.length < 3) {
  console.log("usage: PORT [HOST]");
  process.exit(-1);
}

RPC.HTTP.start(process.argv[2],process.argv[3]);
