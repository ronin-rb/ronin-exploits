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
      module FileSystem
        def dir(path)
          raise(Unimplemented,"the dir method has not been implemented",caller)
        end

        def glob(pattern)
          raise(Unimplemented,"the glob method has not been implemented",caller)
        end

        def cwd
          @cwd ||= ''
        end

        def chdir(path)
          @cwd = path
        end

        def updir!
          chdir(join_paths(cwd,'..'))
        end

        def read_file(path)
          raise(Unimplemented,"the read_file method has not been implemented",caller)
        end

        def write_file(path,contents)
          raise(Unimplemented,"the write_file method has not been implemented",caller)
        end

        def append_file(path,contents)
          raise(Unimplemented,"the append_file method has not been implemented",caller)
        end

        def touch(path)
          write_file(path,'')
        end

        def rm(path)
          raise(Unimplemented,"the rm method has not been implemented",caller)
        end

        def rm_r(path)
          raise(Unimplemented,"the rm_r method has not been implemented",caller)
        end

        protected

        def path_separator
          File::SEPARATOR
        end

        def join_paths(*paths)
          paths.join(path_separator)
        end

        def expand_path(path)
          File.expand_path(path)
        end

        def absolute_path(sub_path)
          if sub_path[0..0] == path_separator
            return sub_path
          else
            return expand_path(join_paths(cwd,sub_path))
          end
        end
      end
    end
  end
end
