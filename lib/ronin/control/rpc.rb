#
#--
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
#++
#

require 'ronin/control/exceptions/not_implemented'

module Ronin
  module Control
    module RPC
      def self.included(base)
        base.module_eval do
          #
          # Exposes the method with the specified _name_.
          #
          def self.expose_method(name)
            define_method(name) do |*arguments|
              call_method(name,*arguments)
            end
          end
        end
      end

      #
      # Calls the specified _method_ with the given _arguments_.
      # Returns the return-value of the method-call.
      #
      def call_method(method,*arguments)
        raise(NotImplemented,"the call method is unimplemented",caller)
      end

      #
      # Evaluates the specified _code_.
      #
      def eval(code)
        call_method(:eval,code)
      end

      #
      # Exits with the given _status_.
      #
      def exit(status=0)
        call_method(:exit,status)
      end

      protected

      #
      # Provides transparent access to remote methods using the
      # specified _name_ and given _arguments_.
      #
      def method_missing(name,*arguments,&block)
        name = name.to_s

        if (name[-1..-1] != '=' && block.nil?)
          return call_method(name,*arguments)
        end

        return super(name,*arguments,&block)
      end
    end
  end
end
