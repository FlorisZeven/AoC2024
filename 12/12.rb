require_relative '../aoc'

class GardenGroupsSolver < AoCExerciseSolver
  attr_accessor :input_stones

  def initialize(*args)
    super
  end

  def preprocess

  end

  def solve_part_1
  end

  def solve_part_2

  end
end

test_solver = GardenGroupsSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = GardenGroupsSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve


