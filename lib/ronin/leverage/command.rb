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
    #
    # The {Command} class represents commands being executed on remote
    # systems. The {Command} class wraps around the `shell_exec` method
    # defined in the object leveraging shell access.
    #
    class Command

      include Enumerable

      #
      # Creates a new Command.
      #
      # @param [#shell_exec] leverage
      #   The object leveraging command execution.
      #
      # @param [String] program
      #   The program to run.
      #
      # @param [Array] arguments
      #   The arguments to run with.
      #
      # @raise [RuntimeError]
      #   The leveraging object does not define `shell_exec`.
      #
      # @since 0.4.0
      #
      def initialize(leverage,program,*arguments)
        unless leverage.respond_to?(:shell_exec)
          raise(RuntimeError,"#{leverage.inspect} must define shell_exec for #{self.class}",caller)
        end

        @leverage = leverage
        @program = program
        @arguments = arguments
      end

      #
      # Iterates over each line of the output from the command.
      #
      # @yield [line]
      #   The given block will be passed each line of output.
      #
      # @yieldparam [String] line
      #   A line of output from the command.
      #
      # @return [Enumerator]
      #   If no block is given, it will be returned an enumerator object.
      #
      # @since 0.4.0
      #
      def each_line(&block)
        return enum_for(:each_line) unless block

        @leverage.shell_exec(@program,*@arguments,&block)
      end

      alias lines each_line
      alias each each_line

      #
      # Iterates over each output byte from the command.
      #
      # @yield [byte]
      #   The given block will be passed each byte of output.
      #
      # @yieldparam [Integer] byte
      #   A byte of output from the command.
      #
      # @return [Enumerator]
      #   If no block is given, it will be returned an enumerator object.
      #
      # @since 0.4.0
      #
      def each_byte(&block)
        return enum_for(:each_byte) unless block

        each_line { |line| line.each_byte(&block) }
      end

      alias bytes each_byte

      #
      # Iterates over each output character from the command.
      #
      # @yield [char]
      #   The given block will be passed each output character.
      #
      # @yieldparam [String] char
      #   An output character from the command.
      #
      # @return [Enumerator]
      #   If no block is given, it will be returned an enumerator object.
      #
      # @since 0.4.0
      #
      def each_char
        return enum_for(:each_char) unless block_given?

        each_byte { |b| yield b.chr }
      end

      alias chars each_char

      #
      # Converts the output from the command to a String.
      #
      # @return [String]
      #   The full output from the command.
      #
      # @since 0.4.0
      #
      def to_s
        each_line.inject('') { |output,line| output << line }
      end

    end
  end
end
