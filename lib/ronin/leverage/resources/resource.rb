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

require 'ronin/ui/output/helpers'

module Ronin
  module Leverage
    module Resources
      class Resource

        include UI::Output::Helpers

        # The object leveraging the resource
        attr_reader :leverage

        #
        # Creates a new Resource.
        #
        # @param [Object] parent 
        #   The object leveraging the Resource.
        #
        # @since 0.4.0
        #
        def initialize(leverage)
          @leverage = leverage
        end

        protected

        #
        # Requires that the leveraging object define the given method.
        #
        # @param [Symbol] name
        #   The name of the method that is required.
        #
        # @return [true]
        #   The method is defined.
        #
        # @raise [RuntimeError]
        #   The method is not defined by the leveraging object.
        #
        # @since 0.4.0
        #
        def requires_method!(name)
          unless @leverage.respond_to?(name)
            raise(RuntimeError,"#{@leverage.inspect} does not define #{name}",caller)
          end

          return true
        end

      end
    end
  end
end
