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

      end
    end
  end
end
