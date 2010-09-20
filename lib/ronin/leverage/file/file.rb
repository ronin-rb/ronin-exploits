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

require 'ronin/leverage/io'

module Ronin
  module Leverage
    class File

      include IO

      # The file descriptor
      attr_reader :fd

      #
      # Creates a new levered File object.
      #
      # @param [#fs_read] leverage
      #   The object leveraging remote files.
      #
      # @param [String] path
      #   The path of the remote file.
      #
      # @raise [RuntimeError]
      #   The leveraging object does not define `fs_read`.
      #
      # @since 0.4.0
      #
      def initialize(leverage,path,&block)
        unless leverage.respond_to?(:fs_read)
          raise(RuntimeError,"#{leverage.inspect} must define fs_read for #{self.class}",caller)
        end

        @leverage = leverage
        @path = path.to_s

        super(&block)
      end

      #
      # Sets the position in the file to read.
      #
      # @param [Integer] new_pos
      #   The new position to read from.
      #
      # @return [Integer]
      #   The new position within the file.
      #
      # @since 0.4.0
      #
      def pos=(new_pos)
        clear_buffer!
        @pos = new_pos
      end

      protected

      #
      # Attempts calling `fs_open` from the leveraging object to open
      # the remote file.
      #
      # @return [Object]
      #   The file descriptor returned by `fs_open`.
      #
      # @since 0.4.0
      #
      def io_open
        @fd = if @leverage.respond_to?(:fs_open)
                    @leverage.fs_open(@path)
                  else
                    @path
                  end
      end

      #
      # Reads a block from the remote file by calling `fs_read` from the
      # leveraging object.
      #
      # @return [String, nil]
      #   A block of data from the file.
      #
      # @since 0.4.0
      #
      def io_read
        @leverage.fs_read(@fd,@pos)
      end

      #
      # Attempts calling `fs_close` from the leveraging object to close
      # the file.
      #
      # @since 0.4.0
      #
      def io_close
        if @leverage.respond_to?(:fs_close)
          @leverage.fs_close(@fd)
        end
        
        @fd = nil
      end

    end
  end
end
