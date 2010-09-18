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

require 'ronin/leverage/resources/resources'
require 'ronin/leverage/exceptions/unknown_resource'
require 'ronin/leverage/class_methods'
require 'ronin/extensions/meta'

module Ronin
  module Leverage
    module Mixin
      def self.included(base)
        base.send :extend, ClassMethods
      end

      #
      # The leveraged resources.
      #
      # @return [Hash{Symbol => Resource}]
      #   The leveraged resources.
      #
      # @since 0.4.0
      #
      def leveraged
        unless defined?(@leveraged)
          @leveraged = {}

          self.class.leverages.each do |name|
            @leveraged[name] = leveraged_resource(name)
          end
        end

        return @leveraged
      end

      #
      # Determines if the object leverages the specified resource.
      #
      # @param [Symbol] name
      #   The resource name.
      #
      # @return [Boolean]
      #   Specifies whether the object leverages the specified resource.
      #
      # @since 0.4.0
      #
      def leveraged?(name)
        self.leveraged.has_key?(name.to_sym)
      end

      protected

      #
      # Loads and creates a new leveraged resource.
      #
      # @param [Symbol] name
      #   The resource to load.
      #
      # @return [Resource]
      #   The leveraged resource.
      #
      # @since 0.4.0
      #
      def leveraged_resource(name)
        name = name.to_sym

        unless (resource = Resources.require_const(name))
          raise(UnknownResource,"Unknown resource for #{name}",caller)
        end

        return resource.new(self)
      end

      #
      # Defines a leveraged resource.
      #
      # @param [Symbol] name
      #   The resource to leverage.
      #
      # @return [Resource]
      #   The leveraged resource.
      #
      # @raise [UnknownResource]
      #   The resource class could not be found.
      #
      # @since 0.4.0
      #
      def leverage(name)
        name = name.to_sym

        unless self.respond_to?(name)
          # define a getter method, if it was not defined by the class
          self.meta_def(name) { self.leveraged[name] }
        end

        self.leveraged[name] = leveraged_resource(name)
      end
    end
  end
end
