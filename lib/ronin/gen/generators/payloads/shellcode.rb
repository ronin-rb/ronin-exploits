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

require 'ronin/gen/generators/payloads/binary_payload'

module Ronin
  module Gen
    module Generators
      module Payloads
        #
        # Generates a new ronin shellcode payload file.
        #
        class Shellcode < BinaryPayload

          #
          # Generate a Shellcode payload.
          #
          # @since 0.3.0
          #
          def generate
            erb File.join('ronin','gen','payloads','shellcode.erb'),
                self.path
          end

        end
      end
    end
  end
end
