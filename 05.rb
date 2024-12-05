require_relative 'aoc'

class PrintQueueSolver < AoCExerciseSolver
  # A rule maps every value to the values that should come before it
  # Ex: 1|2, 1|3, 2|3 results in {1 => [2,3], 2 => [3]}
  attr_accessor :rules
  attr_accessor :updates

  def initialize(*args)
    @rules = {}
    @updates = []
    super
  end

  def preprocess
    parse_lines do |line|
      line.chomp!
      if line.include?('|')
        before, after = line.split('|').map(&:to_i)
        @rules.key?(before) ? @rules[before] << after : @rules[before] = [after]
      elsif line.include?(',')
        @updates << line.split(',').map(&:to_i)
      end
    end
  end

  def valid_update?(update)
    update.each_with_index do |page, i|
      if @rules.key?(page) && i > 0
        if (update[..i-1] + @rules[page]).uniq.size != (update[..i-1] + @rules[page]).size
          return false
        end
      end
    end

    true
  end

  def solve_part_1
    valid_updates = @updates.select do |update|
      valid_update?(update)
    end

    valid_updates.sum do |update|
      update[update.length/2]
    end
  end

  def solve_part_2
    invalid_updates = @updates.reject do |update|
      valid_update?(update)
    end

    # TODO: Sort
  end
end

small_solver = PrintQueueSolver.new(__FILE__.sub('.rb', '_small_input.txt'))
small_solver.preprocess
small_solver.solve

# solver = PrintQueueSolver.new(__FILE__.sub('.rb', '_input.txt'))
# solver.preprocess
# solver.solve
