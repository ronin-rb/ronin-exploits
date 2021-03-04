#
# ronin-exploits - A Ruby library for ronin-rb that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2013 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-exploits.
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
# along with Ronin.  If not, see <https://www.gnu.org/licenses/>
#

require 'ronin/ui/cli/script_command'
require 'ronin/encoders'

module Ronin
  module UI
    module CLI
      module Commands
        #
        # @since 1.0.0
        #
        class Encoder < ScriptCommand

          summary 'Encodes data uses an Encoder'

          script_class Ronin::Encoders::Encoder

          # encoder options
          option :input, type:  String,
                         flag:  '-I',
                         usage: 'DATA'

          option :input_file, type:  String,
                              flag:  '-i',
                              usage: 'FILE'

          option :output, type:  String,
                          flag:  '-o',
                          usage: 'FILE'

          option :raw, type: true,
                       flag: '-r'

          #
          # Sets up the Encoder command.
          #
          def setup
            super

            # silence all output, if we are to print the raw data
            UI::Output.silent! if raw?
          end

          #
          # Runs the input data through the encoder.
          #
          def execute
            unless (@encoder = load_script)
              print_error "Could not find the specified encoder"
              exit -1
            end

            open_input do |input|
              encoded = begin
                          @encoder.encode(input)
                        rescue Behaviors::Exception => e
                          print_exception(e)
                          exit -1
                        end

              open_output do |output|
                if options.raw?
                  output.write(encoded)
                else
                  output.puts(encoded.inspect)
                end
              end
            end
          end

          protected

          #
          # Opens the input stream and reads the data.
          #
          # @yield [data]
          #   The input data will be passed to the block.
          #
          # @yield [String] data
          #   The data read from the input stream.
          #
          def open_input
            if @input
              yield @input
            elsif @input_file
              File.open(@input_file,'rb') do |file|
                yield file.read
              end
            else
              yield STDIN.read
            end
          end

          #
          # Opens the output stream.
          #
          # @yield [output]
          #   The block will be passed the opened output stream.
          #
          # @yield [IO] output
          #   The output stream.
          #
          def open_output(&block)
            if @output
              File.open(@output,'wb',&block)
            else
              yield STDOUT
            end
          end

        end
      end
    end
  end
end
