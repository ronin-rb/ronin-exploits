#
#--
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2009 Hal Brodigan (postmodern.mod3 at gmail.com)
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
#++
#

require 'ronin/model/targets_arch'
require 'ronin/model/targets_os'
require 'ronin/cacheable'

require 'parameters'

module Ronin
  module Payloads
    class Encoder

      include Parameters
      include Cacheable
      include Model::TargetsArch
      include Model::TargetsOS

      contextify :ronin_payload_encoder

      # Primary key of the payload
      property :id, Serial

      # Name of the specific payload
      property :name, String, :index => true

      # Description of the payload
      property :description, Text

      # Validations
      validates_present :name

      #
      # Finds all payloads with names like the specified _name_.
      #
      def self.named(name)
        self.all(:name.like => "%#{name}%")
      end

      #
      # Finds all payloads with descriptions like the specified
      # _description_.
      #
      def self.describing(description)
        self.all(:description.like => "%#{description}%")
      end

      #
      # Default method which will encode the specified _data_.
      # Returns the specified _data_ by default.
      #
      def call(data)
        data
      end

    end
  end
end
