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

require 'ronin/ui/cli/model_command'

require 'ronin/payloads/payload'

module Ronin
  module UI
    module CommandLine
      module Commands
        class Payloads < ModelCommand

          desc 'Lists the available Payloads'

          model Ronin::Payloads::Payload

          query_option :named, :type => :string,
                               :aliases => '-n',
                               :banner => 'NAME'

          query_option :revision, :type => :string,
                                  :aliases => '-v',
                                  :banner => 'VERSION'

          query_option :describing, :stype => :string,
                                    :aliases => '-d',
                                    :banner => 'TEXT'

          query_option :licensed_under, :type => :string,
                                        :aliases => '-l',
                                        :banner => 'LICENSE'

          query_option :targeting_arch, :type => :string,
                                        :aliases => '-a',
                                        :banner => 'x86|x86_64|ia64|ppc|ppc64|sparc|sparc64|mips|mips_le|arm|arm_le'

          query_option :targeting_os, :type => :string,
                                      :aliases => '-o',
                                      :banner => 'Linux|FreeBSD|OpenBSD|NetBSD|OSX|Solaris|Windows|UNIX'

          class_option :verbose, :type => :boolean, :aliases => '-v'

          protected

          def print_resource(payload)
            unless options.verbose?
              puts "  #{payload}"
              return
            end

            attributes = payload.humanize_attributes(
              :exclude => [:description]
            )
            attributes['Arch'] = payload.arch if payload.arch
            attributes['OS'] = payload.os if payload.os

            print_hash attributes, :title => "Payload: #{payload}"

            indent do
              if payload.description
                puts "Description:\n\n"
                indent do
                  payload.description.each_line { |line| puts line }
                end
                puts "\n"
              end

              unless payload.authors.empty?
                payload.authors.each do |author|
                  print_hash author.humanize_attributes, :title => 'Author'
                end
              end

              unless payload.behaviors.empty?
                print_array payload.behaviors, :title => 'Exploits'
              end

              begin
                payload.load_code!
              rescue Exception => error
                print_exception error
              end

              unless payload.params.empty?
                print_array payload.params.values, :title => 'Parameters'
              end
            end
          end

        end
      end
    end
  end
end
