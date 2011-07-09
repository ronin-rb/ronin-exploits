#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2011 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/payloads/payload'

module Ronin
  module Payloads
    #
    # The {HasPayload} module allows another class to be coupled with a
    # {Payload}. The module provides methods for loading payloads
    # from the database or from a file.
    #
    module HasPayload
      # The payload being used
      attr_accessor :payload

      #
      # Initializes the default payload.
      #
      # @param [Hash] attributes
      #   Additiona attributes.
      #
      # @since 1.0.0
      #
      def initialize(attributes={})
        super(attributes)

        self.payload = default_payload
      end

      #
      # The default payload to use, if no other payload has been selected.
      #
      # @return [Payload]
      #   The default payload.
      #
      # @since 1.0.0
      #
      def default_payload
      end

      #
      # Specifies that the {Payload} class will be used when searching for
      # compatible payloads.
      #
      # @return [Class]
      #   Returns the {Payload} class.
      #
      # @since 0.3.0
      #
      def use_payload_class
        Ronin::Payloads::Payload
      end

      #
      # Selects and uses a new payload.
      #
      # @param [Hash] query
      #   Query options to use when selecting the payload.
      #
      # @return [Payload, nil]
      #   The new payload, or `nil` if no payload was found.
      #
      # @since 0.3.0
      #
      def use_payload!(query={})
        self.payload = use_payload_class.load_first(query)
      end

      #
      # Loads and uses a new payload from a given path.
      #
      # @param [String] path
      #   The path to load the payload from.
      #
      # @return [Payload, nil]
      #   The new payload, or `nil` if no payload was found.
      #
      # @since 0.3.0
      #
      def use_payload_from!(path)
        self.payload = use_payload_class.load_from(path)
      end

      protected

      #
      # Relays missing method calls to the payload, if the payload inherits
      # from {Payload}.
      #
      # @since 0.3.0
      #
      def method_missing(name,*arguments,&block)
        if @payload.kind_of?(Ronin::Payloads::Payload)
          return @payload.send(name,*arguments,&block)
        end

        super(name,*arguments,&block)
      end
    end
  end
end
