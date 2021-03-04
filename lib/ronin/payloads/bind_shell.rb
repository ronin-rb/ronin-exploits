#
# ronin-exploits - A Ruby library for ronin-rb that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2013 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-exploits.
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
# along with Ronin.  If not, see <https://www.gnu.org/licenses/>
#

require 'ronin/payloads/payload'
require 'ronin/payloads/helpers/bind_shell'

module Ronin
  module Payloads
    #
    # A generic payload for interacting with Bind Shells.
    #
    #     require 'ronin/payloads/bind_shell'
    #
    #     payload = Ronin::Payloads::BindShell.new
    #     payload.protocol = :tcp
    #     payload.host = 'victim.com'
    #     payload.port = 1337
    #
    #     rpc.build!
    #     rpc.deploy!
    #
    #     rpc.shell.whoami
    #     # => "www"
    #
    class BindShell < Payload

      #
      # Creates a new bind shell payload.
      #
      # @param [Hash] attributes
      #   Attributes for the bind shell.
      #
      def initialize(attributes={})
        super(attributes)

        helper :bind_shell
      end

    end
  end
end
