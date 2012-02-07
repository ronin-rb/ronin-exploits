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

require 'ronin/network/http'

require 'uri/http'

module Ronin
  module Payloads
    module Helpers
      module RPC
        #
        # RPC Transport methods for interacting with a HTTP Service.
        #
        module HTTP
          def self.extended(object)
            object.extend Network::HTTP

            object.instance_eval do
              parameter :base_url, :type        => String,
                                   :default     => '/',
                                   :description => 'Base URL of the RPC Server'

              parameter :query_param_field, :type        => String,
                                   :default     => '_request',
                                   :description => 'Query parameter field to use rpc value'

              parameter :response_tag, :type        => String,
                                       :default     => 'rpc-response',
                                       :description => 'The tag that the rpc response will be embedded in'
            end
          end

          def rpc_url
            URI::HTTP.build(
              :host => self.host,
              :port => self.port
            )
          end

          def rpc_url_for(message)
            url  = rpc_url
            url.query_params[self.query_param_field] = rpc_serialize(message)

            return url
          end

          protected

          def rpc_send(message)
            body = http_get_body(:url => rpc_url_for(message))
            if self.response_tag && body =~ /<rpc-response>([^<]+)<\/rpc-response>/
              body = $1
            end

            rpc_deserialize(body)
          end
        end
      end
    end
  end
end
