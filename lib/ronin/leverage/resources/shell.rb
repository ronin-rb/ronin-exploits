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
require 'ronin/leverage/command'
require 'ronin/ui/shell'

require 'date'

module Ronin
  module Leverage
    module Resources
      class Shell < Resource

        def command(program,*arguments)
          Command.new(@leverage,program,*arguments)
        end

        def exec(program,*arguments)
          cmd = command(program,*arguments)

          if block_given?
            cmd.each { |line| yield line.rstrip }
          else
            cmd.read
          end
        end

        def system(command,*arguments)
          exec(command,*arguments) { |line| puts line }
        end

        def cd(path)
          command('cd',path).first
        end

        def pwd
          command('pwd').first.rstrip
        end

        def ls(*arguments,&block)
          exec('ls',*arguments,&block)
        end

        def ls_a(*arguments,&block)
          exec('ls','-a',*arguments,&block)
        end

        def ls_l(*arguments,&block)
          exec('ls','-l',*arguments,&block)
        end

        def ls_la(*arguments,&block)
          exec('ls','-la',*arguments,&block)
        end

        def find(*arguments)
          if block_given?
            exec('find',*arguments) { |line| yield line.rstrip }
          else
            enum_for(:find,*arguments).to_a
          end
        end

        def file(*arguments)
          command('file',*arguments).first
        end

        def which(*arguments)
          command('which',*arguments).first
        end

        def cat(*arguments,&block)
          exec('cat',*arguments,&block)
        end

        def head(*arguments,&block)
          exec('head',*arguments,&block)
        end

        def head_n(lines,*arguments,&block)
          head('-n',lines,*arguments,&block)
        end

        def tail(*arguments,&block)
          exec('tail',*arguments,&block)
        end

        def tail_n(*arguments,&block)
          tail('-n',lines,*arguments,&block)
        end

        def grep(*arguments,&block)
          if block_given?
            exec('grep',*arguments) do |line|
              yield(*line.split(':',2))
            end
          else
            enum_for(:grep,*arguments).to_a
          end
        end

        def egrep(*arguments,&block)
          exec('egrep',*arguments,&block)
        end

        def touch(*arguments)
          command('touch',*arguments).first
        end

        def mktemp(*arguments)
          command('mktemp',*arguments).first.rstrip
        end

        def mktempdir(*arguments)
          mktemp('-d',*arguments)
        end

        def mkdir(*arguments)
          command('mkdir',*arguments).first
        end

        def cp(*arguments)
          command('cp',*arguments).first
        end

        def cp_r(*arguments)
          cp('-r',*arguments)
        end

        def cp_a(*arguments)
          cp('-a',*arguments)
        end

        def rsync(*arguments,&block)
          exec('rsync',*arguments,&block)
        end

        def rsync_a(*arguments,&block)
          rsync('-a',*arguments,&block)
        end

        def wget(*arguments)
          exec('wget',*arguments)
        end

        def wget_out(path,*arguments)
          wget('-O',path,*arguments)
        end

        def curl(*arguments)
          exec('curl',*arguments)
        end

        def curl_out(path,*arguments)
          curl('-O',path,*arguments)
        end

        def rmdir(*arguments)
          command('rmdir',*arguments).first
        end

        def rm(*arguments,&block)
          exec('rm',*arguments,&block)
        end

        def rm_r(*arguments,&block)
          rm('-r',*arguments,&block)
        end

        def rm_rf(*arguments,&block)
          rm('-rf',*arguments,&block)
        end

        def date
          Date.parse(exec('date'))
        end

        def time
          date.to_time
        end

        def id
          exec('id')
        end

        def uid
          exec('id','-u').to_i
        end

        def gid
          exec('id','-g').to_i
        end

        def whoami(*arguments)
          exec('whoami',*arguments)
        end

        def who(*arguments,&block)
          exec('who',*arguments,&block)
        end

        def w(*arguments,&block)
          exec('w',*arguments,&block)
        end

        def lastlog(*arguments,&block)
          exec('lastlog',*arguments,&block)
        end

        def faillog(*arguments,&block)
          exec('faillog',*arguments,&block)
        end

        def ps(*arguments,&block)
          exec('ps',*arguments,&block)
        end

        def ps_axu(*arguments,&block)
          ps('aux',*arguments,&block)
        end

        def kill(*arguments)
          command('kill',*arguments).first
        end

        def ifconfig(*arguments,&block)
          exec('ifconfig',*arguments,&block)
        end

        def netstat(*arguments,&block)
          exec('netstat',*arguments,&block)
        end

        def netstat_anp(*arguments,&block)
          netstat('-anp',*arguments,&block)
        end

        def ping(*arguments,&block)
          exec('ping',*arguments,&block)
        end

        def nc(*arguments,&block)
          exec('nc',*arguments,&block)
        end

        def nc_listen(port,*arguments,&block)
          nc('-l',port,*arguments,&block)
        end

        def nc_connect(host,port,*arguments,&block)
          nc(host,port,*arguments,&block)
        end

        def gcc(*arguments,&block)
          exec('gcc',*arguments,&block)
        end

        def cc(*arguments,&block)
          exec('cc',*arguments,&block)
        end

        def perl(*arguments,&block)
          exec('perl',*arguments,&block)
        end

        def python(*arguments,&block)
          exec('python',*arguments,&block)
        end

        def ruby(*arguments,&block)
          exec('ruby',*arguments,&block)
        end

        def exit
          exec('exit')
        end

        def console
          UI::Shell.start(:prompt => '$') do |shell,line|
            command(line).each_block { |block| shell.write(block) }
          end
        end

      end
    end
  end
end
