#
#--
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2009 Hal Brodigan (postmodern.mod3 at gmail.com)
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
#++
#

require 'ronin/payloads/helpers/exceptions/unimplemented'

module Ronin
  module Payloads
    module Helpers
      module Shell
        #
        # Executes the specified _command_ with the given _arguments_.
        #
        def exec(command,*arguments)
          raise(Unimplemented,"the exec method has not been implemented",caller)
        end

        #
        # Executes the specified _command_ with the given _arguments_,
        # and prints the output of the command.
        #
        def sh(command,*args)
          puts exec(command,*args)
        end

        #
        # Changes the current working directory of the shell to the
        # specified _path_.
        #
        def cd(path)
          exec('cd',path)
          return path
        end

        #
        # Returns the current working directory of the shell.
        #
        def pwd
          exec('pwd').chomp
        end

        #
        # Returns the listed files or directories using the given _arguments_.
        #
        def ls(*arguments)
          exec('ls',*arguments).split(/\n\r?/)
        end

        #
        # Returns the +Hash+ of environment variables to use for the
        # shell.
        #
        def env
          @env ||= {}
        end
      end
    end
  end
end
