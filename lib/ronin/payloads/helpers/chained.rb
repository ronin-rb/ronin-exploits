require 'ronin/payloads/has_payload'

module Ronin
  module Payloads
    module Helpers
      module Chained
        include HasPayload

        #
        # Chains the payload to another payload.
        #
        # @param [Payload] sub_payload The payload chained to this payload.
        # @return [Payload] The chained payload.
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
        # @yield [(payload)] If a block is given, the chained payload will
        #                    be passed to the block.
        # @yieldparam [Payload] payload The chained payload.
        # @return [Payload] The chained payload.
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
