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
require 'uri/query_params'

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
              parameter :rpc_path, :type        => String,
                                   :default     => '/',
                                   :description => 'Base URL of the RPC Server'

              parameter :rpc_query_param, :type        => String,
                                   :default     => '_request',
                                   :description => 'Query parameter field to use rpc value'

              parameter :rpc_response_tag, :type        => String,
                                           :default     => 'rpc-response',
                                           :description => 'The tag that the rpc response will be embedded in'
            end
          end

          #
          # @return [URI::HTTP]
          #   The URL to the HTTP RPC Server.
          #
          def rpc_url
            URI::HTTP.build(
              :host => self.host,
              :port => self.port
            )
          end

          #
          # Creates a URL for the RPC message.
          #
          # @return [URI::HTTP]
          #   The URL including the RPC message.
          #
          def rpc_url_for(message)
            url  = rpc_url

            url.path  = self.rpc_path
            url.query = "#{self.rpc_query_param}=#{rpc_serialize(message)}"

            return url
          end

          protected

          #
          # Encodes an RPC message.
          #
          # @param [Hash] message
          #   The message to encode.
          #
          # @return [String]
          #   The encoded message.
          #
          def rpc_serialize(message)
            super(message).gsub("\n",'')
          end

          #
          # Sends the message to the HTTP RPC Server.
          #
          # @param [Hash] message
          #   The RPC message to send.
          #
          # @return [Hash]
          #   The response RPC message.
          #
          def rpc_send(message)
            body = http_get_body(:url => rpc_url_for(message))

            if self.rpc_response_tag
              # regexp to extract the response from within HTTP output
              response_extractor = /<#{self.rpc_response_tag}>([^<]+)<\/#{self.rpc_response_tag}>/

              if (match = body.match(response_extractor))
                body = match[1]
              end
            end

            return rpc_deserialize(body)
          end
        end
      end
    end
  end
end
