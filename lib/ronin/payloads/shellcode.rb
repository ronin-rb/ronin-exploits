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

require 'ronin/payloads/asm_payload'

module Ronin
  module Payloads
    #
    # A {Payload} class that represents payloads written in assembly which
    # spawn shells or run commands.
    #
    class Shellcode < ASMPayload

      protected

      #
      # Assembles Shellcode and sets the `@payload` instance variable.
      #
      # @param [Hash{Symbol => Object}] variables
      #   Variables for the shellcode.
      #
      # @yield []
      #   The given block represents the instructions of the shellcode.
      #
      # @return [String]
      #   The assembled shellcode.
      #
      # @see #assemble
      #
      def shellcode(variables={},&block)
        @payload = assemble(:format => :bin, :variables => variables,&block)
      end

    end
  end
end
