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

require 'ronin/payloads/helpers/rpc/process'
require 'ronin/network/mixins/http'

require 'base64'
require 'json'
require 'uri'

module Ronin
  module Payloads
    module Helpers
      module RPC
        #
        # Payload Helper for interacting with RPC HTTP Servers.
        #
        # ## Example
        #
        #     ronin_payload do
        #
        #       helper 'rpc/http'
        #
        #       def process_getuid
        #         rpc_call('process.getuid')
        #       end
        #
        #       def process_setuid(uid)
        #         rpc_call('process.setuid', uid)
        #       end
        #
        #     end
        #
        module HTTP
          include Process

          def self.extended(object)
            object.extend Network::Mixins::HTTP

            object.instance_eval do
              test_set :host
              test_set :port
            end
          end

          protected

          #
          # Encodes an RPC Request.
          #
          # @param [Hash] message
          #   The message to send to the HTTP Server.
          #
          # @return [URI::HTTP]
          #   The encoded request.
          #
          # @api private
          #
          def rpc_encode_request(message)
            name      = message[:name]
            arguments = message[:arguments]

            URI::HTTP.build(
              :host  => self.host,
              :port  => self.port,
              :path  => '/' + name.gsub('.','/'),
              :query => unless (arguments.nil? || arguments.empty?)
                          URI.escape(Base64.encode64(arguments.to_json))
                        end
            )
          end

          #
          # Decodes a RPC Response.
          #
          # @param [String] data
          #   A response from the HTTP Server.
          #
          # @return [Hash]
          #   The decoded RPC response.
          #
          # @api private
          #
          def rpc_decode_response(data)
            JSON.parse(Base64.decode64(data))
          end

          #
          # Calls a function on the Server.
          #
          # @param [String, Symbol] name
          #   The RPC function to call.
          #
          # @param [Array] arguments
          #   Additional arguments to pass to the RPC function.
          #
          # @return [Object]
          #   The return value from the RPC function.
          #
          # @raise [RuntimeError]
          #   An exception raised by the RPC function.
          #
          # @api semipublic
          #
          def rpc_call(name,*arguments)
            uri = rpc_encode_request(:name => name, :arguments => arguments)

            response = rpc_decode_response(http_get(:url => uri).body)

            if response['exception']
              raise(response['exception'])
            end

            return response['return']
          end

        end
      end
    end
  end
end
