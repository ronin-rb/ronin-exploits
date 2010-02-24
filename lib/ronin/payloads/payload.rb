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

require 'ronin/payloads/exceptions/unknown_helper'
require 'ronin/payloads/exceptions/deploy_failed'
require 'ronin/payloads/payload_author'
require 'ronin/payloads/controlled_behavior'
require 'ronin/payloads/helpers'
require 'ronin/control/api'
require 'ronin/model/targets_arch'
require 'ronin/model/targets_os'
require 'ronin/model/has_name'
require 'ronin/model/has_description'
require 'ronin/model/has_version'
require 'ronin/model/has_license'
require 'ronin/cacheable'
require 'ronin/ui/output/helpers'
require 'ronin/extensions/kernel'

require 'parameters'

module Ronin
  module Payloads
    #
    # The {Payload} class allows for describing payloads, which are
    # delivered via exploits, purely in Ruby. Payloads contain metadata
    # about the payload and methods which define the functionality of the
    # payload. Payloads may also be coupled with exploits, or chained
    # together with other payloads.
    #
    # # Metadata
    #
    # A {Payload} is described via metadata, which is cached into the
    # database. The cacheable metadata must be defined within a `cache`
    # block, so that the metadata is set only before the payload is cached:
    #
    #     cache do
    #       self.name = 'BindShell payload'
    #       self.version = '0.1'
    #       self.description = %{
    #         An assembly Bind Shell payload, which binds a shell to a
    #         given port.
    #       }
    #
    #       # ...
    #     end
    #
    # ## License
    #
    # A {Payload} may associate with a specific software license using the
    # `license!` method:
    #
    #     license! :cc_sa_by
    #
    # ## Authors
    #
    # A {Payload} may have one or more authors which contributed to the
    # payload, using the {#author} method:
    #
    #     author(:name => 'evoltech', :organization => 'HackBloc')
    #
    #     author(:name => 'postmodern', :organization => 'SophSec')
    #
    # ## Targeting
    #
    # A {Payload} may target a specific Architecture or Operating System.
    # Targetting information can be set using the `arch!` and `os!`
    # methods.
    #
    #     arch! :i686
    #     os! :name => 'Linux'
    #
    # # Methods
    #
    # The functionality of a {Payload} is defined by three main methods.
    #
    # * `build` - Handles building the payload.
    # * `verify` - Optional method which handles verifying a built payload.
    # * `deploy` - Handles deploying a built and verified payload against a
    #   host.
    #
    # The `build`, `verify`, `deploy` methods can be invoked individually
    # using the {#build!}, {#verify!}, {#deploy!} methods, respectively.
    #
    # # Exploit/Payload Coupling
    # 
    # When an exploit is coupled with a {Payload}, the `exploit` instance 
    # variable will contain the coupled exploit. When the payload is built
    # along with the exploit, it will receive the same options given to
    # the exploit.
    #
    # # Payload Chaining
    #
    # All {Payload} classes include the {HasPayload} module, which allows
    # another payload to be chained together with a {Payload}.
    #
    # To chain a cached payload, from the database, simply use the
    # `use_payload!` method:
    #
    #     payload.use_payload!(:name.like => '%Bind Shell%')
    #
    # In order to chain a payload, loaded directly from a file, call the 
    # `use_payload_from!` method:
    #
    #     payload.use_payload_from!('path/to/my_payload.rb')
    #
    class Payload

      include Parameters
      include Cacheable
      include Model::HasName
      include Model::HasDescription
      include Model::HasVersion
      include Model::HasLicense
      include Model::TargetsArch
      include Model::TargetsOS
      include Control::API
      include UI::Output::Helpers

      # The directory to load payload helpers from.
      HELPERS_DIR = File.join('ronin','payloads','helpers')

      #
      # Creates a new payload object.
      #
      # @yield []
      #   The given block will be used to create a new payload object.
      #
      # @return [Payload]
      #   The new payload object.
      #
      # @example
      #   ronin_payload do
      #     cache do
      #       self.name = 'some payload'
      #       self.description = %{
      #         This is an example payload.
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
      contextify :ronin_payload

      # Primary key of the payload
      property :id, Serial

      # Author(s) of the payload
      has 0..n, :authors, :model => 'Ronin::Payloads::PayloadAuthor'

      # Behaviors the payload controls
      has 0..n, :controlled_behaviors

      # Validations
      validates_present :name
      validates_is_unique :version, :scope => [:name]

      # The exploit to deploy with
      attr_accessor :exploit

      # The raw payload
      attr_accessor :raw_payload

      #
      # Creates a new Payload object.
      #
      # @param [Array] attributes
      #   Additional attributes to initialize the payload with.
      #
      # @yield []
      #   If a block is given, it will be evaluated in the newly created
      #   Payload object.
      #
      def initialize(attributes={},&block)
        super(attributes)

        initialize_params(attributes)

        @built = false
        @deployed = false

        instance_eval(&block) if block
      end

      #
      # Finds all payloads written by a specific author.
      #
      # @param [String] name
      #   The name of the author.
      #
      # @return [Array<Payload>]
      #   The payload written by the author.
      #
      def self.written_by(name)
        all(self.authors.name.like => "%#{name}%")
      end

      #
      # Finds all payloads written for a specific organization.
      #
      # @param [String] name
      #   The name of the organization.
      #
      # @return [Array<Payload>]
      #   The payloads written for the organization.
      #
      def self.written_for(name)
        all(self.authors.organization.like => "%#{name}%")
      end

      #
      # Adds a new author to the payload.
      #
      # @param [Hash] attributes
      #   Additional attributes to create the PayloadAuthor object with.
      #
      # @yield [author]
      #   If a block is given, it will be passed the newly created author
      #   object.
      #
      # @yieldparam [PayloadAuthor] author
      #   The author object tied to the payload.
      #
      # @example
      #   author :name => 'Anonymous',
      #          :email => 'anon@example.com',
      #          :organization => 'Anonymous LLC'
      #
      def author(attributes={},&block)
        self.authors << PayloadAuthor.new(attributes,&block)
      end

      #
      # @return [Boolean]
      #   Specifies whether the payload is built.
      #
      def built?
        @built == true
      end

      #
      # Builds the payload.
      #
      # @param [Hash] options
      #   Additional options to build the payload with and use as
      #   parameters.
      #
      # @yield [payload]
      #   If a block is given, it will be yielded the result of the
      #   payload building.
      #
      # @yieldparam [String] payload
      #   The built payload.
      #
      # @return [String]
      #   The built payload.
      #
      def build!(options={},&block)
        self.params = options

        print_debug "Payload parameters: #{self.params.inspect}"

        @built = false
        @raw_payload = ''

        print_info "Building payload ..."

        build()

        print_info "Payload built!"

        @built = true

        if block
          if block.arity == 1
            block.call(self)
          else
            block.call()
          end
        end

        return self
      end

      #
      # Verifies the payload is properly configured and ready to be
      # deployed.
      #
      def verify!
        print_info "Verifying payload ..."

        verify

        print_info "Payload verified!"
      end

      #
      # @return [Boolean]
      #   Specifies whether the payload has previously been deployed.
      #
      def deployed?
        @deployed == true
      end

      #
      # Verifies the built payload and deploys the payload.
      #
      # @yield [payload]
      #   If a block is given, it will be passed the deployed payload.
      #
      # @yieldparam [Payload] payload
      #   The deployed payload.
      #
      def deploy!(&block)
        # verify the payload
        verify!

        print_info "Deploying payload ..."
        @deployed = false

        deploy()

        print_info "Payload deployed!"
        @deployed = true
        
        if block
          if block.arity == 1
            block.call(self)
          else
            block.call()
          end
        end

        return self
      end

      #
      # Converts the payload to a String.
      #
      # @return [String]
      #   The name and version of the payload.
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
      # @return [String]
      #   The inspected payload.
      #
      def inspect
        str = "#{self.class}: #{self}"
        str << " #{self.params.inspect}" unless self.params.empty?

        return "#<#{str}>"
      end

      protected

      #
      # Loads a helper module from `ronin/payloads/helpers` and extends the
      # payload with it.
      #
      # @param [Symbol, String] name
      #   The snake-case name of the payload helper to load and extend the
      #   payload with.
      #
      # @return [true]
      #   The payload helper was successfully loaded.
      #
      # @raise [UnknownHelper]
      #   No valid helper module could be found or loaded with the similar
      #   name.
      #
      # @example
      #   helper :shell
      #
      def helper(name)
        name = name.to_s

        unless (helper_module = Helpers.require_const(name))
          raise(UnknownHelper,"unknown helper #{name.dump}",caller)
        end

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
      # Indicates that the deployment of the payload has failed.
      #
      # @raise [DeployFailed]
      #   The deployment of the payload failed.
      #
      # @since 0.3.2
      #
      def deploy_failed!(message)
        raise(DeployFailed,message,caller)
      end

      #
      # Default payload deployer method.
      #
      def deploy(&block)
      end

    end
  end
end
