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

require 'ronin/payloads/helpers/rpc/tcp'
require 'ronin/payloads/helpers/rpc/process'
require 'ronin/network/mixins/tcp'

module Ronin
  module Payloads
    module Helpers
      module RPC
        #
        # Payload Helper for interacting with RPC TCP Servers.
        #
        # ## Example
        #
        #     ronin_payload do
        #
        #       helper 'rpc/tcp_server'
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
        module TCPServer
          include TCP
          include Process

          def self.extended(object)
            object.extend Network::Mixins::TCP

            object.instance_eval do
              test_set :host
              test_set :port

              deploy do
                @connection = tcp_connect
              end

              evacuate do
                @connection.close
                @connection = nil
              end
            end
          end
        end
      end
    end
  end
end
