#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2010 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ronin/leverage/resources/resource'

module Ronin
  module Leverage
    module Resources
      class Sys < Resource

        def pid
          requires_method! :sys_getpid

          @leverage.sys_getpid
        end

        def ppid
          requires_method! :sys_getppid

          @leverage.sys_getppid
        end

        def uid
          requires_method! :sys_getuid

          @leverage.sys_getuid
        end

        def uid=(new_uid)
          requires_method! :sys_setuid

          @leverage.sys_setuid(new_uid)
        end

        def euid
          requires_method! :sys_geteuid

          @leverage.sys_geteuid
        end

        def euid=(new_euid)
          requires_method! :sys_seteuid

          @leverage.sys_seteuid(new_euid)
        end

        def gid
          requires_method! :sys_getgid

          @leverage.sys_getgid
        end

        def gid=(gid)
          requires_method! :sys_setgid

          @leverage.sys_setgid(new_gid)
        end

        def egid
          requires_method! :sys_getegid

          @leverage.sys_getegid
        end

        def egid=(new_egid)
          requires_method! :sys_setegid

          @leverage.sys_setegid(new_egid)
        end

        def sid
          requires_method! :sys_getsid

          @leverage.sys_getsid
        end

        def setsid(new_sid)
          requires_method! :sys_setsid

          @leverage.sys_setsid(new_sid)
        end

        def kill(pid)
          requires_method! :sys_kill

          @leverage.sys_kill(pid)
        end

        def getcwd
          requires_method! :sys_getcwd

          @leverage.sys_getcwd
        end

        def chdir(path)
          requires_method! :sys_chdir

          @leverage.sys_chdir(path)
        end

        def time
          requires_method! :sys_time

          @leverage.sys_time
        end

        def exit
          requires_method! :sys_exit

          @leverage.sys_exit
        end

      end
    end
  end
end
