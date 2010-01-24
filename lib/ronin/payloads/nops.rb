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

require 'ronin/payloads/asm_payload'

module Ronin
  module Payloads
    class Nops < ASMPayload

      #
      # Creates a new NOPs payload object.
      #
      # @yield []
      #   The given block will be used to create a new NOPs payload object.
      #
      # @return [Nops]
      #   The new NOPs payload object.
      #
      # @example
      #   ronin_nops do
      #     cache do
      #       self.name = 'some NOPs payload'
      #       self.description = %{
      #         This is an example NOPs payload.
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
      contextify :ronin_nops

    end
  end
end
