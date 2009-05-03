#
#--
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
#++
#

require 'ronin/payloads/payload_author'
require 'ronin/payloads/control'
require 'ronin/payloads/helpers'
require 'ronin/targeted_arch'
require 'ronin/targeted_os'
require 'ronin/cacheable'
require 'ronin/has_license'

require 'parameters'

module Ronin
  module Payloads
    class Payload

      include Parameters
      include Cacheable
      include HasLicense
      include Helpers

      contextify :ronin_payload

      # Primary key of the payload
      property :id, Serial

      # Name of the specific payload
      property :name, String, :index => true

      # Version of the payload
      property :version, String, :default => '0.1', :index => true

      # Description of the payload
      property :description, Text

      # The payloads targeted architecture
      belongs_to :arch,
                 :child_key => [:arch_id],
                 :class_name => 'Ronin::TargetedArch'

      # The payloads targeted OS
      belongs_to :os,
                 :child_key => [:os_id],
                 :class_name => 'Ronin::TargetedOS'

      # Author(s) of the payload
      has n, :authors, :class_name => 'Ronin::Payloads::PayloadAuthor'

      # Controls the payload provides
      has n, :controls

      # Validations
      validates_present :name
      validates_is_unique :version, :scope => [:name]

      # Encoders to apply to the payload
      attr_reader :encoders

      # The built and encoded payload
      attr_accessor :payload

      #
      # Creates a new Payload object with the given _attributes_. If a
      # _block_ is given, it will be passed the newly created Payload
      # object.
      #
      def initialize(attributes={},&block)
        super(attributes)

        @encoders = []
        @built = false

        instance_eval(&block) if block
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
      # Returns the current targeted arch if no _name_ is given. If a
      # _name_ is given, a new TargetedArch object will be created
      # with the given _name_ and associated with the target.
      #
      #   target.arch
      #   # => nil
      #
      #   target.arch :i686
      #   # => #<Ronin::TargetedArch type=Ronin::TargetedArch id=nil
      #   # name="i686" endian="little" address_length=4>
      #
      def arch(name=nil)
        if name
          return self.arch = TargetedArch[name]
        else
          return arch_association
        end
      end

      #
      # Returns the current targeted OS if no _arguments_ are given. If
      # _arguments_ are given, a new TargetedOS object will be created
      # from the given _arguments_ and associated with the target.
      #
      #   target.os
      #   # => nil
      #
      #   target.os(:name => 'FreeBSD', :version => '7.1')
      #   # => #<Ronin::TargetedOS type=Ronin::TargetedOS id=nil
      #   # name="FreeBSD" version="7.1">
      #
      def os(*arguments)
        unless arguments.empty?
          return self.os = TargetedOS.first_or_create(*arguments)
        else
          return os_association
        end
      end

      #
      # Adds a new PayloadAuthor with the given _attributes_. If a _block_
      # is given, it will be passed to the newly created PayloadAuthor
      # object.
      #
      def author(attributes={},&block)
        authors << PayloadAuthor.new(
          attributes.merge(:payload => self),
          &block
        )
      end

      #
      # Adds a new Control to the payload that provides the specified
      # _behavior_.
      #
      def controls(behavior)
        self.controls << Control.new(
          :behavior => Vuln::Behavior[behavior],
          :payload => self
        )
      end

      #
      # Add the specified _encoder_object_ to the encoders.
      #
      def encoder(encoder_object)
        @encoders << encoder_object
      end

      #
      # Returns +true+ if the payload is built, returns +false+ otherwise.
      #
      def built?
        @built == true
      end

      #
      # Performs a clean build of the payload with the given _params_.
      # If a _block_ is given, it will be passed the built and encoded
      # payload.
      #
      def build!(options={},&block)
        self.params = options

        @built = false
        @payload = ''

        build()

        @built = true

        @encoders.each do |encoder|
          @payload = encoder.encode(@payload)
        end

        block.call(@payload) if block
        return @payload
      end

      #
      # Default verify method, calls verifier by default.
      #
      def verify!
        verify
      end

      #
      # Default method to call after the payload has been deployed.
      #
      def deploy!(&block)
        verify!
        deploy()
        
        block.call(self) if block
        return self
      end

      #
      # Returns the name and version of the payload.
      #
      def to_s
        "#{self.name} #{self.version}"
      end

      protected

      #
      # Default builder method.
      #
      def build
      end

      #
      # Default payload verifier method.
      #
      def verify
      end

      #
      # Default payload deployer method.
      #
      def deploy(&block)
      end

    end
  end
end
