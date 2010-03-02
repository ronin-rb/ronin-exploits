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
  module Control
    class Command

      # The command or program to run.
      attr_reader :command

      # Additional arguments to run with the command.
      attr_reader :arguments

      # Any environment variables to run with the command.
      attr_reader :env

      # The output from the command.
      attr_accessor :output

      #
      # Creates a new {Command} object.
      #
      # @param [String] command
      #   The command or program to run.
      #
      # @param [Array<String>] arguments
      #   Additional arguments to run with the command.
      #
      # @since 0.4.0
      #
      def initialize(command,*arguments)
        @command = command
        @arguments = arguments
        @env = {}

        @output = nil
      end

      #
      # Converts the command to a String.
      #
      # @return [String]
      #   The output from the command.
      #
      # @since 0.4.0
      #
      def to_s
        @output.to_s
      end

    end
  end
end
