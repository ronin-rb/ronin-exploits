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

require 'open_namespace'
require 'base64'
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

            build do
              extend Ronin::Payloads::Helpers::RPC.require_const(self.transport)
            end

            deploy do
              rpc_connect if respond_to?(:rpc_connect)
            end

            evacuate do
              rpc_disconnect if respond_to?(:rpc_disconnect)
            end
          end
        end

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

        def rpc_serialize(message)
          Base64.encode64(message.to_json)
        end

        def rpc_deserialize(data)
          JSON.parse(Base64.decode64(data))
        end

      end
    end
  end
end
