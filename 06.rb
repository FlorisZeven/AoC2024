require_relative 'aoc'

class GuardGallivantSolver < AoCExerciseSolver
  attr_accessor :lab_grid

  GUARD_CHAR = '^'
  OBSTRUCTION_CHAR = '#'

  def initialize(*args)
    @lab_grid = []
    super
  end

  def preprocess
    parse_lines do |line|
      @lab_grid << line.chomp.chars
    end
  end

  def initial_guard_position
    row = @lab_grid.index {|row| row.include?(GUARD_CHAR) }
    col = @lab_grid[row].index {|char| char == GUARD_CHAR}

    [row, col]
  end

  # Assumes lab grid is rectangular
  def out_of_bounds?(row, col)
    row < 0 || row > @lab_grid.length - 1 || col < 0 || col > @lab_grid[0].length - 1
  end

  def obstruction?(row, col)
    @lab_grid[row][col] == OBSTRUCTION_CHAR
  end

  # Find the next guard position
  # @return [<Integer, Integer, Symbol, Boolean>] The new row and column of the
  #   guard, its current direction, and whether it is out of bounds.
  #   If the guard is out of bounds, don't move the guard.
  def next_guard_position(row, col, direction)
    case direction
    when :up
      return [row, col, direction, true] if out_of_bounds?(row - 1, col)

      obstruction?(row - 1, col) ? direction = :right : row -= 1
    when :down
      return [row, col, direction, true] if out_of_bounds?(row + 1, col)

      obstruction?(row + 1, col) ? direction = :left : row += 1
    when :left
      return [row, col, direction, true] if out_of_bounds?(row, col - 1)

      obstruction?(row , col - 1) ? direction = :up : col -= 1
    when :right
      return [row, col, direction, true] if out_of_bounds?(row, col + 1)

      obstruction?(row, col + 1) ? direction = :down : col += 1
    else
      raise 'invalid direction'
    end

    [row, col, direction, false]
  end

  def count_marked_positions(grid)
    grid.sum {|row| row.count {|cell| cell == true}}
  end

  def solve_part_1
    # Initialize grid with dimensions of lab grid, all with value 'false'.
    marked_grid = Array.new(@lab_grid.length){Array.new(@lab_grid[0].length, false)}

    out_of_bounds = false
    direction = :up
    guard_row, guard_col = initial_guard_position

    until out_of_bounds
      marked_grid[guard_row][guard_col] = true
      guard_row, guard_col, direction, out_of_bounds = next_guard_position(guard_row, guard_col, direction)
    end

    count_marked_positions(marked_grid)
  end

  def solve_part_2
    'not implemented'
  end
end

test_solver = GuardGallivantSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = GuardGallivantSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
