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

      FS.readSync(fd,buffer,0,length,position);
      return buffer;
    },
    write: function(fd,position,data) {
      var buffer = new Buffer(data);

      return FS.writeSync(fd,buffer,0,buffer.length,position);
    },
    close:  FS.closeSync,

    readlink: FS.readlinkSync,
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

RPC.lookup = function(name) {
  var names = name.split('.');
  var scope = RPC;
  var index;

  for (index=0; index<names.length; index++) {
    scope = scope[names[index]];

    if (scope == undefined) { return; }
  }

  return scope;
}

RPC.call = function(name,args) {
  var func = RPC.lookup(name);

  if (func == undefined) {
    return {'exception': "unknown function: " + name};
  }

  try {
    return {'return': func.apply(this,args)};
  } catch(error) {
    return {'exception': error.toString()};
  }
}

RPC.Transport = function() {}
RPC.Transport.prototype.start    = function() {}
RPC.Transport.prototype.stop     = function() {}

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
  this.port = parseInt(port);
  this.host = (host ? host : '0.0.0.0');
}

RPC.HTTP.start       = function(port,host) {
  var server = new RPC.HTTP(port,host);

  server.start(function() {
    console.log("[HTTP] Listening on " + server.host + ":" + server.port);
  });
}

RPC.HTTP.prototype = new RPC.Transport();

RPC.HTTP.prototype.start = function(callback) {
  var self = this;

  this.server = HTTP.createServer(function(request,response) {
    self.serve(request,response);
  });

  this.server.listen(this.port,this.host,callback);
}

RPC.HTTP.prototype.decode_request = function(request,callback) {
  var url  = URL.parse(request.url);
  var name = url.pathname.slice(1,url.pathname.length).split('/').join('.');
  var args = (url.query ? this.deserialize(url.query) : []);

  callback(name,args);
}

RPC.HTTP.prototype.encode_response = function(response,message) {
  response.write(this.serialize(message));
  response.end();
}

RPC.HTTP.prototype.serve = function(request,response) {
  var self = this;

  self.decode_request(request,function(name,args) {
    self.encode_response(response,RPC.call(name,args));
  });
}

RPC.HTTP.prototype.stop = function() { this.server.close(); }

var Net = require('net');

RPC.TCP = {
  decode_request: function(request,callback) {
    var message = this.deserialize(request);

    callback(message['name'],message['arguments']);
  },

  encode_response: function(socket,message) {
    socket.write(this.serialize(message));
  },

  serve: function(socket) {
    var self = this;
    var buffer = '';

    socket.on('data',function(stream) {
      var data        = stream.toString();
      var deliminator = data.lastIndexOf('=');

      if (deliminator) {
        buffer += data.substr(0,deliminator);

        self.decode_request(buffer,function(name,args) {
          self.encode_response(socket,RPC.call(name,args));
        });

        buffer = data.substr(deliminator,data.length);
      }
      else { buffer.write(data); }
    });
  }
};

RPC.TCP.Server = function(port,host) {
  this.port = parseInt(port);
  this.host = (host ? host : '0.0.0.0');
}

RPC.TCP.Server.start = function(port,host) {
  var server = new RPC.TCP.Server(port,host);

  server.start(function() {
    console.log("[TCP] Listening on " + server.host + ":" + server.port);
  });
}

RPC.TCP.Server.prototype   = new RPC.Transport();
RPC.TCP.Server.prototype.decode_request  = RPC.TCP.decode_request;
RPC.TCP.Server.prototype.encode_response = RPC.TCP.encode_response;
RPC.TCP.Server.prototype.serve           = RPC.TCP.serve;

RPC.TCP.Server.prototype.start = function(callback) {
  var self = this;

  this.server = Net.createServer(function(client) {
    self.serve(client);
  });

  this.server.listen(this.port,this.host,callback);
}

RPC.TCP.Server.prototype.stop = function() { this.server.stop(); }

RPC.TCP.ConnectBack = function(host,port) {
  this.host = host;
  this.port = parseInt(port);
}

RPC.TCP.ConnectBack.start = function(host,port) {
  var client = new RPC.TCP.ConnectBack(host,port);

  client.start(function() {
    console.log("[TCP] Connected to " + client.host + ":" + client.port);
  });
}

RPC.TCP.ConnectBack.prototype = new RPC.Transport();
RPC.TCP.ConnectBack.prototype.decode_request  = RPC.TCP.decode_request;
RPC.TCP.ConnectBack.prototype.encode_response = RPC.TCP.encode_response;
RPC.TCP.ConnectBack.prototype.serve           = RPC.TCP.serve;

RPC.TCP.ConnectBack.prototype.start = function(callback) {
  this.connection = Net.createConnection(this.port,this.host,callback);

  this.serve(this.connection);
}

RPC.TCP.ConnectBack.prototype.stop = function() { this.connection.end(); }

function usage() {
  console.log("usage: [--http PORT [HOST]] [--listen PORT [HOST]] [--connect HOST PORT]");
  process.exit(-1);
}

if (process.argv.length < 4) { usage(); }

var option = process.argv[2];
var args   = process.argv.slice(3,process.argv.length);

if      (option == '--http')    { RPC.HTTP.start(args[0],args[1]); }
else if (option == '--listen')  { RPC.TCP.Server.start(args[0],args[1]); }
else if (option == '--connect') { RPC.TCP.ConnectBack.start(args[0],args[1]); }
else { usage(); }
