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

require 'ronin/encoders/encoder'

require 'chars'

module Ronin
  module Encoders
    class XOR < Encoder

      # Set of characters to allow in the encoded data
      attr_accessor :allow

      #
      # Creates a new XOR Encoder object.
      #
      # @param [Hash] options
      #   Additional options.
      #
      # @option options [Array, Range] :allow (1..255)
      #   The set of characters allowed in the encoded result.
      #
      # @option options [Array, Range] :disallow
      #   The set of characters that are not allowed in the encoded
      #   result.
      #
      # @yield [encoder]
      #   If a block is given it will be passed the newly created
      #   xor encoder.
      #
      # @yieldparam [XOR] encoder
      #   The newly created xor encoder.
      #
      def initialize(options={},&block)
        @allow = Chars::CharSet.new(options[:allow] || (1..255))

        if options[:disallow]
          @allow -= options[:disallow]
        end

        super(&block)
      end

      #
      # XOR encodes the given data prefixing the XOR key to the
      # encoded data.
      #
      # @param [String] data
      #   The data to be encoded.
      #
      # @return [String]
      #   The XOR encoded data.
      #
      def encode(data)
        alphabet = Chars.ascii.select { |b| data.include?(b.chr) }
        excluded = (Chars.ascii - alphabet)

        key = excluded.enum_for(:reverse_each).find do |b|
          @allow.include?(b) && alphabet.all? { |i|
            @allow.include?(i ^ b)
          }
        end

        text = ''

        text << key.chr
        data.each_byte { |b| text << (b ^ key).chr }
        return text
      end

    end
  end
end
