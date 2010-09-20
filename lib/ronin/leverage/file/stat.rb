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

module Ronin
  module Leverage
    class File
      #
      # Represents the status information of a remote file. The {Stat} class
      # using the `fs_stat` method defined by the leveraging object to
      # request the remote status information.
      #
      class Stat

        # The path of the file
        attr_reader :path

        # The size of the file (in bytes)
        attr_reader :size

        # The number of native file-system blocks
        attr_reader :blocks

        # The native file-system block size.
        attr_reader :block_size

        # The Inode number
        attr_reader :inode

        # The number of hard links to the file
        attr_reader :nlinks

        # The mode of the file
        attr_reader :mode

        #
        # Creates a new File Stat object.
        #
        # @param [#fs_stat] leverage
        #   The object leveraging file-system stat.
        #
        # @param [String] path
        #   The path of the remote.
        #
        # @raise [RuntimeError]
        #   The leveraging object does not define `fs_stat` needed by
        #   {Stat}.
        #
        # @raise [Errno::ENOENT]
        #   The remote file does not exist.
        #
        # @since 0.4.0
        #
        def initialize(leverage,path)
         unless leverage.respond_to?(:fs_stat)
            raise(RuntimeError,"#{leverage.inspect} must define fs_stat for #{self.class}",caller)
          end

          @leverage = leverage
          @path = path.to_s

          unless (stat = @leverage.fs_stat(@path))
            raise(Errno::ENOENT,"No such file or directory #{@path.dump}",caller)
          end

          @size = stat[:size]
          @blocks = stat[:blocks]
          @block_size = stat[:block_size]
          @inode = stat[:inode]
          @nlinks = stat[:nlinks]

          @mode = stat[:mode]
          @uid = stat[:uid]
          @gid = stat[:gid]

          @atime = stat[:atime]
          @ctime = stat[:ctime]
          @mtime = stat[:mtime]
        end

        alias ino inode
        alias blksize blocksize

        #
        # Determines whether the file has zero size.
        #
        # @return [Boolean]
        #   Specifies whether the file has zero size.
        #
        # @since 0.4.0
        #
        def zero?
          @size == 0
        end

      end
    end
  end
end
