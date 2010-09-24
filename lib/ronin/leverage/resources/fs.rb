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
require 'ronin/leverage/file'
require 'ronin/leverage/file/stat'
require 'ronin/ui/hexdump/hexdump'

require 'digest/md5'

module Ronin
  module Leverage
    module Resources
      class FS < Resource

        def open(path,&block)
          File.open(@leverage,path,&block)
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
          requires_method! :fs_copy

          @leverage.fs_copy(path,new_path)
        end

        def unlink(path)
          requires_method! :fs_unlink

          @leverage.fs_unlink(path)
        end

        alias rm unlink

        def rmdir(path)
          requires_method! :fs_rmdir

          @leverage.fs_rmdir(path)
        end

        def move(path,new_path)
          requires_method! :fs_move

          @leverage.fs_move(path,new_path)
        end

        alias rename move

        def link(path,new_path)
          requires_method! :fs_link

          @leverage.fs_link(path,new_path)
        end

        def chown(*arguments)
          requires_method! :fs_chmod

          @leverage.fs_chmod(*arguments)
        end

        def chgrp(*arguments)
          requires_method! :fs_chgrp

          @leverage.fs_chgrp(*arguments)
        end

        def chmod(*arguments)
          requires_method! :fs_chmod

          @leverage.fs_chmod(*arguments)
        end

        def stat(path)
          File::Stat.new(@leverage,path)
        end

        def compare(path,other_path)
          checksum1 = Digest::MD5.new
          open(path).each_block { |block| checksum1 << block }

          checksum2 = Digest::MD5.new
          open(other_path).each_block { |block| checksum2 << block }

          return checksum1 == checksum2
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

        def console
          UI::Shell.start(:prompt => 'fs>') do |shell,line|
            args = line.strip.split(' ')

            case args[0]
            when 'read'
              shell.write(read(args[1]))
            when 'hexdump'
              hexdump(args[1],shell)
            when 'copy'
              copy(args[1],args[2])
            when 'rmdir'
              rmdir(args[1])
            when 'rm'
              unlink(args[1])
            when 'move'
              move(args[1],args[2])
            when 'chown'
              chown(*args[1..-1])
            when 'chgrp'
              chgrp(*args[1..-1])
            when 'chmod'
              chmod(*args[1..-1])
            when 'stat'
              stat(args[1])
            when 'help'
              shell.puts(
                "read PATH\t\t\treads data from the given PATH",
                "hexdump FILE\t\t\thexdumps the given FILE",
                "copy SRC DEST\t\t\tcopies a file from SRC to DEST",
                "rmdir DIR\t\t\tremoves the given DIR",
                "rm FILE\t\t\t\tremoves the given FILE",
                "move SRC DEST\t\t\tmoves a file or directory from SRC to DEST",
                "ln SRC DEST\t\t\tlinks a file or directory from SRC to DEST",
                "chown USER [GROUP] LIST...\tchanges ownership on one or more paths",
                "chgrp GROUP LIST...\t\tchanges group ownership on one or more paths",
                "chmod MODE LIST...\t\tchanges permissions on one or more paths",
                "stat PATH\t\t\tlists status information about the PATH",
                "help\t\t\t\tthis message"
              )
            end
          end
        end

      end
    end
  end
end
