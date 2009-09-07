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
        # @see Payload#deploy!
        #
        def deploy!(&block)
          super(&block)

          @payload.deploy!() if @payload

          return self
        end
      end
    end
  end
end
