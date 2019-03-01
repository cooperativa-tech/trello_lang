require "io/console"

module TrelloLang
  class VM
    MEM_SIZE = 1_024_000
    DEBUGGING = ENV["DEBUG"] == "1"

    def initialize(program)
      @dp = 0
      @ip = 0
      @mem = Array.new(MEM_SIZE, 0)
      @call_stack = []
      @program = program
      @ff = false
    end

    def run
      while ip < program.length
        run_instruction(program[ip])
        @ip += 1
      end
    end

    private

    attr_reader :dp, :ip, :mem, :call_stack, :program, :ff

    def run_instruction(instruction)
      with_debug do
        return noop_with_debug if ff && instruction != "]"

        y_lambda = {
          ">" => inc_dp,
          "<" => dec_dp,
          "+" => inc_byte,
          "-" => dec_byte,
          "." => p_buf,
          "," => rw_byte,
          "[" => opn_while,
          "]" => cls_while,
        }[instruction] || noop

        y_lambda.call
      end
    end

    def debugging?
      DEBUGGING
    end

    # Complex VM OPS - intentionally poorly named

    def opn_while
      -> do
        if mem[dp].zero?
          @ff = true
        elsif @call_stack.last != ip
          @call_stack.push(ip)
        end
      end
    end

    def cls_while
      -> do
        if ff
          @ff = false
          @call_stack.pop
          return
        else
          @ip = call_stack.last - 1
        end
      end
    end

    def noop_with_debug
      puts "noop-ing instruction" if debugging?

      noop.call
    end

    # Simple VM OPS - intentionally poorly named

    def noop
      -> {  }
    end

    def inc_dp
      -> { @dp += 1 }
    end

    def dec_dp
      -> { @dp -= 1 }
    end

    def inc_byte
      -> { @mem[dp] += 1 }
    end

    def dec_byte
      -> { @mem[dp] -= 1 }
    end

    def p_buf
      -> { puts @mem[0..dp] }
    end

    def rw_byte
      -> { @mem[dp] = STDIN.getch }
    end

    # Debug only

    def with_debug
      print_program_data if debugging?

      yield

      if debugging?
        separator = "=" * (program.length + 9)
        puts "#{separator}\n"
      end
    end

    def print_program_data
      puts "ip: #{ip}"
      puts "dp: #{dp}"
      puts "ff: #{ff}"
      puts "mem: #{mem[0..dp]}"
      puts "call_stack: #{call_stack}"
      puts "program: #{program}"
      puts " " * (9 + ip) + "^"
    end
  end
end
