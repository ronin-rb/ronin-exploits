#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2009 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/payloads/encoders/encoder'

require 'chars'

module Ronin
  module Payloads
    module Encoders
      class XOR < Encoder

        # Set of characters to allow in the encoded data
        attr_accessor :allow

        #
        # Creates a new XOR Encoder object using the given _options_.
        # If a _block_ is given it will be passed the newly created
        # Encoder object.
        #
        # _options_ may include the following keys:
        # <tt>:allow</tt>:: The set of characters allowed in the encoded
        #                   result. Defaults to <tt>(1..255)</tt>.
        # <tt>:disallow</tt>:: The set of characters that are not allowed
        #                      in the encoded result.
        #
        def initialize(options={},&block)
          @allow = Chars::CharSet.new(options[:allow] || (1..255))

          if options[:disallow]
            @allow -= options[:disallow]
          end

          super(&block)
        end

        #
        # XOR encodes the specified _data_ prefixing the XOR key to the
        # encoded data.
        #
        def encode(data)
          alphabet = Chars.ascii.select { |b| data.include?(b.chr) }
          excluded = (Chars.ascii - alphabet)

          key = excluded.select { |b|
            @allow.include?(b) && alphabet.all? { |i|
              @allow.include?(i ^ b)
            }
          }.last

          text = ''

          text << key.chr
          data.each_byte { |b| text << (b ^ key).chr }
          return text
        end

      end
    end
  end
end
