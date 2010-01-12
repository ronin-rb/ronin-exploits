#
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
#

require 'ronin/control/behavior'

module Ronin
  module Control
    module API
      protected

      #
      # Prepares the resource to be cached.
      #
      # If resource has a relationship named +controlled_behaviors+ and
      # if there are any methods named after behaviors defined in
      # {Control::Behavior}, then behaviors from {Control::Behavior} will
      # be added to the +controlled_behaviors+ relationship.
      #
      def cache(&block)
        super(&block)

        if self.class.relationships.has_key?(:controlled_behaviors)
          behavior_model = self.class.relationships[:controlled_behaviors].child_model

          Ronin::Controls::Behavior.predefined_names.each do |name|
            if respond_to?(name)
              behavior = Ronin::Control::Behavior.predefined_resource(name)
              self.behaviors << behavior_model.new(:behavior => behavior)
            end
          end
        end
      end
    end
  end
end
