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
    #
    # The {Command} class represents commands being executed on remote
    # systems. The {Command} class wraps around the `shell_exec` method
    # defined in the object leveraging shell access.
    #
    class Command < IO

      # The program name
      attr_reader :program

      # The arguments of the program
      attr_reader :arguments

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

        super()
      end

      #
      # Reopens the command.
      #
      # @param [String] program
      #   The new program to run.
      #
      # @param [Array] arguments
      #   The new arguments to run with.
      #
      # @return [Command]
      #   The new command.
      #
      # @since 0.4.0
      #
      def reopen(program,*arguments)
        close

        @program = program
        @arguments = arguments

        return open
      end

      #
      # Converts the command to a `String`.
      #
      # @return [String]
      #   The program name and arguments.
      #
      # @since 0.4.0
      #
      def to_s
        ([@program] + @arguments).join(' ')
      end

      #
      # Inspects the command.
      #
      # @return [String]
      #   The inspected command listing the program name and arguments.
      #
      # @since 0.4.0
      #
      def inspect
        "#<#{self.class}: #{self}>"
      end

      protected

      #
      # Executes and opens the command for reading.
      #
      # @return [Enumerator]
      #   The enumerator that wraps around `shell_exec`.
      #
      # @since 0.4.0
      #
      def io_open
        @leverage.enum_for(:shell_exec,@program,*@arguments)
      end

      #
      # Reads a line of output from the command.
      #
      # @return [String]
      #   A line of output.
      #
      # @since 0.4.0
      #
      def io_read
        begin
          @fd.next
        rescue StopIteration
          return nil
        end
      end

    end
  end
end
