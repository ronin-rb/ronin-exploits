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
      # @yield [payloads]
      #   If a block is given, it will be passed all payloads matching
      #   the given query, in order to be filtered down. The first payload
      #   from the filtered payloads will end up being selected.
      #
      # @yieldparam [Array<Payload>] payloads
      #   All available payloads that match the given query.
      #
      # @return [Payload, nil]
      #   The new payload, or `nil` if no payload was found.
      #
      # @since 0.3.0
      #
      def use_payload!(query={},&block)
        self.payload = use_payload_class.load_first(query,&block)
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
