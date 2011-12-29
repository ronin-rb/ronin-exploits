require 'fileutils'
require 'time'
require 'resolv'
require 'socket'
require 'base64'
require 'json'

Main = self

module RPC
  module Fs
    extend FileUtils

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

    def self.getcwd;                   Dir.pwd;                            end
    def self.readlink(path);           File.readlink(path);                end
    def self.readdir(path);            Dir.entries(path);                  end
    def self.glob(pattern);            Dir.glob(pattern);                  end
    def self.mktemp(basename);         Tempfile.new(basename).path;        end
    def self.unlink(path);             File.unlink(path);                  end
    def self.chown(user,path);         FileUtils.chown(user,nil,path);     end
    def self.chgrp(group,path);        FileUtils.chown(nil,group,path);    end
    def self.stat(path);               File.stat(path);                    end
    def self.compare(path,other_path); File.compare_file(path,other_path); end
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

  def self.[](name)
    names       = name.split('.')
    method_name = names.pop
    scope       = RPC

    names.each do |name|
      scope = begin
                scope.const_get(name.capitalize)
              rescue NameError
                return nil
              end

      return if scope.nil?
    end

    begin
      scope.method(method_name)
    rescue NameError
    end
  end

  def self.call(name,arguments)
    unless (method = self[name])
      return {'exception' => "Unknown method: #{names.join('.')}"}
    end

    value = begin
              method.call(*arguments)
            rescue => exception
              return {'exception' => exception.message}
            end

    return {'return' => value}
  end

  module Transport
    protected

    def serialize(data);   Base64.encode64(data.to_json);     end
    def deserialize(data); JSON.parse(Base64.decode64(data)); end
  end

  module HTTP
    require 'webrick'

    class Server < WEBrick::HTTPServlet::AbstractServlet

      include Transport

      def self.start(port,host=nil)
        server = WEBrick::HTTPServer.new(:Host => host, :Port => port)
        server.mount '/', self

        trap('INT') { server.shutdown }

        server.start
      end

      def do_GET(request,response)
        decode_request(request) do |name,args|
          encode_response(response,RPC.call(name,args))
        end
      end

      protected

      def decode_request(request)
        name = request.path[1..-1].gsub('/','.')
        args = (request.query_string ? deserialize(request.query_string) : [])

        yield name, args
      end

      def encode_response(response,message)
        response.status = (message['exception'] ? 404 : 200)
        response.body   = serialize(message)
      end

    end
  end

  module TCP
    module Protocol
      protected

      def decode_request(request)
        name = request['name']
        args = (request['arguments'] || [])

        yield name, args
      end

      def encode_response(socket,message)
        socket.write(serialize(message))
      end

      def serve(socket)
        buffer = ''

        socket.each_line do |line|
          buffer << line

          if line.chomp.end_with?('=')
            decode_request(buffer) do |name,args|
              encode_response(socket,RPC.call(name,args))
            end

            buffer = ''
          end
        end
      end
    end

    require 'socket'

    class ConnectBack

      include Transport, Protocol

      attr_reader :host, :port, :local_host, :local_port

      def initialize(host,port,local_host=nil,local_port=nil)
        @host       = host
        @port       = port
        @local_host = local_host
        @local_port = local_port
      end

      def self.start(host,port,local_host=nil,local_port=nil)
        client = new(host,port,local_host,local_port)

        trap('INT') { client.stop }

        client.start
      end

      def start
        @connection = TCPSocket.new(@host,@port,@local_host,@local_port)

        serve(@connection)
      end

      def stop; @connection.close; end

    end

    require 'gserver'

    class Server < GServer

      include Transport, Protocol

      def self.start(port,host=nil)
        server = new(port,host)

        trap('INT') { server.stop }
        
        server.start
        server.join
      end

    end
  end
end

if $0 == __FILE__
  def usage
    puts "usage: #{$0} [--http PORT [HOST]] [--listen PORT [HOST]] [--connect HOST PORT]"
    exit -1
  end

  case ARGV[0]
  when '--http'
    RPC::HTTP::Server.start ARGV[1], ARGV[2]
  when '--listen'
    RPC::TCP::Server.start ARGV[1], ARGV[2]
  when '--connect'
    RPC::TCP::ConnectBack.start ARGV[1], ARGV[2]
  else
    usage
  end
end
