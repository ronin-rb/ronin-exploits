#
# ronin-exploits - A Ruby library for ronin-rb that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2013 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-exploits.
#
# ronin-exploits is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-exploits is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ronin-exploits.  If not, see <https://www.gnu.org/licenses/>
#

module Ronin
  module PostExploitation
    #
    # The {IO} module provides an API for communicating with controlled
    # resources, that is still compatible with the standard
    # [IO](http://rubydoc.info/docs/ruby-core/1.9.2/IO) class.
    #
    # To utilize the {IO} class, simply extend it and define either
    # {#io_read} and/or {#io_write}, to handle the reading and writting
    # of data.
    #
    # The {#io_open} method handles optionally opening and assigning the
    # file descriptor for the IO stream. The {#io_close} method handles
    # optionally closing the IO stream.
    #
    # @since 1.0.0
    #
    module IO

      include Enumerable
      include File::Constants

      # The position within the IO stream
      attr_reader :pos

      # The end-of-file indicator
      attr_reader :eof

      # The file descriptor
      attr_reader :fd

      alias tell pos

      #
      # Determines if end-of-file has been reached.
      #
      # @return [Boolean]
      #   Specifies whether end-of-file has been reached.
      #
      # @since 1.0.0
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
      # @raise [IOError]
      #   The stream is closed for reading.
      #
      # @since 1.0.0
      #
      def each_block
        return enum_for(__method__) unless block_given?

        unless @read
          raise(IOError,"closed for reading")
        end

        # read from the buffer first
        yield read_buffer unless empty_buffer?

        until @eof
          begin
            # no data currently available, sleep and retry
            until (block = io_read)
              sleep(1)
            end
          rescue EOFError
            break
          end

          unless block.empty?
            @pos += block.length
            yield block
          else
            # short read
            @eof = true
          end
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

      alias sysread read
      alias read_nonblock read

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
      def readpartial(length,buffer=nil)
        read(length,buffer)
      end

      if RUBY_VERSION > '1.9.'
        #
        # Reads a byte from the IO stream.
        #
        # @return [Integer]
        #   A byte from the IO stream.
        #
        # @note
        #   Only available on Ruby > 1.9.
        #
        def getbyte
          if (c = read(1))
            c.bytes.first
          end
        end
      end

      if RUBY_VERSION < '1.9.'
        #
        # Reads a character from the IO stream.
        #
        # @return [Integer]
        #   A character from the IO stream.
        #
        def getc
          if (c = read(1))
            c[0]
          end
        end
      else
        #
        # Reads a character from the IO stream.
        #
        # @return [String]
        #   A character from the IO stream.
        #
        def getc
          read(1)
        end
      end

      if RUBY_VERSION > '1.9.'
        #
        # Un-reads a byte from the IO stream, append it to the read buffer.
        #
        # @param [Integer, String] byte
        #   The byte to un-read.
        #
        # @return [nil]
        #   The byte was appended to the read buffer.
        #
        # @note
        #   Only available on Ruby > 1.9.
        #
        def ungetbyte(byte)
          byte = case byte
                 when Integer then byte.chr
                 else              byte.to_s
                 end

          prepend_buffer(byte)
          return nil
        end
      end

      if RUBY_VERSION < '1.9.'
        #
        # Un-reads a character from the IO stream, append it to the
        # read buffer.
        #
        # @param [Integer] char
        #   The character to un-read.
        #
        # @return [nil]
        #   The character was appended to the read buffer.
        #
        def ungetc(char)
          prepend_buffer(char.chr)
          return nil
        end
      else
        #
        # Un-reads a character from the IO stream, append it to the
        # read buffer.
        #
        # @param [#to_s] char
        #   The character to un-read.
        #
        # @return [nil]
        #   The character was appended to the read buffer.
        #
        def ungetc(char)
          prepend_buffer(char.to_s)
          return nil
        end
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
      def gets(separator=$/)
        # increment the line number
        @lineno += 1

        # if no separator is given, read everything
        return read if separator.nil?

        line = ''

        while (c = read(1))
          line << c

          break if c == separator # separator reached
        end

        if line.empty?
          # a line should atleast contain the separator
          raise(EOFError,"end of file reached")
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
      def readchar
        unless (c = getc)
          raise(EOFError,"end of file reached")
        end

        return c
      end

      #
      # Reads a byte from the IO stream.
      #
      # @return [Integer]
      #   A byte from the IO stream.
      #
      # @raise [EOFError]
      #   The end-of-file has been reached.
      #
      def readbyte
        unless (c = read(1))
          raise(EOFError,"end of file reached")
        end

        return c.bytes.first
      end

      #
      # Reads a line from the IO stream.
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
      # @see #gets
      #
      def readline(separator=$/)
        unless (line = gets(separator))
          raise(EOFError,"end of file reached")
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
      def each_byte(&block)
        return enum_for(__method__) unless block

        each_block { |chunk| chunk.each_byte(&block) }
      end

      alias bytes each_byte

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
      def each_char(&block)
        return enum_for(__method__) unless block

        each_block { |chunk| chunk.each_char(&block) }
      end

      alias chars each_char

      if RUBY_VERSION > '1.9.'
        #
        # Passes the Integer ordinal of each character in the stream.
        #
        # @yield [ord]
        #   The given block will be passed each codepoint.
        #
        # @yieldparam [String] ord
        #   The ordinal of a character from the stream.
        #
        # @return [Enumerator]
        #   If no block is given an Enumerator object will be returned.
        #
        # @note
        #   Only available on Ruby > 1.9.
        #
        def each_codepoint
          return enum_for(__method__) unless block_given?

          each_char { |c| yield c.ord }
        end

        alias codepoints each_codepoint
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
      def each_line(separator=$/)
        return enum_for(__method__,separator) unless block_given?

        loop do
          begin
            line = gets(separator)
          rescue EOFError
            break
          end

          yield line
        end
      end

      alias each each_line
      alias lines each_line

      #
      # Reads every line from the IO stream.
      #
      # @return [Array<String>]
      #   The lines in the IO stream.
      #
      # @see #gets
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
      # @raise [IOError]
      #   The stream is closed for writting.
      #
      def write(data)
        unless @write
          raise(IOError,"closed for writting")
        end

        io_write(data.to_s) if @write
      end

      alias syswrite write
      alias write_nonblock write

      #
      # Writes a byte or a character to the IO stream.
      #
      # @param [String, Integer] data
      #   The byte or character to write.
      #
      # @return [String, Integer]
      #   The byte or character that was written.
      #
      def putc(data)
        char = case data
               when String then data.chr
               else             data
               end

        write(char)
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
      def print(*arguments)
        arguments.each { |data| write(data) }
        return nil
      end

      #
      # Prints data with new-line characters to the IO stream.
      #
      # @param [Array] arguments
      #   The data to print to the IO stream.
      #
      # @return [nil]
      #
      def puts(*arguments)
        arguments.each { |data| write("#{data}#{$/}") }
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
      def printf(format_string,*arguments)
        write(format_string % arguments)
        return nil
      end

      alias << write

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

      #
      # @raise [NotImplementedError]
      #   {#pid} is not implemented.
      #
      def pid
        raise(NotImplementedError,"#{self.class}#pid is not implemented")
      end

      #
      # @raise [NotImplementedError]
      #   {#stat} is not implemented.
      #
      def stat
        raise(NotImplementedError,"#{self.class}#stat is not implemented")
      end

      #
      # @return [false]
      #
      # @note
      #   For compatibility with
      #   [IO](http://rubydoc.info/docs/ruby-core/1.8.7/IO).
      #
      def isatty
        false
      end

      #
      # @see #isatty
      #
      def tty?
        isatty
      end

      #
      # @raise [NotImplementedError]
      #   {#seek} is not implemented.
      #
      def seek(new_pos,whence=SEEK_SET)
        raise(NotImplementedError,"#{self.class}#seek is not implemented")
      end

      #
      # @see #seek
      #
      def sysseek(offset,whence=SEEK_SET)
        seek(new_pos,whence)
      end

      #
      # @see #seek
      #
      def pos=(new_pos)
        seek(new_pos,SEEK_SET)
      end

      #
      # The current line-number (how many times {#gets} has been called).
      #
      # @return [Integer]
      #   The current line-number.
      #
      # @raise [IOError]
      #   The stream was not opened for reading.
      #
      def lineno
        unless @read
          raise(IOError,"not opened for reading")
        end

        return @lineno
      end

      #
      # Manually sets the current line-number.
      #
      # @param [Integer] number
      #   The new line-number.
      #
      # @return [Integer]
      #   The new line-number.
      #
      # @raise [IOError]
      #   The stream was not opened for reading.
      #
      def lineno=(number)
        unless @read
          raise(IOError,"not opened for reading")
        end

        return @lineno = number.to_i
      end

      #
      # @return [IO]
      #
      # @see #seek
      #
      # @note
      #   For compatibility with
      #   [IO](http://rubydoc.info/docs/ruby-core/1.8.7/IO).
      #
      def rewind
        @lineno = 0
        seek(0,SEEK_SET)
      end

      #
      # @return [IO]
      #
      # @note
      #   For compatibility with
      #   [IO](http://rubydoc.info/docs/ruby-core/1.8.7/IO).
      #
      def binmode
        @binmode = true
        return self
      end

      #
      # @return [Boolean]
      #
      # @note
      #   For compatibility with
      #   [IO](http://rubydoc.info/docs/ruby-core/1.8.7/IO).
      #
      def binmode?
        @binmode == true
      end

      if RUBY_VERSION > '1.9.'
        #
        # @return [IO]
        #
        # @note
        #   For compatibility with
        #   [IO](http://rubydoc.info/docs/ruby-core/1.9.2/IO).
        #
        def autoclose=(mode)
          self
        end

        #
        # @return [true]
        #
        # @note
        #   For compatibility with
        #   [IO](http://rubydoc.info/docs/ruby-core/1.9.2/IO).
        #
        def autoclose?
          true
        end

        #
        # @return [IO]
        #
        # @note
        #   For compatibility with
        #   [IO](http://rubydoc.info/docs/ruby-core/1.9.2/IO).
        #
        def close_on_exec=(mode)
          self
        end

        #
        # @return [true]
        #
        # @note
        #   For compatibility with
        #   [IO](http://rubydoc.info/docs/ruby-core/1.9.2/IO).
        #
        def close_on_exec?
          true
        end
      end

      #
      # @raise [NotImplementedError]
      #   {#ioctl} was not implemented in {IO}.
      #
      def ioctl(command,argument)
        raise(NotImplementedError,"#{self.class}#ioctl was not implemented")
      end

      #
      # @raise [NotImplementedError]
      #   {#fcntl} was not implemented in {IO}.
      #
      def fcntl(command,argument)
        raise(NotImplementedError,"#{self.class}#fcntl was not implemented")
      end

      #
      # @return [0]
      #
      # @note
      #   For compatibility with
      #   [IO](http://rubydoc.info/docs/ruby-core/1.8.7/IO).
      #
      def fsync
        fflush
        return 0
      end

      alias fdatasync fsync

      #
      # @return [true]
      #   Returns `true` for compatibility with
      #   [IO](http://rubydoc.info/docs/ruby-core/1.8.7/IO).
      #
      def sync
        true
      end

      #
      # @param [Boolean] mode
      #   The sync mode.
      #
      # @return [Boolean]
      #   Returns the sync mode, for compatibility with
      #   [IO](http://rubydoc.info/docs/ruby-core/1.8.7/IO).
      #
      def sync=(mode)
        mode
      end

      #
      # @return [IO]
      #
      # @note
      #   For compatibility with
      #   [IO](http://rubydoc.info/docs/ruby-core/1.8.7/IO).
      #
      def flush
        self
      end

      #
      # @raise [NotImplementedError]
      #   {#reopen} is not implemented.
      #
      def reopen(*arguments)
        raise(NotImplementedError,"#{self.class}#reopen is not implemented")
      end
      
      #
      # Closes the read end of a duplex IO stream.
      #
      def close_read
        if @write then @read = false
        else           close
        end

        return nil
      end

      #
      # Closes the write end of a duplex IO stream.
      #
      def close_write
        if @read then @write = false
        else          close
        end

        return nil
      end

      #
      # Determines whether the IO stream is closed.
      #
      # @return [Boolean]
      #   Specifies whether the IO stream has been closed.
      #
      def closed?
        @closed == true
      end

      #
      # Closes the IO stream.
      #
      def close
        io_close

        @fd = nil

        @read   = false
        @write  = false
        @closed = true
        return nil
      end

      #
      # Inspects the IO stream.
      #
      # @return [String]
      #   The inspected IO stream.
      #
      def inspect
        "#<#{self.class}: #{@fd.inspect if @fd}>"
      end

      protected

      #
      # Clears the read buffer.
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
      def empty_buffer?
        @buffer.nil?
      end

      #
      # Reads data from the read buffer.
      #
      # @return [String]
      #   Data read from the buffer.
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
      def append_buffer(data)
        @pos -= data.length

        @buffer ||= ''
        @buffer << data
      end

      #
      # Opens the IO stream.
      #
      # @return [IO]
      #   The opened IO stream.
      #
      def open
        @pos = 0
        @eof = false

        clear_buffer!

        @fd = io_open
        @closed = false
        return self
      end

      #
      # @return [IO]
      #
      # @note
      #   For compatibility with
      #   [IO](http://rubydoc.info/docs/ruby-core/1.8.7/IO).
      #
      def to_io
        self
      end

      protected

      #
      # Initializes the IO stream.
      #
      def io_initialize
        @lineno = 0

        @read   = true
        @write  = true
        @closed = true

        open
      end

      #
      # Place holder method used to open the IO stream.
      #
      # @return [fd]
      #   The abstract file-descriptor that represents the stream.
      #
      # @abstract
      #
      def io_open
      end

      #
      # Place holder method used to read a block from the IO stream.
      #
      # @return [String]
      #   Available data to be read.
      #
      # @raise [EOFError]
      #   The end of the stream has been reached.
      #
      # @abstract
      #
      def io_read
      end

      #
      # Place holder method used to write data to the IO stream.
      #
      # @param [String] data
      #   The data to write to the IO stream.
      #
      # @abstract
      #
      def io_write(data)
        0
      end

      #
      # Place holder method used to close the IO stream.
      #
      # @abstract
      #
      def io_close
      end

    end
  end
end
