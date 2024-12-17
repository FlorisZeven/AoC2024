require_relative '../aoc'
require_relative '../helpers/graph'
require 'set'

class ChronospatialComputerSolver < AoCExerciseSolver
  def initialize(*args)
    @input = {}
    super
  end

  def preprocess
    parse_lines do |line|
      if line.include?('Register A')
        @input['a'] = line.scan(/\d+/).first.to_i
      elsif line.include?('Register B')
        @input['b'] = line.scan(/\d+/).first.to_i
      elsif line.include?('Register C')
        @input['c'] = line.scan(/\d+/).first.to_i
      elsif line.include?('Program')
        @input['program'] = line.scan(/\d+/).join
      end
    end
  end

  def solve_part_1
    computer = ChronoSpatialComputer.new(@input['a'], @input['b'], @input['c'])
    computer.perform_program(@input['program'])
  end

  def solve_part_2

  end
end

class ChronoSpatialComputer
  attr_accessor :register_a, :register_b, :register_c
  attr_accessor :instruction_pointer
  attr_reader :output

  OPCODES = {
    0 => 'adv', 1 => 'bxl', 2 => 'bst', 3 => 'jnz', 4 => 'bxc',
    5 => 'out', 6 => 'bdv', 7 => 'cdv'
  }.freeze

  def initialize(a, b, c)
    @register_a = a
    @register_b = b
    @register_c = c
    @instruction_pointer = nil
    @output = nil
  end

  # @param [<<Integer, Integer>>] instructions a list of instructions
  def perform_program(program)
    @instruction_pointer = 0
    @output = ''
    pp_computer
    until program[@instruction_pointer].nil? || program[@instruction_pointer + 1].nil?
      opcode = program[@instruction_pointer].to_i
      operand = program[@instruction_pointer + 1].to_i
      pp_next_instruction(program)
      instruct(opcode, operand)
      pp_computer
    end
    @output.chars.join(',')
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
    when 0,1,2,3 then operand
    when 4 then @register_a
    when 5 then @register_b
    when 6 then @register_c
    when 7 then raise 'invalid program'
    else raise "Unknown combo operand: #{operand}"
    end
  end

  # Shared between adv bdv cdv
  def division(operand)
    numerator = @register_a
    denominator = 2**value_for_combo_operand(operand)
    (numerator / denominator).to_i
  end

  # 0
  def adv(operand)
    @register_a = division(operand)
  end

  # 1
  def bxl(operand)
    @register_b = (@register_b ^ operand).to_s(2).to_i
  end

  # 2
  def bst(operand)
    @register_b = value_for_combo_operand(operand) % 8
  end

  # 3
  def jnz(operand)
    if @register_a.zero?
      @instruction_pointer += 2
    else
      @instruction_pointer = operand
    end
  end

  # 4
  def bxc(_operand)
    @register_b = (@register_b ^ @register_c).to_s(2).to_i
  end

  # 5
  def out(operand)
    output = value_for_combo_operand(operand) % 8
    @output += output.to_s
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