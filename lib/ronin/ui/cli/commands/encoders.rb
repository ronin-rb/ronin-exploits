#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2012 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/ui/cli/resources_command'
require 'ronin/encoders/encoder'

module Ronin
  module UI
    module CLI
      module Commands
        class Exploits < ResourcesCommand

          summary 'Lists available encoders'

          model Ronin::Encoders::Encoder

          query_option :named, :type  => String,
                               :flag  => '-n',
                               :usage => 'NAME'

          query_option :revision, :type  => String,
                                  :flag  => '-V',
                                  :usage => 'VERSION'

          query_option :describing, :type  => String,
                                    :flag  => '-d',
                                    :usage => 'TEXT'

          query_option :status, :type  => String,
                                :flag  => '-s',
                                :usage => 'potential|proven|weaponized'

          query_option :licensed_under, :type  => String,
                                        :flag  => '-l',
                                        :usage => 'LICENSE'

          option :verbose, :type => true,
                           :flag => '-v'

          protected

          def print_resource(encoder)
            unless verbose?
              puts "  #{encoder}"
              return
            end

            print_hash(
              encoder.humanize_attributes(:exclude => [:description]),
              :title => "Encoder: #{exploit}"
            )

            indent do
              if exploit.description
                puts "Description:\n\n"
                indent do
                  exploit.description.each_line { |line| puts line }
                end
                puts "\n"
              end

              unless exploit.authors.empty?
                exploit.authors.each do |author|
                  print_hash author.humanize_attributes, :title => 'Author'
                end
              end

              begin
                encoder.load_original!
              rescue Exception => error
                print_exception error
              end

              unless encoder.params.empty?
                print_array encoder.params.values, :title => 'Parameters'
              end
            end
          end

        end
      end
    end
  end
end
