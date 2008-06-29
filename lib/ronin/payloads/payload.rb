#
#--
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2008 Hal Brodigan (postmodern.mod3 at gmail.com)
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
#++
#

require 'ronin/payloads/payload_author'
require 'ronin/cache/object_context'
require 'ronin/parameters'
require 'ronin/license'

module Ronin
  module Payloads
    class Payload

      include Cache::ObjectContext
      include Parameters

      object_contextify :payload

      # Name of the specific payload
      property :name, String

      # Version of the payload
      property :version, String

      # Description of the payload
      property :description, String

      # Author(s) of the payload
      has 0..n, :authors, :class_name => 'Ronin::Payloads::PayloadAuthor'

      # Content license
      belongs_to :license, :class_name => 'Ronin::License'

      # Payload package
      attr_accessor :package

      #
      # Adds a new PayloadAuthor with the given _options_ and _block_.
      #
      def author(options={},&block)
        @authors << PayloadAuthor.new(options,&block)
      end

      #
      # Default prepare method.
      #
      def prepare(exploit)
      end

      #
      # Default builder method.
      #
      def builder
      end

      #
      # Returns +true+ if the payload is built, returns +false+ otherwise.
      #
      def is_built?
        !(@package.nil? || @package.empty?)
      end

      #
      # Performs a clean build of the payload.
      #
      def build
        @package = ''

        builder
      end

      #
      # Default cleaner method.
      #
      def cleaner
      end

      #
      # Returns +true+ if the payload has been cleaned, returns false
      # otherwise.
      #
      def is_clean?
        @package.nil?
      end

      #
      # Cleans the payload.
      #
      def clean
        cleaner

        @package = nil
      end

      #
      # Returns a String form of the payload containing the payload's name
      # and version.
      #
      def to_s
        return "#{@name}-#{@version}" if @version
        return @name.to_s
      end

    end
  end
end
