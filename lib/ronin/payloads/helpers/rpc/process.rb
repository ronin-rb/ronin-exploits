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

module Ronin
  module Payloads
    module Helpers
      module RPC
        module Process

          def process_getpid;  rpc_call('process.getpid'); end
          def process_getppid; rpc_call('process.getppid'); end
          def process_getuid; rpc_call('process.getuid'); end
          def process_setuid(uid); rpc_call('process.setuid',uid); end
          def process_geteuid; rpc_call('process.geteuid'); end
          def process_seteuid(euid); rpc_call('process.geteuid',euid); end
          def process_getgid; rpc_call('process.getgid'); end
          def process_setgid(gid); rpc_call('process.setgid',gid); end
          def process_getegid; rpc_call('process.getegid'); end
          def process_setegid(egid); rpc_call('process.getegid',egid); end
          def process_getsid; rpc_call('process.getsid'); end
          def process_setsid(sid); rpc_call('process.setsid',sid); end
          def process_getenv(name); rpc_call('process.getenv',name); end
          def process_setenv(name,value)
            rpc_call('process.setenv',name,value)
          end
          def process_unsetenv(name); rpc_call('process.unsetenv',name); end

          def process_kill(pid,signal='KILL')
            rpc_call('process.kill',pid,signal)
          end
          def process_getcwd; rpc_call('process.getcwd'); end
          def process_chdir(dir); rpc_call('process.chdir',dir); end
          def process_time; Time.at(rpc_call('process.time')); end
          def process_spawn(program,*arguments)
            rpc_call('process.spawn',program,*arguments)
          end
          def process_exit; rpc_call('process.exit'); end

        end
      end
    end
  end
end
