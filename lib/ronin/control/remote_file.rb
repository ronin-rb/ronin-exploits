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

module Ronin
  module Control
    #
    # Represents a remote file being controlled.
    #
    class RemoteFile < StringIO

      # Path to the file
      attr_reader :path

      #
      # Creates a new {RemoteFile} object.
      #
      # @param [String] path
      #   The path of the remote file.
      #
      # @param [String] body
      #   The body of the remote file.
      #
      # @since 0.4.0
      #
      def initialize(path,body='')
        super(body)

        @path = path
      end

      alias contents string
      alias contents= string=
      alias to_s string

      #
      # Inspects the remote file.
      #
      # @return [String]
      #   The inspected remote file.
      #
      # @since 0.4.0
      #
      def inspect
        "#<#{self.class}:#{@path}>"
      end

    end
  end
end
