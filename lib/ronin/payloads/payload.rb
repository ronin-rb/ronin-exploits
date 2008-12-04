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
require 'ronin/object_context'
require 'ronin/parameters'
require 'ronin/license'

module Ronin
  module Payloads
    class Payload

      include ObjectContext
      include Parameters

      object_contextify :payload

      # Name of the specific payload
      property :name, String, :index => true

      # Version of the payload
      property :version, String, :default => '0.1', :index => true

      # Description of the payload
      property :description, Text

      # Author(s) of the payload
      has n, :authors, :class_name => 'PayloadAuthor'

      # Content license
      belongs_to :license

      # Validations
      validates_present :name
      validates_is_unique :version, :scope => [:name]

      # Encoders to apply to the payload
      attr_reader :encoders

      # Payload package
      attr_accessor :package

      # Encoded payload package
      attr_reader :encoded_package

      #
      # Creates a new Payload object with the given _options_. If a
      # _block_ is given, it will be passed the newly created Payload
      # object.
      #
      def initialize(options={},&block)
        super(options)

        @encoders = []

        block.call(self) if block
      end

      #
      # Finds all payloads with names like the specified _name_.
      #
      def self.named(name)
        self.all(:name.like => "%#{name}%")
      end

      #
      # Finds all payloads with descriptions like the specified
      # _description_.
      #
      def self.describing(description)
        self.all(:description.like => "%#{description}%")
      end

      #
      # Finds the payload with the most recent vesion.
      #
      def self.latest
        self.first(:order => [:version.desc])
      end

      #
      # Adds a new PayloadAuthor with the given _attribs_ and _block_.
      #
      def author(attribs={},&block)
        authors << PayloadAuthor.first_or_create(attribs,&block)
      end

      #
      # Add the specified _encoder_object_ to the encoders.
      #
      def encoder(encoder_object)
        @encoders << encoder_object
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
      # Performs a clean build of the payload. If a _block_ is given, it
      # will be passed the built and encoded package.
      #
      def build(&block)
        @package = ''

        builder()

        @encoded_package = @package

        @encoders.each do |enc|
          @encoded_package = encode(@encoded_package)
        end

        block.call(@encoded_package) if block
        return @encoded_package
      end

      #
      # Default method to call after the payload has been deployed.
      #
      def deploy(&block)
      end

      #
      # Returns a String form of the payload containing the payload's name
      # and version.
      #
      def to_s
        return "#{@name} #{@version}" if @version
        return @name.to_s
      end

    end
  end
end
