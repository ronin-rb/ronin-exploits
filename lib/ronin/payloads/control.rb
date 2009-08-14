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

require 'ronin/vuln/behavior'
require 'ronin/payloads/payload'

require 'ronin/model'

module Ronin
  module Payloads
    class Control

      include Model

      # The primary key of the control
      property :id, Serial

      # The behavior the ability provides
      belongs_to :behavior, :model => 'Vuln::Behavior'

      # The payload which has this ability
      belongs_to :payload

      # Feature validations
      validates_present :behavior_id, :payload_id

    end
  end
end
