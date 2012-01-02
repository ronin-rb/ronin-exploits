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

require 'open_namespace'
require 'base64'
require 'json'

module Ronin
  module Payloads
    module Helpers
      #
      # Helper methods for interacting with RPC Servers.
      #
      module RPC
        include OpenNamespace

        def self.extended(object)
          object.instance_eval do
            parameter :transport, :type        => Symbol,
                                  :description => 'RPC Transport [tcp_server, tcp_connect_back, http]'

            parameter :host, :type        => String,
                             :description => 'RPC host'

            parameter :port, :type        => Integer,
                             :description => 'RPC port'

            parameter :local_host, :type        => String,
                                   :default     => '0.0.0.0',
                                   :description => 'Local RPC host'

            parameter :local_port, :type        => Integer,
                                   :description => 'Local RPC port'

            build do
              extend Ronin::Payloads::Helpers::RPC.require_const(self.transport)
            end

            deploy do
              rpc_connect if respond_to?(:rpc_connect)
            end

            evacuate do
              rpc_disconnect if respond_to?(:rpc_disconnect)
            end
          end
        end

        def rpc_call(name,*arguments)
          response = rpc_send(:name => name, :arguments => arguments)

          if response['exception']
            raise(response['exception'])
          end

          return response['return']
        end

        protected

        def rpc_serialize(message)
          Base64.decode64(message.to_json)
        end

        def rpc_deserialize(data)
          JSON.parse(Base64.decode64(data))
        end

      end
    end
  end
end
