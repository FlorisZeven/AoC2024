require_relative 'aoc'

class BridgeRepairSolver < AoCExerciseSolver
  attr_accessor :equations

  NodeContent = Struct.new(:value, :index)

  def initialize(*args)
    @equations = []
    super
  end

  def preprocess
    parse_lines do |line|
      # We give special treatment to the first char later
      @equations << line.chomp.split(/\s|:\s/).map(&:to_i)
    end   
  end

  # @return [Boolean]
  def calibration_result(target, equation, value:, index:, concat: false)
    return false if value > target
    
    # End of array, we check result
    return value == target if equation[index].nil?
   
    return true if calibration_result(target, equation, value: value + equation[index], index: index + 1, concat:)
    return true if calibration_result(target, equation, value: value * equation[index], index: index + 1, concat:)
    return true if calibration_result(target, equation, value: [value, equation[index]].join.to_i, index: index + 1, concat:) if concat

    false
  end
  
  def solve_part_1
    @equations.sum do |equation|
      # First number of equation is the target test value
      target = equation[0]
      calibration_result(target, equation[1..], value: equation[1], index: 1) ? target : 0
    end
  end
  
  def solve_part_2
    @equations.sum do |equation|
      # First number of equation is the target test value
      target = equation[0]
      calibration_result(target, equation[1..], value: equation[1], index: 1, concat: true) ? target : 0
    end
  end
end

test_solver = BridgeRepairSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = BridgeRepairSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
