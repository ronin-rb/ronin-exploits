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

require 'ronin/model/has_name'
require 'ronin/model/has_description'
require 'ronin/model/targets_arch'
require 'ronin/model/targets_os'
require 'ronin/cacheable'

require 'parameters'

module Ronin
  module Payloads
    module Encoders
      class Encoder

        include Parameters
        include Cacheable
        include Model::HasName
        include Model::HasDescription
        include Model::TargetsArch
        include Model::TargetsOS

        #
        # Creates a new Ronin::Payload::Encoder object using the given
        # _block_.
        #
        #   ronin_payload_encoder do
        #     ...
        #   end
        #
        contextify :ronin_payload_encoder

        # Primary key of the payload
        property :id, Serial

        #
        # Creates a new Encoder object with the given _arguments_.
        #
        def initialize(*arguments)
          super(*arguments)

          initialize_params(*arguments)
        end

        #
        # Default method which will encode the specified _data_.
        # Returns the specified _data_ by default.
        #
        def encode(data)
          data
        end

        #
        # Returns the name of the payload encoder.
        #
        def to_s
          self.name.to_s
        end

        #
        # Inspects the contents of the payload encoder.
        #
        def inspect
          str = "#{self.class}: #{self}"
          str << " #{self.params.inspect}" unless self.params.empty?

          return "#<#{str}>"
        end

      end
    end
  end
end
