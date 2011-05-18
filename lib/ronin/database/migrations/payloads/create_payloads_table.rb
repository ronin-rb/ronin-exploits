#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2011 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of Ronin Exploits.
#
# Ronin is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ronin is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ronin.  If not, see <http://www.gnu.org/licenses/>
#

require 'ronin/database/migrations/migrations'
require 'ronin/database/migrations/create_licenses_table'
require 'ronin/database/migrations/create_script_paths_table'

module Ronin
  module Database
    module Migrations
      migration(
        :create_payloads_table, :needs => [
          :create_licenses_table,
          :create_script_paths_table
        ]
      ) do
        up do
          create_table(:ronin_payloads_payloads) do
            column :id, Serial
            column :type, String, :not_null => true
            column :name, String, :not_null => true
            column :description, Ronin::Model::Types::Description
            column :version, String, :default => '0.1'
            column :license_id, Integer
            column :script_path_id, Integer
            column :arch_id, Integer
            column :os_id, Integer

            # needed by Exploits::RempteTCP and Exploits::RemoteUDP
            column :default_port, Integer

            # needed by Exploits::Web
            column :url_path, String
            column :url_query, String
          end

          create_table :ronin_author_payloads do
            column :id, Serial
            column :author_id, Integer, :not_null => true
            column :payload_id, Integer, :not_null => true
          end
        end

        down do
          drop_table :ronin_author_payloads
          drop_table :ronin_payloads_payloads
        end
      end
    end
  end
end
