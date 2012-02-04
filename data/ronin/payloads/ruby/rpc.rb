require 'fileutils'
require 'time'
require 'resolv'
require 'socket'
require 'base64'
require 'json'

Main = self

module RPC
  BLOCK_SIZE = (1024 * 512)

  module Fs
    extend FileUtils

    def self.open(path,mode); File.new(path,mode).fileno; end

    def self.read(fd,position)
      file = File.for_fd(fd)
      file.seek(position)

      return file.read(BLOCK_SIZE)
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
    def self.shell; @shell ||= IO.popen(ENV['SHELL']); end

    def self.exec(program,*arguments)
      io = IO.popen("#{program} #{arguments.join(' ')}")

      self.processes[io.pid] = io
      return io.pid
    end

    def self.read(pid)
      process = self.process(pid)

      begin
        return process.read_nonblock(BLOCK_SIZE)
      rescue IO::WaitReadable
        return nil # no data currently available
      end
    end

    def self.write(pid,data)
      self.process(pid).write(data)
    end

    def self.close(pid)
      process = self.process(pid)
      process.close

      self.processes.delete(pid)
      return true
    end
  end

  module Net
    def self.sockets; @sockets ||= {}; end
    def self.socket(fd)
      unless (socket = sockets[fd])
        raise(RuntimeError,"unknown socket file-descriptor",caller)
      end

      return socket
    end

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

        Net.sockets[socket.fileno] = socket
        return socket.fileno
      end

      def self.listen(port,host=nil)
        socket = TCPServer.new(port,host)
        socket.listen(256)

        Net.sockets[socket.fileno] = socket
        return socket.fileno
      end

      def self.accept(fd)
        socket = Net.socket(fd)

        begin
          client = socket.accept_nonblock
        rescue IO::WaitReadable, Errno::EINTR
          return nil
        end

        Net.sockets[client.fileno] = client
        return client.fileno
      end

      def self.recv(fd)
        socket = Net.socket(fd)

        begin
          return socket.recv_nonblock(BLOCK_SIZE)
        rescue IO::WaitReadable
          return nil
        end
      end

      def self.send(fd,data)
        Net.socket(fd).send(data)
      end
    end

    module Udp
      def self.connect(host,port,local_host=nil,local_port=nil)
        socket = UDPSocket.new(host,port,local_host,local_port)

        Net.sockets[socket.fileno] = socket
        return socket.fileno
      end

      def self.listen(port,host=nil)
        socket = UDPServer.new(port,host)

        Net.sockets[socket.fileno] = socket
        return socket.fileno
      end

      def self.recv(fd)
        socket = Net.socket(fd)

        begin
          return socket.recvfrom_nonblock(BLOCK_SIZE)
        rescue IO::WaitReadable
          return nil
        end
      end

      def self.send(fd,data,host=nil,port=nil)
        socket = Net.socket(fd)

        if (host && port)
          return socket.send(data,0,host,port)
        else
          return socket.send(data)
        end
      end
    end

    def self.remote_address(fd)
      socket   = self.socket(fd)
      addrinfo = socket.remote_address

      return [addrinfo.ip_address, addrinfo.ip_port]
    end

    def self.local_address(fd)
      socket   = self.socket(fd)
      addrinfo = socket.local_address

      return [addrinfo.ip_address, addrinfo.ip_port]
    end

    def self.close(fd)
      socket = self.socket(fd)
      socket.close

      self.sockets.delete(fd)
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

    return if method_name.nil?

    names.each do |name|
      scope = begin
                scope.const_get(name.capitalize)
              rescue NameError
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
      return {'exception' => "Unknown method: #{name}"}
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

    def decode_request(request)
      request = deserialize(request)

      return request['name'], request.fetch('arguments',[])
    end

    def encode_response(response); serialize(response); end
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
        p request.query_string

        name, arguments = decode_request(request.query['_request'])

        encode_response(response,RPC.call(name,arguments))
      end

      protected

      def encode_response(response,message)
        response.status = (message.has_key?('exception') ? 404 : 200)
        response.body   = super(message)
      end

    end
  end

  module TCP
    module Protocol
      include Transport

      protected

      def decode_request(request)
        super(request.chomp("\0"))
      end

      def encode_response(socket,message)
        socket.write(super(message) + "\0")
      end

      def serve(socket)
        loop do
          name, arguments = decode_request(socket.readline("\0"))

          encode_response(socket,RPC.call(name,arguments))
        end
      end
    end

    require 'socket'

    class ConnectBack

      include Protocol

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

      include Protocol

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
