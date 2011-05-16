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

require 'ronin/ui/cli/script_command'
require 'ronin/encoders'

module Ronin
  module UI
    module CLI
      module Commands
        class Encoder < ScriptCommand

          desc 'Encodes data uses an Encoder'

          script_class Ronin::Encoders::Encoder

          # encoder options
          class_option :input, :type => :string,
                               :aliases => '-I',
                               :banner => 'DATA'

          class_option :input_file, :type => :string,
                                    :aliases => '-i',
                                    :banner => 'FILE'

          class_option :output, :type => :string,
                                :aliases => '-o',
                                :banner => 'FILE'

          class_option :raw, :type => :boolean,
                             :default => false,
                             :aliases => '-r'

          #
          # Runs the input data through the encoder.
          #
          # @since 1.0.0
          #
          def execute
            # silence all output, if we are to print the raw data
            UI::Output.silent! if options.raw?

            unless (@encoder = load_script)
              print_error "Could not find the specified encoder"
              exit -1
            end

            @encoder.params = options[:params]

            open_input do |input|
              encoded = begin
                          @encoder.encode(input)
                        rescue Script::Exception => error
                          print_exception error
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
          # @since 1.0.0
          #
          def open_input
            if options[:input]
              yield options[:input]
            elsif options[:input_file]
              File.open(options[:input_file],'rb') do |file|
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
          # @since 1.0.0
          #
          def open_output(&block)
            if options[:output]
              File.open(options[:output],'wb',&block)
            else
              yield STDOUT
            end
          end

        end
      end
    end
  end
end
