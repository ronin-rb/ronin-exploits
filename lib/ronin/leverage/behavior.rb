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

require 'ronin/model/types/description'
require 'ronin/model'

require 'dm-is-predefined'

module Ronin
  module Leverage
    class Behavior

      include Model

      is :predefined

      # Primary key of the behavior
      property :id, Serial

      # Name of the behavior
      property :name, String, :required => true, :unique => true

      # Description for the behavior
      property :description, Description, :required => true

      #
      # Converts the behavior to a String.
      #
      # @return [String]
      #   The name of the behavior.
      #
      def to_s
        self.name.to_s
      end

      #
      # Converts the behavior to a Symbol.
      #
      # @return [Symbol]
      #   The name of the behavior.
      #
      # @since 0.4.0
      #
      def to_sym
        self.name.to_sym
      end

      protected

      #
      # Defines a new builtin Behavior.
      #
      # @param [Symbol, String] name
      #   The name of the behavior to predefine.
      #
      # @param [String] description
      #   The description of the behavior.
      #
      # @example Defining a builtin Behavior
      #   Behavior.predefine :command_exec, "Arbitrary command execution"
      #
      # @example Retrieving a predefined behavior
      #   Behavior.command_exec
      #
      def self.predefine(name,description=nil)
        super(name,:name => name.to_s, :description => description)
      end

      # The ability to read memory
      predefine :mem_read, "The ability to read memory"

      # The ability to write to memory
      predefine :mem_write, "The ability to write to memory"

      # The ability to execute from memory
      predefine :mem_exec, "The ability to execute memory"

      # The ability to create files
      predefine :file_create, "Arbitrary file creation"

      # The ability to read files
      predefine :file_read, "The ability to read from a file"

      # The ability to write to a file
      predefine :file_write, "The ability to write to a file"

      # The ability to modify existing files
      predefine :file_modify, "The ability to modify an existing file"

      # The ability to change ownership on files
      predefine :file_ownership, "The ability to change ownership of an existing file"

      # The ability to change the modification time on files
      predefine :file_mtime, "The ability to change the modification timestamp of a file"

      # The ability to change the creation time on files
      predefine :file_ctime, "The ability to change the creation timestamp of a file"

      # The ability to create directories
      predefine :dir_create, "The ability to create a directory"

      # The ability to list the contents of directories
      predefine :dir_listing, "The ability to list the contents of a directory"

      # The ability to redirect socket connections
      predefine :socket_redirect, "The ability to redirect a socket's connection"

      # The ability to create socket connections
      predefine :socket_connect, "The ability to create a network socket"

      # The ability to listen on a socket
      predefine :socket_listen, "The ability to listen on a network socket"

      # The ability to read from a socket
      predefine :socket_read, "The ability to read from a network socket"

      # The ability to write to a socket
      predefine :socket_write, "The ability to write to a network socket"

      # The ability to execute code
      predefine :code_exec, "Arbitrary code execution"

      # The ability to execute commands
      predefine :command_exec, "Arbitrary command execution"

      # The ability to bypass authentication
      predefine :auth_bypass, "Authentication by-pass"

      # The ability to gain privileges
      predefine :gain_privs, "Gain privileges"

      # The ability to drop privileges
      predefine :drop_privs, "Drop privileges"

      # The ability to safely exit a running program
      predefine :exit_program, "Exit program"

      # The ability to crash a running program
      predefine :crash_program, "Crash program"

      # The ability to exhaust available memory
      predefine :exhaust_mem, "Exhaust freely available memory"

      # The ability to exhaust available disk space
      predefine :exhaust_disk, "Exhaust freely available disk-space"

      # The ability to exhaust available network bandwidth
      predefine :exhaust_bandwidth, "Exhaust available bandwidth"

      # The ability to exhaust CPU access
      predefine :exhaust_cpu, "Exhaust CPU performance"

    end
  end
end
