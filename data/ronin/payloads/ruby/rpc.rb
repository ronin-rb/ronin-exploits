require 'time'
require 'resolv'
require 'socket'
require 'base64'
require 'json'

Main = self

module RPC
  module Fs
    def self.open(path,mode); File.new(path,mode).fileno; end

    def self.read(fd,position,length)
      file = File.for_fd(fd)
      file.seek(position)

      return file.read(length)
    end

    def self.write(fd,position,data)
      file = File.for_fd(fd)
      file.seek(position)

      return file.write(data)
    end

    def self.seek(fd,position)
      file = File.for_fd(fd)
      file.seek(position)

      return file.pos
    end

    def self.close(fd); file = File.for_fd(fd).close; end
  end

  module Process
    def self.getpid;             ::Process.pid;         end
    def self.getppid;            ::Process.ppid;        end
    def self.getuid;             ::Process.uid;         end
    def self.setuid(uid);        ::Process.uid = uid;   end
    def self.geteuid;            ::Process.euid;        end
    def self.seteuid(euid);      ::Process.euid = euid; end
    def self.getgid;             ::Process.gid;         end
    def self.setgid(gid);        ::Process.gid = gid;   end
    def self.getegid;            ::Process.egid;        end
    def self.setegid(gid);       ::Process.egid = egid; end
    def self.getsid;             ::Process.sid;         end
    def self.setsid(sid);        ::Process.sid = sid;   end
    def self.getenv(name);       ENV[name];             end
    def self.setenv(name,value); ENV[name] = value;     end
    def self.unsetenv(name);     ENV.delete(name);      end

    def self.kill(pid,signal='KILL'); ::Process.kill(pid,signal); end
    def self.getcwd;                  Dir.pwd;                    end
    def self.chdir(path);             Dir.chdir(path);            end
    def self.time;                    Time.now.to_i;              end
    def self.spawn(program,*arguments)
      fork { exec(program,*arguments) }
    end
    def self.exit; exit; end
  end

  module Shell
    COMMANDS = {}

    def self.exec(program,*arguments)
      io = IO.popen("#{program} #{arguments.join(' ')}")

      COMMANDS[io.pid] = io
      return io.pid
    end

    def self.read(pid,length)
      unless (command = COMMANDS[pid])
        raise(RuntimeError,"unknown command pid",caller)
      end

      begin
        return command.read_nonblock(length)
      rescue IO::WaitReadable
        return nil # no data currently available
      end
    end

    def self.write(pid,data)
      unless (command = COMMANDS[pid])
        raise(RuntimeError,"unknown command pid",caller)
      end

      command.write(data)

      return command.write(length)
    end

    def self.close(pid)
      unless (command = COMMANDS[pid])
        raise(RuntimeError,"unknown command pid",caller)
      end

      command.close
      COMMANDS.delete(pid)
      return true
    end
  end

  module Net
    SOCKETS = {}

    module Dns
      def self.lookup(host)
        Resolv.getaddresses(host)
      end

      def self.reverse_lookup(ip)
        Resolv.getnames(host)
      end
    end

    module Tcp
      def self.connect(host,port,local_host=nil,local_port=nil)
        socket = TCPSocket.new(host,port,local_host,local_port)

        SOCKETS[socket.fileno] = socket
        return socket.fileno
      end

      def self.listen(port,host=nil)
        socket = TCPServer.new(port,host)
        socket.listen(256)

        SOCKETS[socket.fileno] = socket
        return socket.fileno
      end

      def self.accept(fd)
        unless (socket = SOCKETS[fd])
          raise(RuntimeError,"unknown socket file-descriptor")
        end

        begin
          client = socket.accept_nonblock
        rescue IO::WaitReadable, Errno::EINTR
          return nil
        end

        SOCKETS[client.fileno] = client
        return client.fileno
      end

      def self.recv(fd,length)
        unless (socket = SOCKETS[fd])
          raise(RuntimeError,"unknown socket file-descriptor")
        end

        begin
          return socket.recv_nonblock(length)
        rescue IO::WaitReadable
          return nil
        end
      end

      def self.send(fd,data)
        unless (socket = SOCKETS[fd])
          raise(RuntimeError,"unknown socket file-descriptor")
        end

        return socket.send(data)
      end
    end

    module Udp
      def self.connect(host,port,local_host=nil,local_port=nil)
        socket = UDPSocket.new(host,port,local_host,local_port)

        SOCKETS[socket.fileno] = socket
        return socket.fileno
      end

      def self.listen(port,host=nil)
        socket = UDPServer.new(port,host)

        SOCKETS[socket.fileno] = socket
        return socket.fileno
      end

      def self.recv(fd,length)
        unless (socket = SOCKETS[fd])
          raise(RuntimeError,"unknown socket file-descriptor")
        end

        begin
          return socket.recvfrom_nonblock(length)
        rescue IO::WaitReadable
          return nil
        end
      end

      def self.send(fd,data,host=nil,port=nil)
        unless (socket = SOCKETS[fd])
          raise(RuntimeError,"unknown socket file-descriptor")
        end

        if (host && port)
          return socket.send(data,0,host,port)
        else
          return socket.send(data)
        end
      end
    end

    def self.remote_address(fd)
      unless (socket = SOCKETS[fd])
        raise(RuntimeError,"unknown socket file-descriptor")
      end

      addrinfo = socket.remote_address

      return [addrinfo.ip_address, addrinfo.ip_port]
    end

    def self.local_address(fd)
      unless (socket = SOCKETS[fd])
        raise(RuntimeError,"unknown socket file-descriptor")
      end

      addrinfo = socket.local_address

      return [addrinfo.ip_address, addrinfo.ip_port]
    end

    def self.close(fd)
      unless (socket = SOCKETS[fd])
        raise(RuntimeError,"unknown socket file-descriptor")
      end

      socket.close
      SOCKETS.delete(fd)
      return true
    end
  end

  module Ruby
    def self.eval(code); Main.eval(code); end
    def self.define(name,args,code)
      module_eval %{
        def self.#{name}(#{args.join(',')})
          #{code}
        end
      }
      return true
    end

    def self.version;  RUBY_VERSION;  end
    def self.platform; RUBY_PLATFORM; end
    def self.engine
      if Object.const_defined?('RUBY_ENGINE')
        Object.const_get('RUBY_ENGINE')
      end
    end
  end

  def self.[](names)
    method_name = names.pop
    scope       = RPC

    names.each do |name|
      scope = begin
                scope.const_get(name.capitalize)
              rescue NameError
                return nil
              end
    end

    begin
      scope.method(method_name)
    rescue NameError
    end
  end

  module Transport
    protected

    def call(name,arguments)
      unless (method = lookup(name))
        return error_message("Unknown method: #{name}")
      end

      value = begin
                method.call(*arguments)
              rescue => exception
                return error_message("#{exception.class}: #{exception}")
              end

      return_message(value)
    end

    def error_message(message); {'exception' => message}; end
    def return_message(value);  {'return' => value};      end

    def serialize(data);   Base64.encode64(data.to_json);     end
    def deserialize(data); JSON.parse(Base64.decode64(data)); end
  end

  require 'webrick'

  class HTTP < WEBrick::HTTPServlet::AbstractServlet
    
    include Transport

    def self.start(port,host=nil)
      server = WEBrick::HTTPServer.new(:Host => host, :Port => port)
      server.mount '/', self

      trap('INT') { server.shutdown }

      server.start
    end

    def do_GET(request,response)
      name = request.path
      args = if request.query_string
               deserialize(request.query_string)
             else
               []
             end

      message = call(name,args)

      response.status = (message['exception'] ? 404 : 200)
      response.body   = serialize(message)
    end

    protected

    def lookup(path); RPC[path[1..-1].split('/')]; end

  end
end

if $0 == __FILE__
  unless ARGV.length >= 1
    $stderr.puts "usage: #{$0} PORT [HOST]"
    exit -1
  end

  RPC::HTTP.start(ARGV[0],ARGV[1])
end
