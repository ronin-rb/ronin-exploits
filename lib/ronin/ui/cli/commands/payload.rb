#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2013 Hal Brodigan (postmodern.mod3 at gmail.com)
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

          summary 'Builds the specified Payload'

          script_class Ronin::Payloads::Payload

          query_option :targeting_arch, type:  String,
                                        flag:  '-a',
                                        usage: 'ARCH'

          query_option :targeting_os, type:  String,
                                      flag:  '-o',
                                      usage: 'OS'

          option :print, type:        true,
                         default:     true,
                         description: 'Prints the raw payload'

          option :string, type:        true,
                          default:     true,
                          flag:        '-s',
                          description: 'Prints the raw payload as a String'

          option :raw, type:        true,
                       flag:        '-r',
                       description: 'Prints the raw payload'

          option :hex, type:        true,
                       flag:        '-x',
                       description: 'Prints the raw payload in hex'

          option :deploy, type:        true,
                          description: 'Deploys the Payload'

          option :shell, type: true
          option :fs,    type: true

          #
          # Sets up the Payload command.
          #
          def setup
            super

            # silence all output, if we are to print the built payload
            UI::Output.silent! if raw?
          end

          #
          # Builds and optionally deploys the loaded payload.
          #
          def execute
            begin
              # Build the payload
              @payload.build!
            rescue Behaviors::Exception,
                   Payloads:Exception: error
              print_error error.message
              exit -1
            end

            if deploy?
              deploy_payload!
            elsif print?
              print_payload!
            end
          end

          protected

          #
          # Prints the built payload.
          #
          def print_payload
            raw_payload = @payload.raw_payload

            if raw?
              # Write the raw payload
              write raw_payload
            elsif hex?
              # Prints the raw payload as a hex String
              puts raw_payload.hex_escape
            else
              # Prints the raw payload as a String
              puts raw_payload.dump
            end
          end

          #
          # Deploys the built payload.
          #
          def deploy_payload
            begin
              @payload.deploy!
            rescue Behaviors::TestFailed, Payloads::Exception => e
              print_exception(e)
              exit -1
            end

            if shell?      then @payload.shell.console
            elsif fs?      then @payload.fs.console
            elsif console? then UI::Console.start(@payload)
            end

            @payload.evacuate!
          end

        end
      end
    end
  end
end
