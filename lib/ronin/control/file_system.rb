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

require 'ronin/control/exceptions/not_implemented'

module Ronin
  module Control
    module FileSystem
      #
      # Returns +true+ if the specified _path_ exists, returns +false+
      # otherwise.
      #
      def exists?(path)
        raise(NotImplemented,"the exists? method has not been implemented",caller)
      end

      #
      # Returns +true+ if the specified _path_ is a file, returns +false+
      # otherwise.
      #
      def file?(path)
        raise(NotImplemented,"the file? method has not been implemented",caller)
      end

      #
      # Returns +true+ if the specified _path_ is a directory, returns
      # +false+ otherwise.
      #
      def dir?(path)
        raise(NotImplemented,"the dir? method has not been implemented",caller)
      end

      #
      # Returns the contents of the directory at the specified _path_.
      #
      def dir(path)
        raise(NotImplemented,"the dir method has not been implemented",caller)
      end

      #
      # Returns all the paths matching the specified globbed _pattern_.
      #
      def glob(pattern)
        raise(NotImplemented,"the glob method has not been implemented",caller)
      end

      #
      # Returns the current working directory.
      #
      def cwd
        @cwd ||= ''
      end

      #
      # Changes the current working directory to the specified _path_.
      #
      def chdir(path)
        @cwd = path
      end

      #
      # Goes up one directory.
      #
      def updir!
        chdir(join_paths(cwd,'..'))
      end

      #
      # Returns the contents of the file at the specified _path_.
      #
      def read_file(path)
        raise(NotImplemented,"the read_file method has not been implemented",caller)
      end

      #
      # Writes the specified _contents_ to the file at the specified
      # _path_.
      #
      def write_file(path,contents)
        raise(NotImplemented,"the write_file method has not been implemented",caller)
      end

      #
      # Appends the specified _contents_ to the file at the specified
      # _path_.
      #
      def append_file(path,contents)
        raise(NotImplemented,"the append_file method has not been implemented",caller)
      end

      #
      # Touches the file at the specified _path_.
      #
      def touch(path)
        write_file(path,'')
      end

      #
      # Removes the file at the specified _path_.
      #
      def rm(path)
        raise(NotImplemented,"the rm method has not been implemented",caller)
      end

      #
      # Removes the directory at the specified _path_.
      #
      def rmdir(path)
        raise(NotImplemented,"the rmdir method has not been implemented",caller)
      end

      #
      # Recursively removes the file or directory at the specified _path_.
      #
      def rm_r(path)
        raise(NotImplemented,"the rm_r method has not been implemented",caller)
      end

      protected

      #
      # Returns the File name separator to use.
      #
      def path_separator
        File::SEPARATOR
      end

      #
      # Joins the given _paths_ with the path_separator.
      #
      def join_paths(*paths)
        paths.join(path_separator)
      end

      #
      # Expands the specified _path_ to it's absolute form.
      #
      def expand_path(path)
        File.expand_path(path)
      end

      #
      # Converts the specified _sub_path_ to an absolute path, only if it
      # is a realitive path.
      #
      def absolute_path(sub_path)
        if sub_path[0..0] == path_separator
          return sub_path
        else
          return expand_path(join_paths(cwd,sub_path))
        end
      end

      #
      # Raises an <tt>Errno::ENOENT</tt> exception if the specified
      # _path_ cannot be found.
      #
      def file_not_found!(path)
        path = path.to_s

        raise(Errno::ENOENT,"No such file or directory - #{path.dump}",caller)
      end
    end
  end
end
