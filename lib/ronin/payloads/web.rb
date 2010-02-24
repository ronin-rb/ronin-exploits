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
require 'ronin/network/helpers/http'
require 'ronin/formatting/http'
require 'ronin/extensions/uri/http'

module Ronin
  module Payloads
    #
    # A {Payload} class that represents payloads which are used to
    # compromise Web services.
    #
    class Web < Payload

      include Network::Helpers::HTTP

      #
      # Creates a new web payload object.
      #
      # @yield []
      #   The given block will be used to create a new web payload object.
      #
      # @return [Ronin::Payloads::Web]
      #   The new web payload object.
      #
      # @example
      #   ronin_web_payload do
      #     cache do
      #       self.name = 'some web payload'
      #       self.description = %{
      #         This is an example web payload.
      #       }
      #     end
      #
      #     def build
      #     end
      #
      #     def deploy
      #     end
      #   end
      #
      contextify :ronin_web_payload

    end
  end
end
