require_relative '../aoc'
require 'rational'

class ClawContraptionSolver < AoCExerciseSolver
  ClawMachine = Struct.new(:a_x, :a_y, :b_x, :b_y, :sum_x, :sum_y)

  def initialize(*args)
    @claw_machines = []
    super
  end

  def preprocess
    i = 0
    a_x = a_y = b_x = b_y = sum_x = sum_y = 0

    File.readlines(@input_file).each do |line|
      # Since the input is structured evenly, we can use the line index to determine its contents
      remainder = i % 4
      case remainder
      when 0 # Button A
        a_x, a_y = line.scan(/\d+/).map(&:to_i)
      when 1 # Button B
        b_x, b_y = line.scan(/\d+/).map(&:to_i)
      when 2 # Prize
        sum_x, sum_y = line.scan(/\d+/).map(&:to_i)
      when 3 # Empty line
        @claw_machines << ClawMachine.new(a_x, a_y, b_x, b_y, sum_x, sum_y)
      end
      i += 1
    end
  end

  # @param [ClawMachine] m The machine to test
  def min_tokens(m)
    # We have two expressions
    #  - a_x + a_presses + b_x + b_presses = sum_x
    #  - a_y + a_presses + b_y + b_presses = sum_y
    #
    # Two unknowns, so:
    #  - Rewrite both expressions to a_presses = ...
    #  - Set them equal to each other to have b_presses as remaining unknown
    #  - Once b_presses is known, solve a_presses
    b_presses = (m.a_x * m.sum_y - m.a_y * m.sum_x).to_f / (m.a_x * m.b_y - m.a_y * m.b_x)
    a_presses = (m.sum_x - m.b_x * b_presses).to_f / m.a_x

    # No real solution if a fraction
    return 0 if b_presses.to_i != b_presses || a_presses.to_i != a_presses

    # Calculate tokens
    3 * a_presses + b_presses
  end

  def solve_part_1
    @claw_machines.sum do |claw_machine|
      min_tokens(claw_machine)
    end
  end

  def solve_part_2
    adjusted_claw_machines = @claw_machines.map do |machine|
      machine.sum_x += 10_000_000_000_000
      machine.sum_y += 10_000_000_000_000
      machine
    end

    adjusted_claw_machines.sum do |claw_machine|
      min_tokens(claw_machine)
    end
  end
end

test_solver = ClawContraptionSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = ClawContraptionSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve


