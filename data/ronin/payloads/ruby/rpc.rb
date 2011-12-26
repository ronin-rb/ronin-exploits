require 'time'
require 'resolv'
require 'socket'
require 'base64'
require 'json'
require 'webrick'

Main = self

module RPC
  def self.fs_open(path,mode)
    File.new(path,mode).fileno
  end

  def self.fs_read(fd,position,length)
    file = File.for_fd(fd)
    file.seek(position)

    return file.read(length)
  end

  def self.fs_write(fd,position,data)
    file = File.for_fd(fd)
    file.seek(position)

    return file.write(data)
  end

  def self.fs_seek(fd,position)
    file = File.for_fd(fd)
    file.seek(position)

    return file.pos
  end

  def self.fs_close(fd)
    file = File.for_fd(fd).close
  end

  def self.process_getpid;             Process.pid;         end
  def self.process_getppid;            Process.ppid;        end
  def self.process_getuid;             Process.uid;         end
  def self.process_setuid(uid);        Process.uid = uid;   end
  def self.process_geteuid;            Process.euid;        end
  def self.process_seteuid(euid);      Process.euid = euid; end
  def self.process_getgid;             Process.gid;         end
  def self.process_setgid(gid);        Process.gid = gid;   end
  def self.process_getegid;            Process.egid;        end
  def self.process_setegid(gid);       Process.egid = egid; end
  def self.process_getsid;             Process.sid;         end
  def self.process_setsid(sid);        Process.sid = sid;   end
  def self.process_getenv(name);       ENV[name];           end
  def self.process_setenv(name,value); ENV[name] = value;   end
  def self.process_unsetenv(name);     ENV.delete(name);    end

  def self.process_kill(pid,signal='KILL'); Process.kill(pid,signal); end
  def self.process_getcwd;                  Dir.pwd;                  end
  def self.process_chdir(path);             Dir.chdir(path);          end
  def self.process_time;                    Time.now.to_i;            end
  def self.process_spawn(program,*arguments)
    fork { exec(program,*arguments) }
  end
  def self.process_exit; exit; end

  @@commands = {}

  def self.shell_exec(program,*arguments)
    io = IO.popen("#{program} #{arguments.join(' ')}")

    @@commands[io.pid] = io
    return io.pid
  end

  def self.shell_read(pid,length)
    unless (command = @@commands[pid])
      raise(RuntimeError,"unknown command pid",caller)
    end

    begin
      return command.read_nonblock(length)
    rescue IO::WaitReadable
      return nil # no data currently available
    end
  end

  def self.shell_write(pid,data)
    unless (command = @@commands[pid])
      raise(RuntimeError,"unknown command pid",caller)
    end

    command.write(data)

    return command.write(length)
  end

  def self.shell_close(pid)
    unless (command = @@commands[pid])
      raise(RuntimeError,"unknown command pid",caller)
    end

    command.close
    @@commands.delete(pid)
    return true
  end

  @@sockets = {}

  def self.net_dns_lookup(host)
    Resolv.getaddresses(host)
  end

  def self.net_dns_reverse_lookup(ip)
    Resolv.getnames(host)
  end

  def self.net_tcp_connect(host,port,local_host=nil,local_port=nil)
    socket = TCPSocket.new(host,port,local_host,local_port)

    @@sockets[socket.fileno] = socket
    return socket.fileno
  end

  def self.net_tcp_listen(port,host=nil)
    socket = TCPServer.new(port,host)
    socket.listen(256)

    @@sockets[socket.fileno] = socket
    return socket.fileno
  end

  def self.net_tcp_accept(fd)
    unless (socket = @@sockets[fd])
      raise(RuntimeError,"unknown socket file-descriptor")
    end

    begin
      client = socket.accept_nonblock
    rescue IO::WaitReadable, Errno::EINTR
      return nil
    end

    @@sockets[client.fileno] = client
    return client.fileno
  end

  def self.net_tcp_recv(fd,length)
    unless (socket = @@sockets[fd])
      raise(RuntimeError,"unknown socket file-descriptor")
    end

    begin
      return socket.recv_nonblock(length)
    rescue IO::WaitReadable
      return nil
    end
  end

  def self.net_tcp_send(fd,data)
    unless (socket = @@sockets[fd])
      raise(RuntimeError,"unknown socket file-descriptor")
    end

    return socket.send(data)
  end

  def self.net_udp_connect(host,port,local_host=nil,local_port=nil)
    socket = UDPSocket.new(host,port,local_host,local_port)

    @@sockets[socket.fileno] = socket
    return socket.fileno
  end

  def self.net_udp_listen(port,host=nil)
    socket = UDPServer.new(port,host)

    @@sockets[socket.fileno] = socket
    return socket.fileno
  end

  def self.net_udp_recv(fd,length)
    unless (socket = @@sockets[fd])
      raise(RuntimeError,"unknown socket file-descriptor")
    end

    begin
      return socket.recvfrom_nonblock(length)
    rescue IO::WaitReadable
      return nil
    end
  end

  def self.net_udp_send(fd,data,host=nil,port=nil)
    unless (socket = @@sockets[fd])
      raise(RuntimeError,"unknown socket file-descriptor")
    end

    if (host && port)
      return socket.send(data,0,host,port)
    else
      return socket.send(data)
    end
  end

  def self.net_remote_address(fd)
    unless (socket = @@sockets[fd])
      raise(RuntimeError,"unknown socket file-descriptor")
    end

    addrinfo = socket.remote_address

    return [addrinfo.ip_address, addrinfo.ip_port]
  end

  def self.net_local_address(fd)
    unless (socket = @@sockets[fd])
      raise(RuntimeError,"unknown socket file-descriptor")
    end

    addrinfo = socket.local_address

    return [addrinfo.ip_address, addrinfo.ip_port]
  end

  def self.net_close(fd)
    unless (socket = @@sockets[fd])
      raise(RuntimeError,"unknown socket file-descriptor")
    end

    socket.close
    @@sockets.delete(fd)
    return true
  end

  def self.ruby_eval(code); Main.eval(code); end
  def self.ruby_define(name,args,code)
    module_eval %{
      def #{name}(#{args.join(',')})
        #{code}
      end
    }
  end

  def self.ruby_version;  RUBY_VERSION;  end
  def self.ruby_platform; RUBY_PLATFORM; end
  def self.ruby_engine
    if Object.const_defined?('RUBY_ENGINE')
      Object.const_get(RUBY_ENGINE)
    end
  end

  class Server < WEBrick::HTTPServlet::AbstractServlet

    def do_GET(request,response)
      name = request.path[1..-1].gsub('/','_')
      args = if request.query_string
               deserialize(request.query_string)
             else
               []
             end

      status, content_type, body = dispatch(name,args)

      response.status          = status
      response['Content-Type'] = content_type
      response.body            = body
    end

    protected

    def dispatch(name,args)
      method = begin
                 RPC.method(name)
               rescue NameError
                 return error_response("Unknown method: #{name}")
               end

      return_value = begin
                       method.call(*args)
                     rescue => exception
                       return error_response("#{exception.class}: #{exception}")
                     end

      response(200, {'return' => return_value})
    end

    def serialize(data)
      Base64.encode64(data.to_json)
    end

    def deserialize(data)
      JSON.parse(Base64.decode64(data))
    end

    def response(code,data)
      [code, 'text/plain', serialize(data)]
    end

    def error_response(message)
      response(404, {'exception' => message})
    end

    def return_response(value)
      response(200, {'return' => value})
    end

  end
end

unless ARGV.length >= 1
  $stderr.puts "usage: #{$0} PORT [HOST]"
  exit -1
end

server = WEBrick::HTTPServer.new(:Host => ARGV[1], :Port => ARGV[0])
server.mount '/', RPC::Server

trap('INT') { server.shutdown }

server.start
