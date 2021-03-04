#
# ronin-exploits - A Ruby library for Ronin that provides exploitation and
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
# along with Ronin.  If not, see <http://www.gnu.org/licenses/>
#

require 'ronin/gen/ruby_generator'
require 'ronin/payloads/config'
require 'ronin/author'

module Ronin
  module Gen
    module Generators
      module Payloads
        #
        # Generates a new ronin payload file.
        #
        class Payload < RubyGenerator

          data_dir File.join('ronin','gen','payloads')

          template 'payload.erb'

          parameter :helpers, type:    Array[Symbol],
                              default: []

          parameter :name, type:    String,
                           default: 'Payload'

          parameter :version, type:    String,
                              default: '0.1'

          parameter :description, type:    String,
                                  default: 'This is a payload.'

          parameter :authors, type:    Array,
                              default: ['Anonymous']

          parameter :arch, type: Symbol

          parameter :os, type: String

          parameter :os_version, type: String

        end
      end
    end
  end
end
