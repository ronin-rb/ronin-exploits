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
    class IO < ::IO

      # The position within the IO stream
      attr_reader :pos

      # The end-of-file indicator
      attr_reader :eof

      # The file descriptor
      attr_reader :fd

      #
      # Initializes the IO stream.
      #
      # @yield [io]
      #   The given block will be passed the newly created IO stream.
      #   When the block has returned, the IO object will be closed.
      #
      # @yieldparam [IO]
      #   The newly created IO stream.
      #
      # @since 0.4.0
      #
      def initialize
        @pos = 0
        @eof = false
        @closed = true

        @buffer = nil

        @fd = io_open
        @closed = false
      end

      #
      # Opens an IO stream.
      #
      # @param [Array] arguments
      #   Additional arguments for the IO stream.
      #
      # @yield [io]
      #   The given block will be passed the newly created IO stream.
      #   When the block has returned, the IO object will be closed.
      #
      # @yieldparam [IO]
      #   The newly created IO stream.
      #
      # @since 0.4.0
      #
      def self.open(*arguments)
        io = self.new(*arguments)

        if block_given?
          value = yield(io)

          io.close
          return value
        else
          return io
        end
      end

      #
      # Determines if end-of-file has been reached.
      #
      # @return [Boolean]
      #   Specifies whether end-of-file has been reached.
      #
      # @since 0.4.0
      #
      def eof?
        @eof == true
      end

      #
      # Iterates over each block within the IO stream.
      #
      # @yield [block]
      #   The given block will be passed each block of data from the IO
      #   stream.
      #
      # @yieldparam [String] block
      #   A block of data from the IO stream.
      #
      # @return [Enumerator]
      #   If no block is given, an enumerator object will be returned.
      #
      # @since 0.4.0
      #
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

      #
      # Reads data from the IO stream.
      #
      # @param [Integer, nil] length
      #   The maximum amount of data to read. If `nil` is given, the entire
      #   IO stream will be read.
      #
      # @param [#<<] buffer
      #   The optional buffer to append the data to.
      #
      # @return [String]
      #   The data read from the IO stream.
      #
      # @since 0.4.0
      #
      def read(length=nil,buffer=nil)
        remaining = (length || (0.0 / 0))
        result = ''

        each_block do |block|
          if remaining < block.length
            result << block[0...remaining]
            append_buffer(block[remaining..-1])
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

      #
      # Reads partial data from the IO stream.
      #
      # @param [Integer] length
      #   The maximum amount of data to read.
      #
      # @param [#<<] buffer
      #   The optional buffer to append the data to.
      #
      # @return [String]
      #   The data read from the IO stream.
      #
      # @see #read
      #
      # @since 0.4.0
      #
      def readpartial(length,buffer=nil)
        read(length,buffer)
      end

      #
      # Reads a character from the IO stream.
      #
      # @return [Integer]
      #   A character from the IO stream.
      #
      # @since 0.4.0
      #
      def getc
        if (c = read(1))
          c.ord
        end
      end

      #
      # Un-reads a character from the IO stream, append it to the read
      # buffer.
      #
      # @param [Integer] byte
      #   The character to un-read.
      #
      # @return [nil]
      #   The character was appended to the read buffer.
      #
      # @since 0.4.0
      #
      def ungetc(byte)
        prepend_buffer(byte.chr)
        return nil
      end

      #
      # Reads a string from the IO stream.
      #
      # @param [String] separator
      #   The separator character that designates the end of the string
      #   being read.
      #
      # @return [String]
      #   The string from the IO stream.
      #
      # @since 0.4.0
      #
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

      #
      # Reads a character from the IO stream.
      #
      # @return [Integer]
      #   The character from the IO stream.
      #
      # @raise [EOFError]
      #   The end-of-file has been reached.
      #
      # @see #getc
      #
      # @since 0.4.0
      #
      def readchar
        unless (c = getc)
          raise(EOFError,"end of file reached",caller)
        end

        return c
      end

      #
      # Reads bytes from the IO stream.
      #
      # @param [Integer] n
      #   The number of bytes to read.
      #
      # @return [Array<Integer>]
      #   Bytes read from the IO stream.
      #
      # @raise [EOFError]
      #   The end-of-file has been reached.
      #
      # @since 0.4.0
      #
      def readbytes(n)
        unless (chunk = read(n))
          raise(EOFError,"end of file reached",caller)
        end

        return chunk.enum_for(:each_byte).to_a
      end

      #
      # Reads a line from the IO stream.
      #
      # @see #gts
      #
      # @param [String] separator
      #   The separator character that designates the end of the string
      #   being read.
      #
      # @return [String]
      #   The string from the IO stream.
      #
      # @raise [EOFError]
      #   The end-of-file has been reached.
      #
      # @since 0.4.0
      #
      def readline(separator=$/)
        unless (line = gets(separator))
          raise(EOFError,"end of file reached",caller)
        end

        return line
      end

      #
      # Iterates over each byte in the IO stream.
      #
      # @yield [byte]
      #   The given block will be passed each byte in the IO stream.
      #
      # @yieldparam [Integer] byte
      #   A byte from the IO stream.
      #
      # @return [Enumerator]
      #   If no block is given, an enumerator object will be returned.
      #
      # @since 0.4.0
      #
      def each_byte(&block)
        return enum_for(:each_byte) unless block

        each_block { |chunk| chunk.each_byte(&block) }
      end

      #
      # Iterates over each character in the IO stream.
      #
      # @yield [char]
      #   The given block will be passed each character in the IO stream.
      #
      # @yieldparam [String] char
      #   A character from the IO stream.
      #
      # @return [Enumerator]
      #   If no block is given, an enumerator object will be returned.
      #
      # @since 0.4.0
      #
      def each_char(&block)
        return enum_for(:each_char) unless block

        each_block { |chunk| chunk.each_char(&block) }
      end

      #
      # Iterates over each line in the IO stream.
      #
      # @yield [line]
      #   The given block will be passed each line in the IO stream.
      #
      # @yieldparam [String] line
      #   A line from the IO stream.
      #
      # @return [Enumerator]
      #   If no block is given, an enumerator object will be returned.
      #
      # @see #gets
      #
      # @since 0.4.0
      #
      def each_line(separator=$/)
        return enum_for(:each_line,separator) unless block_given?

        loop do
          begin
            line = gets(separator)
          rescue EOFError
            break
          end

          yield line
        end
      end

      #
      # Reads every line from the IO stream.
      #
      # @return [Array<String>]
      #   The lines in the IO stream.
      #
      # @see #gets
      #
      # @since 0.4.0
      #
      def readlines(separator=$/)
        enum_for(:each_line,separator).to_a
      end

      #
      # Writes data to the IO stream.
      #
      # @param [String] data
      #   The data to write.
      #
      # @return [Integer]
      #   The number of bytes written.
      #
      # @since 0.4.0
      #
      def write(data)
        io_write(data)
      end

      #
      # Writes a byte or a character to the IO stream.
      #
      # @param [String, Integer] data
      #   The byte or character to write.
      #
      # @return [String, Integer]
      #   The byte or character that was written.
      #
      # @since 0.4.0
      #
      def putc(data)
        char = unless data.kind_of?(String)
                 data.chr
               else
                 data
               end

        io_write(char)
        return data
      end

      #
      # Prints data to the IO stream.
      #
      # @param [Array] arguments
      #   The data to print to the IO stream.
      #
      # @return [nil]
      # 
      # @since 0.4.0
      #
      def print(*arguments)
        arguments.each { |data| io_write(data) }
        return nil
      end

      #
      # Prints data with new-line characters to the IO stream.
      #
      # @param [Array]
      #   The data to print to the IO stream.
      #
      # @return [nil]
      #
      # @since 0.4.0
      #
      def puts(*arguments)
        arguments.each { |data| io_write(data + $/) }
        return nil
      end

      #
      # Prints a formatted string to the IO stream.
      #
      # @param [String] format_string
      #   The format string to format the data.
      #
      # @param [Array] arguments
      #   The data to format.
      #
      # @return [nil]
      # 
      # @since 0.4.0
      #
      def printf(format_string,*arguments)
        io_write(format_string % arguments)
        return nil
      end

      #
      # Determines whether the IO stream is closed.
      #
      # @return [Boolean]
      #   Specifies whether the IO stream has been closed.
      #
      # @since 0.4.0
      #   
      def closed?
        @closed == true
      end

      #
      # Closes the IO stream.
      #
      # @since 0.4.0
      #
      def close
        io_close

        @fd = nil
        @closed = true
        return nil
      end

      #
      # The number of the file descriptor.
      #
      # @return [Integer, nil]
      #   The file descriptor, if it is an `Integer`.
      #
      def fileno
        @fd if @fd.kind_of?(Integer)
      end

      alias to_i fileno

      protected

      #
      # Clears the read buffer.
      #
      # @since 0.4.0
      #
      def clear_buffer!
        @buffer = nil
      end

      #
      # Determines if the read buffer is empty.
      #
      # @return [Boolean]
      #   Specifies whether the read buffer is empty.
      #
      # @since 0.4.0
      #
      def empty_buffer?
        @buffer.nil?
      end

      #
      # Reads data from the read buffer.
      #
      # @return [String]
      #   Data read from the buffer.
      #
      # @since 0.4.0
      #
      def read_buffer
        chunk = @buffer
        @pos += @buffer.length

        clear_buffer!
        return chunk
      end

      #
      # Prepends data to the front of the read buffer.
      #
      # @param [String] data
      #   The data to prepend.
      #
      # @since 0.4.0
      #
      def prepend_buffer(data)
        @buffer ||= ''
        @buffer.insert(0,data)
      end

      #
      # Appends data to the read buffer.
      #
      # @param [String] data
      #   The data to append.
      #
      # @since 0.4.0
      #
      def append_buffer(data)
        @pos -= data.length

        @buffer ||= ''
        @buffer << data
      end

      #
      # Place holder method used to open the IO stream.
      #
      # @since 0.4.0
      #
      def io_open
      end

      #
      # Place holder method used to read a block from the IO stream.
      #
      # @since 0.4.0
      #
      def io_read
      end

      #
      # Place holder method used to write data to the IO stream.
      #
      # @param [String] data
      #   The data to write to the IO stream.
      #
      # @since 0.4.0
      #
      def io_write(data)
        0
      end

      #
      # Place holder method used to close the IO stream.
      #
      # @since 0.4.0
      #
      def io_close
      end

    end
  end
end
