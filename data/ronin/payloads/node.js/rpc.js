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
Transport.prototype.serialize = JSON.stringify;

/*
 * The default data deserialization function.
 */
Transport.prototype.deserialize = JSON.parse;

/*
 * Sends a yield message to the session.
 *
 * session - Abstract session belonging to the Transport.
 * arguments - The arguments to encode and send.
 */
Transport.prototype.sendYield = function(session,arguments) {}

/*
 * Sends a return message to the session.
 *
 * session - Abstract session belonging to the Transport.
 * value - The return value to encode and send.
 */
Transport.prototype.sendReturn = function(session,value) {}

/*
 * Sends an error message to the session.
 *
 * session - Abstract session belonging to the Transport.
 * message - The error message to send.
 */
Transport.prototype.sendError = function(session,message) {}

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
* Yields the arguments for the request.
*/
Request.prototype.yield = function() {
  this.transport.sendYield(this.session,arguments);
}

/*
* Returns data for the request.
*/
Request.prototype.return = function(value) {
  this.transport.sendReturn(this.session,value);
}

/*
 * Sends an Error in response to the request.
 *
 * message - The error message to send.
 */
Request.prototype.error = function(message) {
  this.transport.sendError(this.session,message);
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
  this.functions = {
    /* process functions */
    process_pid: function(request) { return process.pid; },
    process_getenv: function(request) {
      return process.env[request.args[0]];
    },
    process_setenv: function(request) {
      return process.env[request.args[0]] = request.args[0];
    },
    process_getcwd: function(request) { return process.cwd(); },
    process_chdir:  function(request) {
      return process.chdir(request.args[0]);
    },
    process_getuid: function(request) { return process.getuid(); },
    process_setuid: function(request) {
      return process.setuid(request.args[0]);
    },
    process_getgid: function(request) { return process.getgid(); },
    process_setgid: function(request) {
      return process.setgid(request.args[0]);
    },
    process_time: function(request) { return new Date().getTime(); },
    process_kill: function(request) { return process.kill(request.args[0]); }
    process_exit: function(request) { process.exit(); }

    shell_exec: function(request) {
      Process.spawn.call(request.args,function(command) {
        command.stdout.on('data', function(data) {
          request.yield({stdout: data});
        });

        command.stderr.on('data', function(data) {
          request.yield({stderr: data});
        });

        command.on('exit', function(data) {
          request.return(code);
        });
      });
    }
  };
}

/*
 * Registers a function with the RPC.
 *
 * name - Name of the registered function.
 * func - The function that will receive the Requests.
 */
RPC.prototype.registerFunction = function(name,func) {
  this.functions[name] = func;
};

/*
 * Starts the Transport and begins processing requests.
 */
RPC.prototype.start = function() {
  var self = this;

  this.transport.start(function(request) {
    var func = self.functions[request.name];

    if (func == undefined) {
      request.error("Unknown function: " + request.name);
    }

    try {
      request.return(func(request));
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

Transports.HTTP.prototype.serialize = function(data) {
  return new Buffer(JSON.stringify(data)).toString('base64');
}

Transports.HTTP.prototype.deserialize = function(data) {
  return JSON.parse(new Buffer(data,'base64'));
}

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

Transports.HTTP.prototype.sendYield = function(session,args) {
  var mesg = {yield: args};

  session.write(this.serialize(mesg));
}

Transports.HTTP.prototype.sendReturn = function(session,value) {
  var mesg = {return_value: value};

  session.write(this.serialize(mesg));
}

Transports.HTTP.prototype.sendError = function(session,message) {
  var mesg = {error: message};

  session.write(this.serialize(mesg));
}

Transports.HTTP.prototype.stop = function() {
  this.server.close();
}

var transport = new Transports.HTTP(process.args[0],process.args[1]);
var rpc = new RPC(transport);

rpc.start();
