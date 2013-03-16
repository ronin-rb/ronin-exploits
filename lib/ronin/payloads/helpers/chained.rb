#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2013 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/payloads/has_payload'

module Ronin
  module Payloads
    module Helpers
      #
      # Allows a payload to wrap around another payload, creating a chain
      # of payloads that will deploy in order.
      #
      module Chained
        include HasPayload

        #
        # Chains the payload to another payload.
        #
        # @param [Payload] sub_payload
        #   The payload chained to this payload.
        #
        # @return [Payload]
        #   The chained payload.
        #
        def chain(sub_payload)
          self.payload = sub_payload
        end

        #
        # Builds the chained payload first, then the payload.
        #
        # @see Payload#build!
        #
        def build!(options={},&block)
          @payload.build!() if @payload

          return super(options,&block)
        end

        #
        # Verifies the built payload and deploys the payload. After the
        # payload has been deployed, the chained payload will then be
        # deployed.
        #
        # @yield [(payload)]
        #   If a block is given, the chained payload will be passed to the
        #   block.
        #
        # @yieldparam [Payload] payload
        #   The chained payload.
        #
        # @return [Payload]
        #   The chained payload.
        #
        # @see Payload#deploy!
        #
        def deploy!(&block)
          if @payload
            super()
            return @payload.deploy!(&block)
          end

          return super(&block)
        end
      end
    end
  end
end
