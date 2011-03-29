#
# Ronin Exploits - A Ruby library for Ronin that provides exploitation and
# payload crafting functionality.
#
# Copyright (c) 2007-2011 Hal Brodigan (postmodern.mod3 at gmail.com)
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
      #
      # Leverages the resources of a Shell.
      #
      class Shell < Resource

        attr_reader :paths

        #
        # Initializes the Shell resource.
        #
        # @param [#shell_exec] leverage
        #   The object leveraging the command-execution.
        #
        # @since 0.4.0
        #
        def initialize(leverage)
          super(leverage)

          @paths = {}
        end

        #
        # Creates a command to later execute.
        #
        # @param [String] program
        #   The program name or path to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to run the program with.
        #
        # @return [Command]
        #   The newly created command.
        #
        # @since 0.4.0
        #
        def command(program,*arguments)
          program = (@paths[program.scan(/^[^\s]+/).first] || program)

          return Command.new(@leverage,program,*arguments)
        end

        #
        # Executes a command and reads the resulting output.
        #
        # @param [String] program
        #   The program name or path to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to run the program with.
        #
        # @yield [line]
        #   If a block is given, it will be passed each line of output
        #   from the command.
        #
        # @yieldparam [String] line
        #   A line of output from the command.
        #
        # @return [String, nil]
        #   If no block is given, the full output of the command will be
        #   returned.
        #
        # @since 0.4.0
        #
        def exec(program,*arguments)
          cmd = command(program,*arguments)

          if block_given?
            cmd.each { |line| yield line.chomp }
          else
            cmd.read
          end
        end

        #
        # Executes a command and prints the resulting output.
        #
        # @param [String] program
        #   The program name or path to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to run the program with.
        #
        # @return [nil]
        #
        # @since 0.4.0
        #
        def system(command,*arguments)
          exec(command,*arguments) { |line| puts line }
        end

        #
        # Changes the current working directory in the shell.
        #
        # @param [String] path
        #   The path for the new current working directory.
        #
        # @return [String]
        #   Any error messages.
        #
        # @since 0.4.0
        #
        def cd(path)
          command('cd',path).first
        end

        #
        # Gets the current working directory.
        #
        # @return [String]
        #   The path of the current working directory.
        #
        # @since 0.4.0
        #
        def pwd
          command('pwd').first.chomp
        end

        #
        # Lists the files or directories.
        #
        # @param [Array<String>] arguments
        #   Arguments to pass to the `ls` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def ls(*arguments,&block)
          exec('ls',*arguments,&block)
        end

        #
        # Lists all files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ls -a` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def ls_a(*arguments,&block)
          exec('ls','-a',*arguments,&block)
        end

        #
        # Lists information about files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ls -l` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def ls_l(*arguments,&block)
          exec('ls','-l',*arguments,&block)
        end

        #
        # Lists information about all files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ls -la` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def ls_la(*arguments,&block)
          exec('ls','-la',*arguments,&block)
        end

        #
        # Searches for files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `find` command.
        #
        # @yield [path]
        #   If a block is given, it will be passed each path found.
        #
        # @yieldparam [String] path
        #   A path found by the `find` command.
        #
        # @return [Array<String>, nil]
        #   If no block is given, all found paths will be returned.
        #
        # @since 0.4.0
        #
        def find(*arguments)
          if block_given?
            exec('find',*arguments) { |line| yield line.chomp }
          else
            enum_for(:find,*arguments).to_a
          end
        end

        #
        # Determines the format of a file.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `file` command.
        #
        # @return [String]
        #   The output of the `file` command.
        #
        # @example
        #   exploit.shell.file('data.db')
        #   # => "data.db: SQLite 3.x database"
        #
        # @since 0.4.0
        #
        def file(*arguments)
          command('file',*arguments).first
        end

        #
        # Finds a program available to the shell.
        #
        # @param [Array<String>] arguments
        #   Additional arguments ot pass to the `which` command.
        #
        # @return [String]
        #   The output from the `which` command.
        #
        # @since 0.4.0
        #
        def which(*arguments)
          command('which',*arguments).first
        end

        #
        # Reads the contents of one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `cat` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def cat(*arguments,&block)
          exec('cat',*arguments,&block)
        end

        #
        # Reads the first `n` lines of one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `head` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def head(*arguments,&block)
          exec('head',*arguments,&block)
        end

        #
        # Reads the first `n` lines of one or more files.
        #
        # @param [Integer] lines
        #   The number of lines to read from one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `head` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def head_n(lines,*arguments,&block)
          head('-n',lines,*arguments,&block)
        end

        #
        # Reads the last `n` lines of one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `tail` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def tail(*arguments,&block)
          exec('tail',*arguments,&block)
        end

        #
        # Reads the last `n` lines of one or more files.
        #
        # @param [Integer] lines
        #   The number of lines to read from one or more files.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `tail` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def tail_n(*arguments,&block)
          tail('-n',lines,*arguments,&block)
        end

        #
        # Searches one or more files for a given pattern.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `grep` command.
        #
        # @yield [path, line]
        #   If a block is given, it will be passed the paths and lines
        #   within files that matched the given pattern.
        #
        # @yieldparam [String] path
        #   The path of a file that contains matching lines.
        #
        # @yieldparam [String] line
        #   A line that matches the given pattern.
        #
        # @return [Array<String>, nil]
        #   If no block is given, all matching paths and lines will be
        #   returned.
        #
        # @since 0.4.0
        #
        def grep(*arguments,&block)
          if block_given?
            exec('grep',*arguments) do |line|
              yield(*line.split(':',2))
            end
          else
            enum_for(:grep,*arguments).to_a
          end
        end

        #
        # Runs `grep -E`.
        #
        # @see #grep
        #
        # @since 0.4.0
        #
        def egrep(*arguments,&block)
          grep('-E',*arguments,&block)
        end

        #
        # Runs `grep -F`.
        #
        # @see #grep
        #
        # @since 0.4.0
        #
        def fgrep(*arguments,&block)
          grep('-F',*arguments,&block)
        end

        #
        # Touches a file.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `touch` command.
        #
        # @return [String]
        #   Any error messages returned by the `touch` command.
        #
        # @since 0.4.0
        #
        def touch(*arguments)
          command('touch',*arguments).first
        end

        #
        # Creates a tempfile.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to `mktemp`.
        #
        # @return [String]
        #   The path of the new tempfile.
        #
        # @since 0.4.0
        #
        def mktemp(*arguments)
          command('mktemp',*arguments).first.chomp
        end

        #
        # Creates a tempdir.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to `mktemp`.
        #
        # @return [String]
        #   The path of the new tempdir.
        #
        # @since 0.4.0
        #
        def mktempdir(*arguments)
          mktemp('-d',*arguments)
        end

        #
        # Creates a new directory.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `mkdir` command.
        #
        # @return [String]
        #   Any error messages returned by the `mkdir` command.
        #
        # @since 0.4.0
        #
        def mkdir(*arguments)
          command('mkdir',*arguments).first
        end

        #
        # Copies one or more files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `cp` command.
        #
        # @return [String]
        #   Any error messages returned by the `cp` command.
        #
        # @since 0.4.0
        #
        def cp(*arguments)
          command('cp',*arguments).first
        end

        #
        # Runs `cp -r`.
        #
        # @see #cp
        #
        # @since 0.4.0
        #
        def cp_r(*arguments)
          cp('-r',*arguments)
        end

        #
        # Runs `cp -a`.
        #
        # @see #cp
        #
        # @since 0.4.0
        #
        def cp_a(*arguments)
          cp('-a',*arguments)
        end

        #
        # Runs `rsync`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rsync` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def rsync(*arguments,&block)
          exec('rsync',*arguments,&block)
        end

        #
        # Runs `rsync -a`.
        #
        # @see #rsync
        #
        # @since 0.4.0
        #
        def rsync_a(*arguments,&block)
          rsync('-a',*arguments,&block)
        end

        #
        # Runs `wget`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rsync` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def wget(*arguments)
          exec('wget','-q',*arguments)
        end

        #
        # Runs `wget -O`.
        #
        # @param [String] path
        #   The path that `wget` will write to.
        #
        # @see #wget
        #
        # @since 0.4.0
        #
        def wget_out(path,*arguments)
          wget('-O',path,*arguments)
        end

        #
        # Runs the `curl`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `curl` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def curl(*arguments)
          exec('curl','-s',*arguments)
        end

        #
        # Runs `curl -O`.
        #
        # @param [String] path
        #   The path that `curl` will write to.
        #
        # @see #curl
        #
        # @since 0.4.0
        #
        def curl_out(path,*arguments)
          curl('-O',path,*arguments)
        end

        #
        # Removes a directory.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rmdir` command.
        #
        # @return [String]
        #   Any error messages returned by the `rmdir` command.
        #
        # @since 0.4.0
        #
        def rmdir(*arguments)
          command('rmdir',*arguments).first
        end

        #
        # Removes one or more files or directories.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `rm` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def rm(*arguments,&block)
          exec('rm',*arguments,&block)
        end

        #
        # Runs `rm -r`.
        #
        # @see #rm
        #
        # @since 0.4.0
        #
        def rm_r(*arguments,&block)
          rm('-r',*arguments,&block)
        end

        #
        # Runs `rm -rf`.
        #
        # @see #rm
        #
        def rm_rf(*arguments,&block)
          rm('-rf',*arguments,&block)
        end

        #
        # Gets the current time and date from the shell.
        #
        # @return [Date]
        #   The current data returned by the shell.
        #
        # @since 0.4.0
        #
        def date
          Date.parse(exec('date'))
        end

        #
        # Gets the current time from the shell.
        #
        # @return [Time]
        #   The current time returned by the shell.
        #
        # @since 0.4.0
        #
        def time
          date.to_time
        end

        #
        # The ID information of the current user.
        #
        # @return [String]
        #   The ID information returned by the `id` command.
        #
        # @since 0.4.0
        #
        def id
          exec('id')
        end

        #
        # The UID of the current user.
        #
        # @return [Integer]
        #   The UID of the current user.
        #
        # @since 0.4.0
        #
        def uid
          exec('id','-u').to_i
        end

        #
        # The GID of the current user.
        #
        # @return [Integer]
        #   The GID of the current user.
        #
        # @since 0.4.0
        #
        def gid
          exec('id','-g').to_i
        end

        #
        # The name of the current user.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `whoami` command.
        #
        # @return [String]
        #   The name of the current user returned by the `whoami` command.
        #
        # @since 0.4.0
        #
        def whoami(*arguments)
          exec('whoami',*arguments)
        end

        #
        # Shows who is currently logged in.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `who` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def who(*arguments,&block)
          exec('who',*arguments,&block)
        end

        #
        # Similar to {#who} but runs the `w` command.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `w` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def w(*arguments,&block)
          exec('w',*arguments,&block)
        end

        #
        # Shows when users last logged in.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `lastlog` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def lastlog(*arguments,&block)
          exec('lastlog',*arguments,&block)
        end

        #
        # Shows login failures.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `faillog` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def faillog(*arguments,&block)
          exec('faillog',*arguments,&block)
        end

        #
        # Shows the current running processes.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ps` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def ps(*arguments,&block)
          exec('ps',*arguments,&block)
        end

        #
        # Runs `ps aux`.
        #
        # @see #ps
        #
        # @since 0.4.0
        #
        def ps_axu(*arguments,&block)
          ps('aux',*arguments,&block)
        end

        #
        # Kills a current running process.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `kill` command.
        #
        # @return [String]
        #   Output from the `kill` command.
        #
        def kill(*arguments)
          command('kill',*arguments).first
        end

        #
        # Shows information about network interfaces.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ifconfig` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def ifconfig(*arguments,&block)
          exec('ifconfig',*arguments,&block)
        end

        #
        # Shows network connections.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `netstat` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def netstat(*arguments,&block)
          exec('netstat',*arguments,&block)
        end

        #
        # Runs `netstat -anp`.
        #
        # @see #netstat
        #
        # @since 0.4.0
        #
        def netstat_anp(*arguments,&block)
          netstat('-anp',*arguments,&block)
        end

        #
        # Pings an IP address.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ping` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def ping(*arguments,&block)
          exec('ping',*arguments,&block)
        end

        #
        # Runs net-cat.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `nc` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def nc(*arguments,&block)
          exec('nc',*arguments,&block)
        end

        #
        # Runs `nc -l`.
        #
        # @see #nc
        #
        # @since 0.4.0
        #
        def nc_listen(port,*arguments,&block)
          nc('-l',port,*arguments,&block)
        end

        #
        # Connects to a host using net-cat.
        #
        # @param [String] host
        #   The host to connect to.
        #
        # @param [Integer] port
        #   The port to connect to.
        #
        # @see #nc
        #
        # @since 0.4.0
        #
        def nc_connect(host,port,*arguments,&block)
          nc(host,port,*arguments,&block)
        end

        #
        # Compiles some C source-code with `gcc`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `gcc` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def gcc(*arguments,&block)
          exec('gcc',*arguments,&block)
        end

        #
        # Compiles some C source-code with `cc`.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `cc` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def cc(*arguments,&block)
          exec('cc',*arguments,&block)
        end

        #
        # Runs a PERL script.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `perl` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def perl(*arguments,&block)
          exec('perl',*arguments,&block)
        end

        #
        # Runs a Python script.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `python` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def python(*arguments,&block)
          exec('python',*arguments,&block)
        end

        #
        # Runs a Ruby script.
        #
        # @param [Array<String>] arguments
        #   Additional arguments to pass to the `ruby` command.
        #
        # @see #exec
        #
        # @since 0.4.0
        #
        def ruby(*arguments,&block)
          exec('ruby',*arguments,&block)
        end

        #
        # Exits the shell.
        #
        def exit
          exec('exit')
        end

        #
        # Starts an interactive Shell console.
        #
        def console
          UI::Shell.start(:prompt => '$') do |shell,line|
            command(line).each_block { |block| shell.write(block) }
          end
        end

      end
    end
  end
end
