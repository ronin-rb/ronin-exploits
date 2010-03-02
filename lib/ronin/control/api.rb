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

require 'ronin/control/exceptions/not_controlled'
require 'ronin/control/behavior'

module Ronin
  module Control
    module API
      #
      # Initializes the control API.
      #
      def initialize(*arguments,&block)
        @control_blocks = {}

        super(*arguments,&block)
      end

      #
      # The names of the supported control methods.
      #
      # @return [Array<Symbol>]
      #   The method names.
      #
      # @since 0.4.0
      #
      def API.control_methods
        Behavior.predefined_names
      end

      #
      # The names of the methods which control behaviors of a vulnerability
      # being exploited.
      #
      # @return [Array<Symbol>]
      #   The names of the methods available in the object.
      #
      def control_methods
        @control_blocks.keys
      end

      #
      # Reads memory at a given address.
      #
      # @param [Integer] address
      #   The address to read memory from.
      #
      # @since 0.4.0
      #
      def mem_read(address)
        control_behavior(:mem_read,address)
      end

      #
      # Writes data to a given memory address.
      #
      # @param [Integer] address
      #   The address to read memory from.
      #
      # @param [String] value
      #   The value to write.
      #
      # @since 0.4.0
      #
      def mem_write(address,value)
        control_behavior(:mem_write,address,value)
      end

      #
      # Executes memory at a given address.
      #
      # @param [Integer] address
      #   The address to start executing at.
      #
      # @since 0.4.0
      #
      def mem_exec(address)
        control_behavior(:mem_exec,address)
      end

      #
      # Creates a file.
      #
      # @param [String] path
      #   The path of the file to create.
      #
      # @since 0.4.0
      #
      def file_create(path)
        control_behavior(:file_create,path)
      end

      #
      # Reads a file.
      #
      # @param [String] path
      #   The path of the file to read.
      #
      # @since 0.4.0
      #
      def file_read(path)
        control_behavior(:file_read,path)
      end

      #
      # Writes data to a file.
      #
      # @param [String] path
      #   The path of the file.
      #
      # @param [String] data
      #   The data to write to the file.
      #
      # @since 0.4.0
      #
      def file_write(path,data)
        control_behavior(:file_write,path,data)
      end

      #
      # Modifies the contents of a file.
      #
      # @param [String] path
      #   The path of the file.
      #
      # @param [String] data
      #   The data to insert into the file.
      #
      # @since 0.4.0
      #
      def file_modify(path,data)
        control_behavior(:file_modify,path,data)
      end

      #
      # Changes the ownership of a file.
      #
      # @param [String] path
      #   The path of the file.
      #
      # @param [String] user
      #   The new owner of the file.
      #
      # @since 0.4.0
      #
      def file_ownership(path,user)
        control_behavior(:file_ownership,path,user)
      end

      #
      # Changes the modification timestamp of a file.
      #
      # @param [String] path
      #   The path of the file.
      #
      # @param [Time] timestamp
      #   The new modification timestamp of the file.
      #
      # @since 0.4.0
      #
      def file_mtime(path,timestamp)
        control_behavior(:file_mtime,path,timestamp)
      end

      #
      # Changes the creation timestamp of a file.
      #
      # @param [String] path
      #   The path of the file.
      #
      # @param [Time] timestamp
      #   The new creation timestamp of the file.
      #
      # @since 0.4.0
      #
      def file_ctime(path,timestamp)
        control_behavior(:file_ctime,path,timestamp)
      end

      #
      # Creates a directory.
      #
      # @param [String] path
      #   The path of the directory to create.
      #
      # @since 0.4.0
      #
      def dir_create(path)
        control_behavior(:dir_create,path)
      end

      #
      # Lists the contents of a directory.
      #
      # @param [String] path
      #   The path of the directory.
      #
      # @since 0.4.0
      #
      def dir_listing(path)
        control_behavior(:dir_listing,path)
      end

      #
      # Causes a socket to be redirected.
      #
      # @param [String] host
      #   The new host to connect to.
      #
      # @param [Integer] port
      #   The new port to connect to.
      #
      # @since 0.4.0
      #
      def socket_redirect(host,port)
        control_behavior(:socket_redirect,host,port)
      end

      #
      # Connects to a given host and port.
      #
      # @param [String] host
      #   The new host to connect to.
      #
      # @param [Integer] port
      #   The new port to connect to.
      #
      # @since 0.4.0
      #
      def socket_connect(host,port)
        control_behavior(:socket_connect,host,port)
      end

      #
      # Listens on a given port.
      #
      # @param [Integer] port
      #   The new port to listen on.
      #
      # @since 0.4.0
      #
      def socket_listen(port)
        control_behavior(:socket_listen,port)
      end

      #
      # Read a number of bytes from a socket.
      #
      # @param [Integer] num
      #   The number of bytes to read.
      #
      # @since 0.4.0
      #
      def socket_read(num)
        control_behavior(:socket_read,num)
      end

      #
      # Writes data to a socket.
      #
      # @param [String] data
      #   The data to write to the socket.
      #
      # @since 0.4.0
      #
      def socket_write(data)
        control_behavior(:socket_write,data)
      end

      #
      # Executes arbitrary code.
      #
      # @param [String] code
      #   The code to execute.
      #
      # @since 0.4.0
      #
      def code_exec(code)
        control_behavior(:code_exec,code)
      end

      #
      # Executes an arbitrary command.
      #
      # @param [String] program
      #   The path of the program to run.
      #
      # @param [Array<String>] arguments
      #   Additional arguments to run with the program.
      #
      # @since 0.4.0
      #
      def command_exec(program,*arguments)
        control_behavior(:code_exec,program,arguments)
      end

      #
      # Bypasses authentication.
      #
      # @since 0.4.0
      #
      def auth_bypass
        control_behavior(:auth_bypass)
      end

      #
      # Gains priviledges.
      #
      # @since 0.4.0
      #
      def gain_privs
        control_behavior(:gain_privs)
      end

      #
      # Drops priviledges to a specific user.
      #
      # @param [String] user
      #   The user to drop priviledges to.
      #
      # @since 0.4.0
      #
      def drop_privs(user)
        control_behavior(:gain_privs,user)
      end

      #
      # Causes the program to exit.
      #
      # @since 0.4.0
      #
      def exit_program
        control_behavior(:exit_program)
      end

      #
      # Causes the program to crash.
      #
      # @since 0.4.0
      #
      def crash_program
        control_behavior(:crash_program)
      end

      #
      # Exhausts all available memory.
      #
      # @since 0.4.0
      #
      def exhaust_mem
        control_behavior(:exhaust_mem)
      end

      #
      # Exhausts all available disk-space.
      #
      # @since 0.4.0
      #
      def exhaust_disk
        control_behavior(:exhaust_disk)
      end

      #
      # Exhausts all available bandwidth.
      #
      # @since 0.4.0
      #
      def exhaust_bandwidth
        control_behavior(:exhaust_bandwidth)
      end

      #
      # Exhausts all available CPU cycles.
      #
      # @since 0.4.0
      #
      def exhaust_cpu
        control_behavior(:exhaust_cpu)
      end

      protected

      #
      # Defines a control method.
      #
      # @param [Symbol] name
      #   The name of the control method.
      #
      # @yield [*args]
      #   The given block will be called when the control method is called.
      #
      # @since 0.4.0
      #
      def control_method(name,&block)
        name = name.to_sym

        if self.class.relationships.has_key?(:controlled_behaviors)
          if (behavior = Ronin::Control::Behavior.predefined_resource(name))
            self.controlled_behaviors.first_or_new(:behavior => behavior)
          end
        end

        @control_blocks[name] = block
        return self
      end

      #
      # Defines a control method for {#mem_read}.
      #
      # @yield [address]
      #   The given block will be called when {#mem_read} is called.
      #
      # @yieldparam [Integer] address
      #   The address to read memory from.
      #
      # @since 0.4.0
      #
      def control_mem_read(&block)
        control_method(:mem_read,&block)
      end

      #
      # Defines a control method for {#mem_write}.
      #
      # @yield [address,value]
      #   The given block will be called when {#mem_write} is called.
      #
      # @yieldparam [Integer] address
      #   The address to write memory from.
      #
      # @yieldparam [Object] data
      #   The data to write to the address.
      #
      # @since 0.4.0
      #
      def control_mem_write(&block)
        control_method(:mem_write,&block)
      end

      #
      # Defines a control method for {#mem_exec}.
      #
      # @yield [address]
      #   The given block will be called when {#mem_exec} is called.
      #
      # @yieldparam [Integer] address
      #   The address to begin executing from.
      #
      # @since 0.4.0
      #
      def control_mem_exec(&block)
        control_method(:mem_exec,&block)
      end

      #
      # Defines a control method for {#file_create}.
      #
      # @yield [path]
      #   The given block will be called when {#file_create} is called.
      #
      # @yieldparam [String] path
      #   The path of the file to create.
      #
      # @since 0.4.0
      #
      def control_file_create(&block)
        control_method(:file_create,&block)
      end

      #
      # Defines a control method for {#file_read}.
      #
      # @yield [path]
      #   The given block will be called when {#file_read} is called.
      #
      # @yieldparam [String] path
      #   The path of the file to read.
      #
      # @since 0.4.0
      #
      def control_file_read(&block)
        control_method(:file_read,&block)
      end

      #
      # Defines a control method for {#file_write}.
      #
      # @yield [path,data]
      #   The given block will be called when {#file_write} is called.
      #
      # @yieldparam [String] path
      #   The path of the file to write.
      #
      # @yieldparam [String] data
      #   The data to write.
      #
      # @since 0.4.0
      #
      def control_file_write(&block)
        control_method(:file_write,&block)
      end

      #
      # Defines a control method for {#file_modify}.
      #
      # @yield [path,data]
      #   The given block will be called when {#file_modify} is called.
      #
      # @yieldparam [String] path
      #   The path of the file to modify.
      #
      # @yieldparam [String] data
      #   The data to insert into the file.
      #
      # @since 0.4.0
      #
      def control_file_modify(&block)
        control_method(:file_modify,&block)
      end

      #
      # Defines a control method for {#file_ownership}.
      #
      # @yield [path,user]
      #   The given block will be called when {#file_ownership} is called.
      #
      # @yieldparam [String] path
      #   The path of the file.
      #
      # @yieldparam [String] user
      #   The new owner of the file.
      #
      # @since 0.4.0
      #
      def control_file_ownership(&block)
        control_method(:file_ownership,&block)
      end

      #
      # Defines a control method for {#file_mtime}.
      #
      # @yield [path,timestamp]
      #   The given block will be called when {#file_mtime} is called.
      #
      # @yieldparam [String] path
      #   The path of the file.
      #
      # @yieldparam [Time] timestamp
      #   The new modification timestamp of the file.
      #
      # @since 0.4.0
      #
      def control_file_mtime(&block)
        control_method(:file_mtime,&block)
      end

      #
      # Defines a control method for {#file_ctime}.
      #
      # @yield [path,timestamp]
      #   The given block will be called when {#file_ctime} is called.
      #
      # @yieldparam [String] path
      #   The path of the file.
      #
      # @yieldparam [Time] timestamp
      #   The new creation timestamp of the file.
      #
      # @since 0.4.0
      #
      def control_file_ctime(&block)
        control_method(:file_ctime,&block)
      end

      #
      # Defines a control method for {#dir_create}.
      #
      # @yield [path]
      #   The given block will be called when {#dir_create} is called.
      #
      # @yieldparam [String] path
      #   The path of the directory to create.
      #
      # @since 0.4.0
      #
      def control_dir_create(&block)
        control_method(:dir_create,&block)
      end

      #
      # Defines a control method for {#dir_listing}.
      #
      # @yield [path]
      #   The given block will be called when {#dir_listing} is called.
      #
      # @yieldparam [String] path
      #   The path of the directory.
      #
      # @since 0.4.0
      #
      def control_dir_listing(&block)
        control_method(:dir_listing,&block)
      end

      #
      # Defines a control method for {#socket_redirect}.
      #
      # @yield [host,port]
      #   The given block will be called when {#socket_redirect} is called.
      #
      # @yieldparam [String] host
      #   The new host to connect to.
      #
      # @yieldparam [Integer] port
      #   The new port to connect to.
      #
      # @since 0.4.0
      #
      def control_socket_redirect(&block)
        control_method(:socket_redirect,&block)
      end

      #
      # Defines a control method for {#socket_connect}.
      #
      # @yield [host,port]
      #   The given block will be called when {#socket_connect} is called.
      #
      # @yieldparam [String] host
      #   The host to connect to.
      #
      # @yieldparam [Integer] port
      #   The port to connect to.
      #
      # @since 0.4.0
      #
      def control_socket_connect(&block)
        control_method(:socket_connect,&block)
      end

      #
      # Defines a control method for {#socket_listen}.
      #
      # @yield [port]
      #   The given block will be called when {#socket_listen} is called.
      #
      # @yieldparam [Integer] port
      #   The port to listen on.
      #
      # @since 0.4.0
      #
      def control_socket_listen(&block)
        control_method(:socket_listen,&block)
      end

      #
      # Defines a control method for {#socket_read}.
      #
      # @yield [num_bytes]
      #   The given block will be called when {#socket_read} is called.
      #
      # @yieldparam [Integer] num_bytes
      #   The number of bytes to read.
      #
      # @since 0.4.0
      #
      def control_socket_read(&block)
        control_method(:socket_read,&block)
      end

      #
      # Defines a control method for {#socket_write}.
      #
      # @yield [data]
      #   The given block will be called when {#socket_write} is called.
      #
      # @yieldparam [String] data
      #   The data to write to the socket.
      #
      # @since 0.4.0
      #
      def control_socket_write(&block)
        control_method(:socket_write,&block)
      end

      #
      # Defines a control method for {#code_exec}.
      #
      # @yield [code]
      #   The given block will be called when {#code_exec} is called.
      #
      # @yieldparam [String] code
      #   The code to be executed.
      #
      # @since 0.4.0
      #
      def control_code_exec(&block)
        control_method(:code_exec,&block)
      end

      #
      # Defines a control method for {#command_exec}.
      #
      # @yield [program,*arguments]
      #   The given block will be called when {#command_exec} is called.
      #
      # @yieldparam [String] program
      #   The path of the program to be ran.
      #
      # @yieldparam [Array<String>] arguments
      #   Additional arguments to run the program with.
      #
      # @since 0.4.0
      #
      def control_command_exec(&block)
        control_method(:code_exec,&block)
      end

      #
      # Defines a control method for {#auth_bypass}.
      #
      # @yield []
      #   The given block will be called when {#auth_bypass} is called.
      #
      # @since 0.4.0
      #
      def control_auth_bypass(&block)
        control_method(:auth_bypass,&block)
      end

      #
      # Defines a control method for {#gain_privs}.
      #
      # @yield []
      #   The given block will be called when {#gain_privs} is called.
      #
      # @since 0.4.0
      #
      def control_gain_privs(&block)
        control_method(:gain_privs,&block)
      end

      #
      # Defines a control method for {#drop_privs}.
      #
      # @yield [user]
      #   The given block will be called when {#drop_privs} is called.
      #
      # @yieldparam [String] user
      #   The user to drop priviledges to.
      #
      # @since 0.4.0
      #
      def control_drop_privs(&block)
        control_method(:gain_privs,&block)
      end

      #
      # Defines a control method for {#exit_program}.
      #
      # @yield []
      #   The given block will be called when {#exit_program} is called.
      #
      # @since 0.4.0
      #
      def control_exit_program(&block)
        control_method(:exit_program,&block)
      end

      #
      # Defines a control method for {#crash_program}.
      #
      # @yield []
      #   The given block will be called when {#crash_program} is called.
      #
      # @since 0.4.0
      #
      def control_crash_program(&block)
        control_method(:crash_program,&block)
      end

      #
      # Defines a control method for {#exhaust_mem}.
      #
      # @yield []
      #   The given block will be called when {#exhaust_mem} is called.
      #
      # @since 0.4.0
      #
      def control_exhaust_mem(&block)
        control_method(:exhaust_mem,&block)
      end

      #
      # Defines a control method for {#exhaust_disk}.
      #
      # @yield []
      #   The given block will be called when {#exhaust_disk} is called.
      #
      # @since 0.4.0
      #
      def control_exhaust_disk(&block)
        control_method(:exhaust_disk,&block)
      end

      #
      # Defines a control method for {#exhaust_bandwidth}.
      #
      # @yield []
      #   The given block will be called when {#exhaust_bandwidth} is called.
      #
      # @since 0.4.0
      #
      def control_exhaust_bandwidth(&block)
        control_method(:exhaust_bandwidth,&block)
      end

      #
      # Defines a control method for {#exhaust_cpu}.
      #
      # @yield []
      #   The given block will be called when {#exhaust_cpu} is called.
      #
      # @since 0.4.0
      #
      def control_exhaust_cpu(&block)
        control_method(:exhaust_cpu,&block)
      end

      #
      # Calls a control method for the given behavior.
      #
      # @param [Symbol] name
      #   The name of the behavior to be controlled.
      #
      # @param [Array] arguments
      #   Additional arguments to pass to the control method.
      #
      # @return [Object]
      #   Result of the control method.
      #
      # @raise [NotControlled]
      #   The behavior does not have a corresponding control method.
      #
      # @since 0.4.0
      #
      def control_behavior(name,*arguments)
        name = name.to_sym

        unless @control_blocks.has_key?(name)
          raise(NotControlled,"the #{name} behavior is not controlled",caller)
        end

        return @control_blocks[name].call(*arguments)
      end
    end
  end
end
