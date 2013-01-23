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
require 'ronin/payloads/payload'

module Ronin
  module UI
    module CLI
      module Commands
        class Payloads < ResourcesCommand

          summary 'Lists the available Payloads'

          model Ronin::Payloads::Payload

          query_option :named, type:  String,
                               flag:  '-n',
                               usage: 'NAME'

          query_option :revision, type:  String,
                                  flag:  '-v',
                                  usage: 'VERSION'

          query_option :describing, type:  String,
                                    flag:  '-d',
                                    usage: 'TEXT'

          query_option :licensed_under, type:  String,
                                        flag:  '-l',
                                        usage: 'LICENSE'

          query_option :targeting_arch, type:  String,
                                        flag:  '-a',
                                        usage: 'x86|x86_64|ia64|ppc|ppc64|sparc|sparc64|mips|mips_le|arm|arm_le'

          query_option :targeting_os, type:  String,
                                      flag:  '-o',
                                      usage: 'Linux|FreeBSD|OpenBSD|NetBSD|OSX|Solaris|Windows|UNIX'

          protected

          def print_resource(payload)
            unless verbose?
              puts "  #{payload}"
              return
            end

            print_section "Payload: #{payload}" do
              puts "Name: #{payload.name}"
              puts "Version: #{payload.version}"
              puts "Type: #{payload.type}" if verbose?
              puts "Status: #{payload.status}"
              puts "Released: #{payload.released}"
              puts "Reported: #{payload.reported}"
              puts "License: #{payload.license}" if payload.license
              puts "Arch: #{payload.arch}"       if payload.arch
              puts "OS: #{payload.os}"           if payload.os

              spacer

              if payload.description
                puts "Description:"
                spacer

                indent do
                  payload.description.each_line { |line| puts line }
                end

                spacer
              end

              unless payload.authors.empty?
                print_section "Authors" do
                  payload.authors.each do |author|
                    payload.authors.each { |author| puts author }
                  end
                end
              end

              begin
                payload.load_script!
              rescue Exception => error
                print_exception error
              end

              unless payload.params.empty?
                print_array payload.params.values, title: 'Parameters'
              end
            end
          end

        end
      end
    end
  end
end
