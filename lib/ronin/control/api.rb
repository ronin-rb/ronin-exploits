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

require 'ronin/control/behavior'

module Ronin
  module Control
    module API
      #
      # The names of the supported control methods.
      #
      # @return [Array<Symbol>]
      #   The method names.
      #
      # @since 0.3.2
      #
      def API.control_methods
        Behavior.predefined_names
      end

      #
      # The names of the methods which control behaviors of a vulnerability
      # being exploited.
      #
      # @return [Array<Symbol>]
      #   The names of the methods available in the object.
      #
      def control_methods
        return Ronin::Control::API.control_methods.select do |name|
          self.respond_to?(name)
        end
      end

      #
      # Populates the +controlled_behaviors+ relationship based on
      # {control_methods}, before the object is cached.
      #
      def before_caching
        super()

        if self.class.relationships.has_key?(:controlled_behaviors)
          behavior_model = self.class.relationships[:controlled_behaviors].child_model

          control_methods.each do |name|
            behavior = Ronin::Control::Behavior.predefined_resource(name)
            self.behaviors << behavior_model.new(:behavior => behavior)
          end
        end
      end
    end
  end
end
