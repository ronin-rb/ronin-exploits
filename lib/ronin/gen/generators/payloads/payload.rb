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

require 'ronin/gen/mixins/control_api'
require 'ronin/gen/file_generator'
require 'ronin/payloads/config'
require 'ronin/author'

module Ronin
  module Gen
    module Generators
      module Payloads
        #
        # Generates a new ronin payload file.
        #
        class Payload < FileGenerator

          include Mixins::ControlAPI

          # Default name to give the payload
          DEFAULT_NAME = 'Payload'

          # Default version to give the payload
          DEFAULT_VERSION = '0.1'

          # Default description to give the payload
          DEFAULT_DESCRIPTION = %{This is a payload.}

          class_option :helpers, :type => :array, :default => []
          class_option :name, :type => :string, :default => DEFAULT_NAME
          class_option :version, :type => :string, :default => DEFAULT_VERSION
          class_option :description, :type => :string, :default => DEFAULT_DESCRIPTION
          class_option :authors, :type => :array, :default => []
          class_option :arch, :type => :string
          class_option :os, :type => :string
          class_option :os_version, :type => :string
          class_option :control_methods, :type => :array, :default => []

          argument :path, :type => :string, :require => true

          #
          # Generate a basic payload.
          #
          # @since 0.3.0
          #
          def generate
            erb File.join('ronin','gen','payloads','payload.erb'),
                self.path
          end

        end
      end
    end
  end
end
