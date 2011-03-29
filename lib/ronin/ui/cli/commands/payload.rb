#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2011 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/ui/cli/command'
require 'ronin/ui/console'
require 'ronin/payloads'
require 'ronin/database'

module Ronin
  module UI
    module CLI
      module Commands
        class Payload < Command

          desc 'Builds the specified Payload'
          class_option :params, :type => :hash,
                                :default => {},
                                :banner => 'NAME:VALUE ...',
                                :aliases => '-p'
          class_option :host, :type => :string
          class_option :port, :type => :numeric
          class_option :local_host, :type => :string
          class_option :local_port, :type => :numeric
          class_option :file, :type => :string, :aliases => '-f'
          class_option :describing, :type => :string, :aliases => '-d'
          class_option :version, :type => :string, :aliases => '-V'
          class_option :license, :type => :string, :aliases => '-l'
          class_option :arch, :type => :string, :aliases => '-a'
          class_option :os, :type => :string, :aliases => '-o'
          class_option :dump, :type => :boolean, :default => true
          class_option :raw, :type => :boolean, :aliases => '-r'
          class_option :deploy, :type => :boolean,
                                :default => false,
                                :aliases => '-D'
          class_option :console, :type => :boolean, :default => true
          class_option :shell_console, :type => :boolean, :default => false
          class_option :fs_console, :type => :boolean, :default => false
          argument :name, :type => :string, :required => false

          def execute
            UI::Output.silent = true if options.raw?
            Database.setup(options[:database])
            
            select_payload!

            params = options[:params]
            params[:host] = options[:host] if options[:host]
            params[:port] = options[:port] if options[:port]
            params[:local_host] = options[:local_host] if options[:local_host]
            params[:local_port] = options[:local_port] if options[:local_port]

            begin
              # Build the payload
              @payload.build!(params)
            rescue Payloads::Exception => e
              print_error(e.message)
              exit -1
            end

            if options.dump?
              dump_payload!
            elsif options.deploy?
              deploy_payload!
            end
          end

          protected

          def load_payload!
            @payload = Payloads::Payload.load_from(options[:file])
          end

          def find_payload!(name=nil)
            @payload = Payloads::Payload.load_first do |payloads|
              if name
                payloads = payloads.named(name)
              end

              if options[:describing]
                payloads = payloads.describing(options[:describing])
              end

              if options[:version]
                payloads = payloads.revision(options[:version])
              end

              if options[:license]
                payloads = payloads.licensed_under(options[:license])
              end

              if options[:arch]
                payloads = payloads.targeting_arch(options[:arch])
              end

              if options[:os]
                payloads = payloads.targeting_os(options[:os])
              end

              payloads
            end
          end

          def select_payload!
            # Load the payload
            if options[:file]
              load_payload!
            else
              find_payload!(name)
            end

            unless @payload
              print_error "Could not find the specified payload"
              exit -1
            end
          end

          def dump_payload!
            raw_payload = @payload.raw_payload

            unless options.console?
              if options.raw?
                # Write the raw payload
                STDOUT.write(raw_payload)
              else
                # Dump the built payload
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
            rescue Engine::VerificationFailed, Payloads::Exception => e
              print_error(e.message)
              exit -1
            end

            if options.shell_console?
              if @payload.leveraged?(:shell)
                @payload.shell.console
              else
                print_error "The payload does not leverage the shell"
              end
            elsif options.fs_console?
              if @payload.leveraged?(:fs)
                @payload.fs.console
              else
                print_error "The payload does not leverage the file system"
              end
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
