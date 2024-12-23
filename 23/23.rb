require_relative '../aoc'
require_relative '../helpers/graph'

class LANPartySolver < AoCExerciseSolver
  def initialize(*args)
    super(*args)
  end

  def preprocess
    @graph = Graph.new

    # Fill in graph
    parse_lines do |line|
      computer_1, computer_2 = line.scan(/\w+/)
      @graph.add_state(computer_1)
      @graph.add_state(computer_2)
      @graph.add_transition(computer_1, computer_2)
      @graph.add_transition(computer_2, computer_1)
    end
  end

  def solve_part_1
    pp @graph
  end

  def solve_part_2

  end
end

test_solver = LANPartySolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

# solver = LANPartySolver.new(__FILE__.sub('.rb', '_input.txt'))
# solver.preprocess
# solver.solve