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

require 'ronin/database/migrations/migrations'

require 'ronin/database/migrations/payloads/create_payloads_table'

module Ronin
  module Database
    module Migrations
      migration(
        :create_payloads_encoders_table,
        :needs => :create_payloads_table
      ) do
        up do
          create_table(:ronin_payloads_encoders) do
            column :id, Serial
            column :type, String, :not_null => true
            column :name, String, :not_null => true
            column :description, Ronin::Model::Types::Description
            column :arch_id, Integer
            column :os_id, Integer
            column :product_id, Integer
          end
        end

        down do
          drop_table :ronin_exploits_targets
        end
      end
    end
  end
end
