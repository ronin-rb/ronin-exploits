module Ronin
  module Sessions
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
