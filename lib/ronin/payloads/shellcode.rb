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

require 'ronin/payloads/asm_payload'

module Ronin
  module Payloads
    #
    # A {Payload} class that represents payloads written in assembly which
    # spawn shells or run commands.
    #
    # ## Example
    #
    #     #!/usr/bin/env ronin-payload -f
    #     
    #     require 'ronin/payloads/shellcode'
    #     
    #     Ronin::Payloads::Shellcode.object do
    #     
    #       cache do
    #         self.name        = 'local_shell'
    #         self.version     = '0.5'
    #         self.description = %{
    #           Shellcode that spawns a local /bin/sh shell
    #         }
    #     
    #         targets_arch :x86
    #         targets_os   'Linux'
    #       end
    #     
    #       build do
    #         shellcode do
    #           xor   eax, eax
    #           push  eax
    #           push  0x68732f2f
    #           push  0x6e69622f
    #           mov   esp, ebx
    #           push  eax
    #           push  ebx
    #           mov   esp, ecx
    #           xor   edx, edx
    #           int   0xb
    #         end
    #       end
    #     
    #     end
    #
    class Shellcode < ASMPayload

      protected

      #
      # Assembles Shellcode and sets the `@payload` instance variable.
      #
      # @param [Hash{Symbol => Object}] define
      #   Constants to define in the shellcode.
      #
      # @yield []
      #   The given block represents the instructions of the shellcode.
      #
      # @return [String]
      #   The assembled shellcode.
      #
      # @see #assemble
      #
      def shellcode(define={},&block)
        options = {:format => :bin, :define => define}

        @raw_payload = assemble(options,&block)
      end

    end
  end
end
