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

require 'ronin/payloads/exceptions/unknown_helper'
require 'ronin/payloads/license'
require 'ronin/payloads/arch'
require 'ronin/payloads/os'
require 'ronin/payloads/payload_author'
require 'ronin/payloads/control'
require 'ronin/cacheable'
require 'ronin/model/targets_arch'
require 'ronin/model/targets_os'
require 'ronin/model/has_name'
require 'ronin/model/has_description'
require 'ronin/model/has_version'
require 'ronin/model/has_license'
require 'ronin/ui/diagnostics'
require 'ronin/extensions/kernel'

require 'parameters'

module Ronin
  module Payloads
    class Payload

      include Parameters
      include Cacheable
      include Model::HasName
      include Model::HasDescription
      include Model::HasVersion
      include Model::HasLicense
      include Model::TargetsArch
      include Model::TargetsOS
      include UI::Diagnostics

      contextify :ronin_payload

      # Primary key of the payload
      property :id, Serial

      # Author(s) of the payload
      has n, :authors, :model => 'Ronin::Payloads::PayloadAuthor'

      # Controls the payload provides
      has n, :controls

      # Validations
      validates_present :name
      validates_is_unique :version, :scope => [:name]

      # The exploit to deploy with
      attr_accessor :exploit

      # The built payload
      attr_accessor :payload

      #
      # Creates a new Payload object with the given _attributes_. If a
      # _block_ is given, it will be passed the newly created Payload
      # object.
      #
      def initialize(attributes={},&block)
        super(attributes)

        initialize_params(attributes)

        @built = false
        @deployed = false

        instance_eval(&block) if block
      end

      #
      # Adds a new PayloadAuthor with the given _attributes_. If a _block_
      # is given, it will be passed to the newly created PayloadAuthor
      # object.
      #
      #   author :name => 'Anonymous',
      #          :email => 'anon@example.com',
      #          :organization => 'Anonymous LLC'
      #
      def author(attributes={},&block)
        self.authors << PayloadAuthor.new(attributes,&block)
      end

      #
      # Adds a new Control to the payload that controls the specified
      # _behaviors_.
      #
      #   controlling :code_exec.
      #               :file_read,
      #               :file_write,
      #               :file_create
      #
      def controlling(*behaviors)
        behaviors.each do |behavior|
          self.controls << Control.new(
            :behavior => Vuln::Behavior[behavior]
          )
        end
      end

      #
      # Returns the behaviors controlled by the payload.
      #
      def behaviors
        self.controls.map { |control| control.behavior }
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

        block.call(@payload) if block
        return @payload
      end

      #
      # Verifies the payload is properly configured and ready to be
      # deployed.
      #
      def verify!
        verify
      end

      #
      # Returns +true+ if the payload has previously been deployed,
      # returns +false+ otherwise.
      #
      def deployed?
        @deployed == true
      end

      #
      # Verifies the built payload and deploys the payload. If a _block_
      # is given, it will be passed the deployed payload object.
      #
      def deploy!(options={},&block)
        # verify the payload
        verify!

        @deployed = false

        deploy()

        @deployed = true
        
        block.call(self) if block
        return self
      end

      #
      # Builds the payload with the given _options_ and deploys it with
      # the given _block_. If a _block_ is given, it will be passed the
      # deployed payload.
      #
      def call(options={},&block)
        # build the payload
        build!(options)

        # deploy the payload
        return deploy!(options,&block)
      end

      #
      # Returns the name and version of the payload.
      #
      def to_s
        if (self.name && self.version)
          "#{self.name} #{self.version}"
        elsif self.name
          self.name
        elsif self.version
          self.version
        end
      end

      #
      # Inspects the contents of the payload.
      #
      def inspect
        str = "#{self.class}: #{self}"
        str << " #{self.params.inspect}" unless self.params.empty?

        return "#<#{str}>"
      end

      protected

      #
      # Extends the payload with the helper module defined in
      # Ronin::Payloads::Helpers that has the similar specified
      # _name_. If no module can be found within
      # Ronin::Payloads::Helpers with the similar _name_, an
      # UnknownHelper exception will be raised.
      #
      #   helper :shell
      #
      def helper(name)
        name = name.to_s
        module_name = name.to_const_string

        begin
          require_within File.join('ronin','payloads','helpers'), name
        rescue Gem::LoadError => e
          raise(e)
        rescue ::LoadError
          raise(UnknownHelper,"unknown helper #{name.dump}",caller)
        end

        unless Ronin::Payloads::Helpers.const_defined?(module_name)
          raise(UnknownHelper,"unknown helper #{name.dump}",caller)
        end

        helper_module = Ronin::Payloads::Helpers.const_get(module_name)

        unless helper_module.kind_of?(Module)
          raise(UnknownHelper,"unknown helper #{name.dump}",caller)
        end

        extend helper_module
        return true
      end

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
