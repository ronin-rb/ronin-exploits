#
# ronin-exploits - A Ruby library for ronin-rb that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2013 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-exploits.
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
# along with Ronin.  If not, see <https://www.gnu.org/licenses/>
#

require 'ronin/database/migrations/script/path'

module Ronin
  module Database
    module Migrations
      migration :create_encoders_table,
                needs: :create_script_paths_table do
        up do
          create_table :ronin_encoders_encoders do
            column :id, Serial
            column :type, String, not_null: true
            column :name, String, not_null: true
            column :description, Ronin::Model::Types::Description
            column :arch_id, Integer
            column :os_id, Integer
            column :script_path_id, Integer
          end

          create_table :ronin_author_encoders_encoders do
            column :id, Serial
            column :author_id, Integer, not_null: true
            column :encoder_id, Integer, not_null: true
          end
        end

        down do
          drop_table :ronin_author_encoders_encoders
        end
      end
    end
  end
end
