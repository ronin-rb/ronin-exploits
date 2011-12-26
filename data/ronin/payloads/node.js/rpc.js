var Transports = {};

/*
 * Creates a new Transport.
 */
Transport = function() {}

/*
 * Starts the Transport and begins receiving Requests.
 *
 * callback - The function that will be passed the received Requests.
 */
Transport.prototype.start = function(callback) {}

/*
 * Stops the Transport
 */
Transport.prototype.stop = function() {}

/*
 * The default data serialization function.
 */
Transport.prototype.serialize = function(data) {
  return new Buffer(JSON.stringify(data)).toString('base64');
}

/*
 * The default data deserialization function.
 */
Transport.prototype.deserialize = function(data) {
  return JSON.parse(new Buffer(data,'base64'));
}

/*
 * Sends data to the session.
 *
 * session - Abstract session belonging to the Transport.
 * data - The data to send.
 */
Transport.prototype.send = function(session,data) {
  session.write(this.serialize(data));
}

/*
 * transport - The transport that received the request.
 * session - Abstract session object.
 * name - Name of the function to call.
 * args - Additional arguments for the function.
 */
Request = function(transport,session,name,args) {
  this.transport = transport;
  this.session   = session;

  this.name = name;
  this.args = args;
}

/*
 * Returns a callback used to yield data to the caller.
 */
Request.prototype.callback = function() {
  var self = this;

  return function() {
    self.transport.send(self.session, {'yield': arguments});
  }
}

/*
* Returns data for the request.
*/
Request.prototype.return = function(value) {
  this.transport.send(this.session, {'return': value});
}

/*
 * Sends an Error in response to the request.
 *
 * message - The error message to send.
 */
Request.prototype.error = function(message) {
  this.transport.send(this.session, {'error': message});
}

var SYS  = require('sys');
var FS   = require('fs');
var Process = require('child_process');

/*
 * Creates a new RPC object.
 *
 * transport - The Transport that will handle receiving and sending data.
 */
RPC = function(transport) {
  this.transport = transport;
}

RPC.functions = {
  /* fs functions */
  fs_open: function(args) { return FS.openSync(args[0],args[1]); },
  fs_read: function(args) {
    var buffer = new Buffer();

    FS.readSync(args[0],buffer,args[1]);
    return buffer;
  },
  fs_write: function(args) {
    var buffer = new Buffer(args[2]);

    return FS.writeSync(args[0],buffer,0,buffer.length,args[1]);
  },
  fs_close: function(args) { return FS.closeSync(args[0]); },
  fs_move: function(args) { return FS.renameSync(args[0],args[1]); },
  fs_unlink: function(args) { return FS.unlinkSync(args[0]); },
  fs_rmdir: function(args) { return FS.rmdirSync(args[0]); },
  fs_mkdir: function(args) { return FS.mkdirSync(args[0]); },
  fs_chmodSync: function(args) { return FS.chmodSync(args[0],args[1]); },
  fs_stat: function(args) { return FS.statSync(args[0]); },
  fs_link: function(args) { return FS.symlinkSync(args[0],args[1]); },

  /* process functions */
  process_pid: function(args) { return process.pid; },
  process_getenv: function(args) { return process.env[args[0]]; },
  process_setenv: function(args) { return process.env[args[0]] = args[0]; },
  process_getcwd: function(args) { return process.cwd(); },
  process_chdir:  function(args) { return process.chdir(args[0]); },
  process_getuid: function(args) { return process.getuid(); },
  process_setuid: function(args) { return process.setuid(args[0]); },
  process_getgid: function(args) { return process.getgid(); },
  process_setgid: function(args) { return process.setgid(args[0]); },
  process_time: function(args) { return new Date().getTime(); },
  process_kill: function(args) { return process.kill(args[0]); },
  process_exit: function(args) { process.exit(); },

  shell_exec: function(args,callback) {
    Process.spawn.call(args,function(command) {
      command.stdout.on('data', function(data) {
        callback({stdout: data});
      });

      command.stderr.on('data', function(data) {
        callback({stderr: data});
      });

      command.on('exit', function(data) {
        return code;
      });
    });
  }
}

/*
 * Registers a function with the RPC.
 *
 * name - Name of the registered function.
 * func - The function that will receive the Requests.
 */
RPC.prototype.registerFunction = function(name,func) {
  RPC.functions[name] = func;
};

/*
 * Starts the Transport and begins processing requests.
 */
RPC.prototype.start = function() {
  var self = this;

  this.transport.start(function(request) {
    var func = RPC.functions[request.name];

    if (func == undefined) {
      request.error("Unknown function: " + request.name);
    }

    try {
      request.return(func(request.args,request.callback));
    } catch(error) {
      request.error(error);
    }
  });
}

/*
 * Stops the Transport.
 */
RPC.prototype.stop = function() {
  this.transport.stop();
}

var HTTP = require('http');
var URL  = require('url');

Transports.HTTP = function(port,hostname) {
  this.port     = port;
  this.hostname = hostname;
}

Transports.HTTP.prototype = new Transport();

Transports.HTTP.prototype.start = function(callback) {
  var self = this;

  this.server = HTTP.createServer(function(request,response) {
    var url  = URL.parse(request.url);
    var name = url.pathname.slice(1,request.url.length).replace('/','_');
    var args = (url.query ? self.deserialize(url.query) : []);

    callback(new Request(self,response,name,args));

    response.end();
  });

  this.server.listen(this.port,this.hostname);
}

Transports.HTTP.prototype.stop = function() {
  this.server.close();
}

var transport = new Transports.HTTP(process.args[0],process.args[1]);
var rpc = new RPC(transport);

rpc.start();
