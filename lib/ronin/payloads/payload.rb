#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2011 Hal Brodigan (postmodern.mod3 at gmail.com)
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
require 'ronin/payloads/helpers'
require 'ronin/leverage'
require 'ronin/engine'
require 'ronin/engine/buildable'
require 'ronin/engine/deployable'
require 'ronin/model/targets_arch'
require 'ronin/model/targets_os'
require 'ronin/extensions/kernel'

require 'set'

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
    # Ronin Database. The cacheable metadata must be defined within a
    # `cache` block, so that the metadata is set only before the payload
    # is cached:
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
    #     cache do
    #       # ...
    #
    #       license! :cc_sa_by
    #     end
    #
    # ## Authors
    #
    # A {Payload} may have one or more authors which contributed to the
    # payload, using the `author` method:
    #
    #     cache do
    #       # ...
    #
    #       author(:name => 'evoltech', :organization => 'HackBloc')
    #       author(:name => 'postmodern', :organization => 'SophSec')
    #     end
    #
    # ## Targeting
    #
    # A {Payload} may target a specific Architecture or Operating System.
    # Targetting information can be set using the {#arch!} and {#os!}
    # methods.
    #
    #     cache do
    #       # ...
    #
    #       arch! :i686
    #       os! :name => 'Linux'
    #     end
    #
    # # Methods
    #
    # The functionality of a {Payload} is defined by three main methods.
    #
    # * `build` - Handles building the payload.
    # * `verify` - Optional method which handles verifying a built payload.
    # * `deploy` - Handles deploying a built and verified payload against a
    #   host.
    # * `evacuate` - Handles cleaning up after a deployed payload.
    #
    # The `build`, `verify`, `deploy`, `evacuate` methods can be invoked
    # individually using the `build!`, `verify!`, `deploy!`, `evacuate!`
    # methods, respectively.
    #
    # # Exploit/Payload Coupling
    # 
    # When an exploit is coupled with a {Payload}, the {#exploit} method 
    # will contain the coupled exploit. When the payload is built
    # along with the exploit, it will receive the same options given to
    # the exploit.
    #
    # # Payload Chaining
    #
    # All {Payload} classes include the {HasPayload} module, which allows
    # another payload to be chained together with a {Payload}.
    #
    # To chain a cached payload, from the Ronin Database, simply use the
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

      include Engine
      include Engine::Buildable
      include Engine::Deployable
      include Model::TargetsArch
      include Model::TargetsOS
      include Leverage::API

      # Primary key of the payload
      property :id, Serial

      # Validations
      validates_uniqueness_of :version, :scope => [:name]

      # The helpers used by the payload
      attr_reader :helpers

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
      def initialize(attributes={})
        super(attributes)

        @helpers = Set[]
      end

      protected

      #
      # Loads a helper module from `ronin/payloads/helpers` and extends the
      # payload with it.
      #
      # @param [Symbol, String] name
      #   The underscored name of the payload helper to load and extend the
      #   payload with.
      #
      # @return [Boolean]
      #   Specifies whether the payload helper was successfully loaded.
      #   Returns `false` if the payload helper has already been loaded.
      #
      # @raise [UnknownHelper]
      #   No valid helper module could be found or loaded with the similar
      #   name.
      #
      # @example
      #   helper :shell
      #
      def helper(name)
        name = name.to_sym

        return false if @helpers.include?(name)

        unless (helper_module = Helpers.require_const(name))
          raise(UnknownHelper,"unknown helper #{name}",caller)
        end

        unless helper_module.kind_of?(Module)
          raise(UnknownHelper,"unknown helper #{name}",caller)
        end

        @helpers << name
        extend helper_module
        return true
      end

    end
  end
end
