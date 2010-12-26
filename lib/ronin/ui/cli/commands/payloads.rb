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

require 'ronin/ui/cli/command'

require 'ronin/payloads'
require 'ronin/database'

module Ronin
  module UI
    module CommandLine
      module Commands
        class Payloads < Command

          desc 'Lists the available Payloads'
          class_option :name, :type => :string, :aliases => '-n'
          class_option :version, :type => :string, :aliases => '-v'
          class_option :describing, :stype => :string, :aliases => '-d'
          class_option :license, :type => :string, :aliases => '-l'
          class_option :arch, :type => :string, :aliases => '-a'
          class_option :os, :type => :string, :aliases => '-o'
          class_option :verbose, :type => :boolean, :aliases => '-v'

          def execute
            Database.setup(options[:database])

            payloads = Ronin::Payloads::Payload.all

            if options[:name]
              payloads = payloads.named(options[:name])
            end

            if options[:version]
              payloads = payloads.revision(options[:version])
            end

            if options[:describing]
              payloads = payloads.describing(options[:describing])
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

            if payloads.empty?
              print_error "Could not find similar payloads"
              exit -1
            end

            if options.verbose?
              payloads.each { |payload| print_payload(payload) }
            else
              indent do
                payloads.each { |payload| puts payload }
              end
            end
          end

          protected

          def print_payload(payload)
            attributes = payload.humanize_attributes(
              :exclude => [:description]
            )
            attributes['Arch'] = payload.arch if payload.arch
            attributes['OS'] = payload.os if payload.os

            print_hash(attributes, :title => "Payload: #{payload}")

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
                  print_hash(author.humanize_attributes, :title => 'Author')
                end
              end

              unless payload.behaviors.empty?
                print_array(payload.behaviors, :title => 'Exploits')
              end

              begin
                payload.load_original!
              rescue Exception => e
                print_exception e
              end

              unless payload.params.empty?
                print_array(payload.params.values, :title => 'Parameters')
              end
            end
          end

        end
      end
    end
  end
end
