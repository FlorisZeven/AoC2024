require_relative '../aoc'
require_relative '../helpers/graph'
require 'set'

class ChronospatialComputerSolver < AoCExerciseSolver
  def initialize(*args)
    @registers = {}
    super
  end

  def preprocess
    parse_lines do |line|
      if line.include?('Register A')
        @registers['a'] = line.scan(/\d+/).first.to_i
      elsif line.include?('Register B')
        @registers['b'] = line.scan(/\d+/).first.to_i
      elsif line.include?('Register C')
        @registers['c'] = line.scan(/\d+/).first.to_i
      elsif line.include?('Program')
        @program = line.scan(/\d+/).join
      end
    end
  end

  def solve_part_1
    computer = ChronoSpatialComputer.new(@registers['a'], @registers['b'], @registers['c'])
    result = computer.execute_program(@program)
    result.chars.join(',')
  end

  def solve_part_2
    @computer = ChronoSpatialComputer.new(0, 0, 0)

    @part_2_options = []
    # Browse the unique integers for the first bit of the register
    (0..7).each do |i|
      find_register_for_program(i, 1)
    end
    @part_2_options.min
  end

  # Find register values that are substrings of the end result
  def find_register_for_program(register_a, bits_processed)
    @computer.reset_computer(register_a, 0, 0)
    result = @computer.execute_program(@program)

    @part_2_options << register_a if result == @program

    # No need to process
    return if bits_processed == @program.length || !@program.end_with?(result)

    # Because the results overlap so far, and the processor is 3-bit,
    # we can determine whether 3-bit-shifting left (times 2^3) with unique integer
    # values (+i) still yields correct results
    (0..7).each do |i|
      next_register_a = (register_a * 8) + i
      find_register_for_program(next_register_a, bits_processed + 1)
    end
  end
end

class ChronoSpatialComputer
  attr_accessor :register_a, :register_b, :register_c
  attr_reader :instruction_pointer, :output

  OPCODES = {
    0 => 'adv', 1 => 'bxl', 2 => 'bst', 3 => 'jnz', 4 => 'bxc',
    5 => 'out', 6 => 'bdv', 7 => 'cdv'
  }.freeze

  def initialize(a, b, c)
    reset_computer(a, b, c)
  end

  # @param [<<Integer, Integer>>] instructions a list of instructions
  def execute_program(program)
    until program[@instruction_pointer].nil? || program[@instruction_pointer + 1].nil?
      opcode = program[@instruction_pointer].to_i
      operand = program[@instruction_pointer + 1].to_i
      instruct(opcode, operand)
    end
    @output
  end

  def reset_computer(a, b, c)
    @register_a = a
    @register_b = b
    @register_c = c
    @output = ''
    @instruction_pointer = 0
  end

  private

  def pp_next_instruction(program)
    puts "#{OPCODES[program[@instruction_pointer].to_i]} #{program[@instruction_pointer + 1]}"
  end

  def pp_computer
    pp [@register_a, @register_b, @register_c, @output]
  end

  # @param [<Integer, Integer>] instruction an instruction
  def instruct(opcode, operand)
    send(:"#{OPCODES[opcode]}", operand)

    # Update instruction pointer
    # Jump updates the instruction pointer itself
    @instruction_pointer += 2 unless OPCODES[opcode] == 'jnz'
  end

  def value_for_combo_operand(operand)
    case operand
    when 0, 1, 2, 3 then operand
    when 4 then @register_a
    when 5 then @register_b
    when 6 then @register_c
    when 7 then raise 'invalid program'
    else raise "Unknown combo operand: #{operand}"
    end
  end

  # Shared between adv bdv cdv
  def division(operand)
    (@register_a / 2**value_for_combo_operand(operand)).to_i
  end

  # 0
  def adv(operand)
    @register_a = division(operand)
  end

  # 1
  def bxl(operand)
    @register_b ^= operand
  end

  # 2
  def bst(operand)
    @register_b = value_for_combo_operand(operand) % 8
  end

  # 3
  def jnz(operand)
    @register_a.zero? ? @instruction_pointer += 2 : @instruction_pointer = operand
  end

  # 4
  def bxc(_operand)
    @register_b ^= @register_c
  end

  # 5
  def out(operand)
    @output += (value_for_combo_operand(operand) % 8).to_s
  end

  # 6
  def bdv(operand)
    @register_b = division(operand)
  end

  # 7
  def cdv(operand)
    @register_c = division(operand)
  end
end

test_solver = ChronospatialComputerSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = ChronospatialComputerSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve