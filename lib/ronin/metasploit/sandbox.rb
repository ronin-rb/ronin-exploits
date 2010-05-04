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

require 'ronin/metasploit/metasploit'

if Ronin::Metasploit.activate!
  require 'msf/core'
  Msf::Module.send :include, Msf
else
  STDERR.puts "Could not load 'msf/core'"
end

module Ronin
  module Metasploit
    class Sandbox < Module

      # The namespace all metasploit modules are defined in
      NAMESPACE = 'Metasploit3'

      #
      # Attempts to load a metasploit module.
      #
      # @param [String] path
      #   The path of the module within the Metasploit root directory.
      #
      # @return [Object, nil]
      #   Returns the loaded module, or `nil` if the module could not be
      #   loaded.
      #
      # @since 0.4.0
      #
      def Sandbox.load(path)
        return nil unless Metasploit.root

        full_path = File.join(Metasploit.root,MODULES_DIR,path)
        return nil unless File.file?(full_path)

        sandbox = Sandbox.new
        sandbox.module_eval File.read(full_path)

        if sandbox.const_defined?(NAMESPACE)
          return sandbox.const_get(NAMESPACE).new()
        end
      end
    end
  end
end
