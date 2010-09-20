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

require 'ronin/leverage/resources/resource'
require 'ronin/leverage/stat'
require 'ronin/leverage/file'
require 'ronin/ui/hexdump/hexdump'

module Ronin
  module Leverage
    module Resources
      class FS < Resource

        def open(path,&block)
          File.new(@leverage,path,&block)
        end

        def read(path)
          open(path).read
        end

        def hexdump(path,output=STDOUT)
          open(path) { |file| UI::Hexdump.dump(file,output) }
        end

        def write(path,data)
          open(path) { |file| file.write(data) }
        end

        def touch(path)
          open(path) { |file| file << data }
        end

        def copy(path,new_path)
          @leverage.fs_copy(path,new_path)
        end

        def move(path,new_path)
          @leverage.fs_move(path,new_path)
        end

        alias rename move

        def link(path,new_path)
          @leverage.fs_link(path,new_path)
        end

        def chown(path,owner)
          @leverage.fs_chmod(path,owner)
        end

        def chgrp(path,group)
          @leverage.fs_group(path,group)
        end

        def chmod(path,mod)
          @leverage.fs_chmod(path,mod)
        end

        def compare(path,other_path)
          @leverage.fs_compare(path,other_path)
        end

        def stat(path)
          @leverage.fs_stat(path)
        end

        def exists?(path)
          begin
            stat(path)
            return true
          rescue Errno::ENOENT
            return false
          end
        end

        def file?(path)
          begin
            stat(path).file?
          rescue Errno::ENOENT
            return false
          end
        end

        def directory?(path)
          begin
            stat(path).directory?
          rescue Errno::ENOENT
            return false
          end
        end

        def pipe?(path)
          begin
            stat(path).pipe?
          rescue Errno::ENOENT
            return false
          end
        end

        def socket?(path)
          begin
            stat(path).socket?
          rescue Errno::ENOENT
            return false
          end
        end

        def zero?(path)
          begin
            stat(path).zero?
          rescue Errno::ENOENT
            return false
          end
        end

      end
    end
  end
end
