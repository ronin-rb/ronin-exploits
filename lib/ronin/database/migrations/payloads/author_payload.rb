#
# ronin-exploits - A Ruby library for ronin-rb that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2013 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-exploits.
#
# ronin-exploits is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-exploits is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ronin-exploits.  If not, see <https://www.gnu.org/licenses/>
#

require 'ronin/database/migrations/payloads/payload'
require 'ronin/database/migrations/author'

module Ronin
  module Database
    module Migrations
      migration :create_author_payloads_table,
                needs: [
                  :create_authors_table,
                  :create_payloads_table
                ] do
        up do
          create_table :ronin_author_payloads do
            column :id, Serial
            column :author_id, Integer, not_null: true
            column :payload_id, Integer, not_null: true
          end
        end

        down do
          drop_table :ronin_author_payloads
        end
      end
    end
  end
end
