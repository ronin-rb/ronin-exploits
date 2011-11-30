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

require 'ronin/ui/cli/script_command'
require 'ronin/payloads/payload'
require 'ronin/formatting/binary'

module Ronin
  module UI
    module CLI
      module Commands
        class Payload < ScriptCommand

          desc 'Builds the specified Payload'

          script_class Ronin::Payloads::Payload

          query_option :targeting_arch, :type => :string, :aliases => '-a'
          query_option :targeting_os, :type => :string, :aliases => '-o'

          class_option :host, :type => :string
          class_option :port, :type => :numeric
          class_option :local_host, :type => :string
          class_option :local_port, :type => :numeric

          class_option :print, :type    => :boolean,
                               :default => true,
                               :desc    => 'Prints the raw payload'
          class_option :string, :type    => :boolean,
                                :default => true,
                                :aliases => '-s',
                                :desc    => 'Prints the raw payload as a String'
          class_option :raw, :type    => :boolean,
                             :aliases => '-r',
                             :desc    => 'Prints the raw payload'
          class_option :hex, :type    => :boolean,
                             :aliases => '-x',
                             :desc    => 'Prints the raw payload in hex'

          class_option :deploy, :type    => :boolean,
                                :default => false,
                                :desc    => 'Deploys the Payload'

          class_option :shell_console, :type => :boolean, :default => false
          class_option :fs_console, :type => :boolean, :default => false

          argument :name, :type => :string, :required => false

          def execute
            # silence all output, if we are to print the built payload
            UI::Output.silent! if options.raw?

            @payload = load_script

            params = options[:params]
            params[:host] = options[:host] if options[:host]
            params[:port] = options[:port] if options[:port]
            params[:local_host] = options[:local_host] if options[:local_host]
            params[:local_port] = options[:local_port] if options[:local_port]

            begin
              # Build the payload
              @payload.build!(params)
            rescue Script::Exception,
                   Payloads::Exception => error
              print_error error.message
              exit -1
            end

            if options.print?
              print_payload!
            elsif options.deploy?
              deploy_payload!
            end
          end

          protected

          def print_payload!
            raw_payload = @payload.raw_payload

            unless options.console?
              if options.raw?
                # Write the raw payload
                write raw_payload
              elsif options.hex?
                # Prints the raw payload as a hex String
                puts raw_payload.hex_escape
              else
                # Prints the raw payload as a String
                puts raw_payload.dump
              end
            else
              print_info 'Starting the console with @payload set ...'
              print_info '  @payload.raw_payload  # for the raw payload.'
              print_info '  @payload.build!       # rebuilds the payload.'

              UI::Console.start(:payload => payload)
            end
          end

          def deploy_payload!
            begin
              @payload.deploy!
            rescue Script::TestFailed, Payloads::Exception => e
              print_exception(e)
              exit -1
            end

            if options.shell_console?
              @payload.shell.console
            elsif options.fs_console?
              @payload.fs.console
            elsif options.console?
              print_info 'Starting the console with @payload set ...'

              UI::Console.start(:payload => @payload)
            end

            @payload.evacuate!
          end

        end
      end
    end
  end
end
