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
    module IO

      # The position within the file
      attr_reader :pos

      # The end-of-file indicator
      attr_reader :eof

      def initialize
        @pos = 0
        @eof = false

        @buffer = nil
      end

      def eof?
        @eof == true
      end

      def each_block
        return enum_for(:each_block) unless block_given?

        # read from the buffer first
        yield read_buffer unless empty_buffer?

        # assume eof has been reached
        @eof = true

        loop do
          block = io_read

          if (block.nil? || block.empty?)
            # short read
            @eof = true
            break
          end

          # not at eof yet
          @eof = false
          @pos += block.length

          yield block
        end
      end

      def read(length=nil,buffer=nil)
        remaining = (length || (0.0 / 0))
        result = ''

        each_block do |block|
          if remaining < block.length
            result << block[0..remaining]
            write_buffer(block[remaining..-1])
            break
          else
            result << block
            remaining -= block.length
          end

          # no more data to read
          break if remaining == 0
        end

        unless result.empty?
          buffer << result if buffer
          return result
        end
      end

      def readpartial(length,buffer=nil)
        read(length,buffer)
      end

      def getc
        c.ord if (c = read(1))
      end

      def ungetc(byte)
        @buffer ||= ''
        @buffer << byte.chr
        return nil
      end

      def gets(separator=$/)
        # if no separator is given, read everything
        return read if separator.nil?

        line = ''

        loop do
          c = read(1)
          break if c.nil? # eof reached

          line << c
          break if c == separator # separator reached
        end

        if line.empty?
          # a line should atleast contain the separator
          raise(EOFError,"end of file reached",caller)
        end

        return line
      end

      def readchar
        unless (c = getc)
          raise(EOFError,"end of file reached",caller)
        end

        return c
      end

      def readbytes(n)
        unless (chunk = read(n))
          raise(EOFError,"end of file reached",caller)
        end

        return chunk.enum_for(:each_byte).to_a
      end

      def readline(separator=$/)
        unless (line = gets(separator))
          raise(EOFError,"end of file reached",caller)
        end

        return line
      end

      def each_byte(&block)
        return enum_for(:each_byte) unless block

        each_block { |chunk| chunk.each_byte(&block) }
      end

      def each_char(&block)
        return enum_for(:each_char) unless block

        each_block { |chunk| chunk.each_char(&block) }
      end

      def each_line(separator=$/)
        return enum_for(:each_line,separator) unless block_given?

        loop do
          break unless (line = gets(separator))

          yield line
        end
      end

      alias each each_line

      def readlines(separator=$/)
        enum_for(:each_line,separator).to_a
      end

      protected

      def clear_buffer!
        @buffer = nil
      end

      def empty_buffer?
        @buffer.nil?
      end

      def read_buffer
        chunk = @buffer
        @pos += buffer.length

        clear_buffer!
        return chunk
      end

      def write_buffer(data)
        @pos -= data.length
        @buffer = data
      end

      def io_read
      end

    end
  end
end
