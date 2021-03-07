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

module Ronin
  module Payloads
    module Helpers
      #
      # Payload helper which implements {PostExploitation} methods via
      # shell commands.
      #
      module Shell
        def fs_getcwd
          shell.pwd
        end

        def fs_chdir(path)
          shell.cd(path)
          return shell.pwd
        end

        def fs_readdir(path)
          shell.ls(path)
        end

        def fs_glob(pattern,&block)
          shell.find(pattern,&block)
        end

        def fs_read(path,pos)
          shell.exec('dd',"if=#{path}",'bs=1',"skip=#{pos}",'count=4096')
        end

        def fs_write(path,pos,data)
          escaped = data.gsub('%','%%').dump

          shell.exec("printf #{escaped} | dd if=#{path} bs=1 skip=#{pos} count=4096")
        end

        def fs_mktemp(basename)
          shell.mktemp(basename)
        end

        def fs_mkdir(path)
          shell.mkdir(path)
        end

        def fs_copy(path,new_path)
          shell.cp(path,new_path).empty?
        end

        def fs_unlink(path)
          shell.rm(path).empty?
        end

        def fs_rmdir(path)
          shell.rmdir(path).empty?
        end

        def fs_move(path,new_path)
          shell.mv(path,new_path).empty?
        end

        def fs_chown(user,path)
          shell.chown(user,path).empty?
        end

        def fs_chgrp(group,path)
          shell.chgrp(group,path).empty?
        end

        def fs_chmod(mode,path)
          shell.chmod("%.4o" % mode,path).empty?
        end

        def fs_stat(path)
          fields = shell.exec('stat','-t',path).strip.split(' ')

          return {
            path: path,
            size: fields[1].to_i,
            blocks: fields[2].to_i,
            uid: fields[4].to_i,
            gid: fields[5].to_i,
            inode: fields[7].to_i,
            links: fields[8].to_i,
            atime: Time.at(fields[11].to_i),
            mtime: Time.at(fields[12].to_i),
            ctime: Time.at(fields[13].to_i),
            blocksize: fields[14].to_i
          }
        end

        def process_getuid
          shell.uid
        end

        def process_getgid
          shell.gid
        end

        def process_getenv(name)
          shell.exec('echo',"$#{name}")
        end

        def process_setenv(name,value)
          shell.exec('export',"#{name}=#{value}")
        end

        def process_unsetenv(name)
          shell.exec('unset',name)
        end

        def process_kill(pid)
          shell.kill(pid)
        end

        def process_time
          shell.time
        end

        def process_spawn(program,*arguments)
          arguments += %w[2>&1 >/dev/null]

          shell.exec(program,*arguments)
        end

        def process_exit
          shell.exit
        end
      end
    end
  end
end
