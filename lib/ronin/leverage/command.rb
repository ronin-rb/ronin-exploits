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
  module Leverage
    class Command

      include Enumerable

      def initialize(session,program,*arguments)
        @session = session
        @program = program
        @arguments = arguments
      end

      def each(&block)
        return enum_for(:each_line) unless block

        @session.shell_exec(@program,*@arguments,&block)
      end

      alias each_line each
      alias lines each_line

      def each_byte(&block)
        return enum_for(:each_byte) unless block

        each_line { |line| line.each_byte(&block) }
      end

      alias bytes each_byte

      def each_char
        return enum_for(:each_char) unless block_given?

        each_byte { |b| yield b.chr }
      end

      alias chars each_char

      def to_s
        each_line.inject('') { |output,line| output << line }
      end

    end
  end
end
