require_relative 'aoc'

class PrintQueueSolver < AoCExerciseSolver
  attr_accessor :after
  attr_accessor :updates

  def initialize(*args)
    @after = {}
    @updates = []
    super
  end

  def preprocess
    parse_lines do |line|
      line.chomp!
      if line.include?('|')
        # Rules are represented as a hash that maps pages to all pages that should come after it
        # Ex: 1|2, 1|3, 2|3 results in {1 => [2,3], 2 => [3]}
        index, after = line.split('|').map(&:to_i)
        @after.key?(index) ? @after[index] << after : @after[index] = [after]
      elsif line.include?(',')
        @updates << line.split(',').map(&:to_i)
      end
    end
  end

  # @return [<Boolean, nil, nil>] if the report is valid
  #   The Boolean contains the validity of the model
  # @return [<Boolean, Integer, Integer>] if the report is invalid.
  #   The Integers contain the indices that caused the violation (for part II)
  def valid_update?(update)
    update.each_with_index do |current_page, i|
      if @after.key?(current_page) && i > 0
        # If a previous page in the update should come after the current page,
        # there is a violation of the page ordering.
        update[..i-1].each_with_index do |page_before_current_page, j|
          if @after[current_page].include?(page_before_current_page)
            return [false, i, j]
          end
        end
      end
    end

    [true, nil, nil]
  end

  def sum_middle_numbers(updates)
    updates.sum do |update|
      update[update.length/2]
    end
  end

  def solve_part_1
    valid_updates = @updates.select do |update|
      valid, _, _ = valid_update?(update)
      valid
    end

    sum_middle_numbers(valid_updates)
  end

  # Fix violations until the update is valid. Essentially insertion sort with a custom condition
  # NOTE: Using sort with a custom <=> comparison might be quicker, but you will need the inverse
  #   of the current rule mapping
  def fix_invalid_update(update)
    loop do
      valid, before_index, after_index = valid_update?(update)
      return update if valid

      # Fix the violation
      # Move the page that caused the violation before the page that should come after it
      before_page = update.delete_at(before_index)
      update.insert(after_index, before_page)
    end
  end

  def solve_part_2
    invalid_updates = @updates.reject do |update|
      valid, _, _ = valid_update?(update)
      valid
    end

    fixed_updates = invalid_updates.map do |invalid_update|
      fix_invalid_update(invalid_update)
    end

    sum_middle_numbers(fixed_updates)
  end
end

test_solver = PrintQueueSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = PrintQueueSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
