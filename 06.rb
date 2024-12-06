require_relative 'aoc'

EMPTY_CHAR = '.'
INITIAL_POSITION_CHAR = '^'
OBSTRUCTION_CHAR = '#'

class GuardGallivantSolver < AoCExerciseSolver
  attr_accessor :lab_grid

  def initialize(*args)
    @lab_grid = []
    super
  end

  def preprocess
    parse_lines do |line|
      @lab_grid << line.chomp.chars
    end
  end

  def count_marked_positions(grid)
    grid.sum {|row| row.count {|cell| cell == true}}
  end

  def solve_part_1
    gridwalker = GridWalker.new(@lab_grid)
    gridwalker.walk
    count_marked_positions(gridwalker.walked_grid)
  end
  
  def solve_part_2
    gridwalker = GridWalker.new(@lab_grid)
    gridwalker.walk
    walked_grid = gridwalker.walked_grid

    num_loops = 0
  
    # NOTE: Can be optimized by keeping track of the path and moving the
    #   initial position (and direction) forward along the path
    walked_grid.each_index do |i|
      walked_grid[i].each_index do |j|
        if walked_grid[i][j] == true && @lab_grid[i][j] != INITIAL_POSITION_CHAR
          @lab_grid[i][j] = OBSTRUCTION_CHAR

          grid_walker = GridWalker.new(@lab_grid)
          grid_walker.walk(mark_path: false)

          @lab_grid[i][j] = EMPTY_CHAR 

          num_loops += 1 if grid_walker.is_looping
        end
      end
    end

    num_loops
  end
end

class GridWalker
  attr_accessor :grid
  attr_accessor :walked_grid
  attr_reader :is_looping

  def initialize(grid)
    @grid = grid
    @walked_grid = []
    @is_looping = false
  end

  def initial_position
    row = @grid.index {|row| row.include?(INITIAL_POSITION_CHAR) }
    col = @grid[row].index {|char| char == INITIAL_POSITION_CHAR}

    [row, col]
  end
  
  # Determine next position based on direction
  def next_position(row, col, direction)
    case direction
      when :right then col += 1;
      when :left  then col -= 1;
      when :up    then row -= 1;
      when :down  then row += 1;
      else 'invalid direction'
    end

    [row, col]
  end

  # Whether current position is out of bounds
  def out_of_bounds?(row, col)
    row < 0 || row > @grid.length - 1 || col < 0 || col > @grid[0].length - 1
  end

  # Whether current position is at an obstruction
  def obstruction?(row, col)
    @grid[row][col] == OBSTRUCTION_CHAR
  end

  # Determine next direction
  def next_direction(direction)
    case direction
      when :right then :down
      when :left  then :up
      when :up    then :right
      when :down  then :left
    end
  end
  
  # @param [Boolean] mark_path Whether to mark the path that is walked
  # @return [Boolean] Whether the walk resulted in an infinite loop
  def walk(mark_path: true)
    @walked_grid = Array.new(grid.length){Array.new(grid[0].length, false)} if mark_path
    seen_turns = {:up => [], :down => [], :right => [], :left => []}
    direction = :up
    row, col = initial_position

    # We stop walking if we detect a loop or we are out of bounds
    loop do
      @walked_grid[row][col] = true if mark_path

      next_row, next_col = next_position(row, col, direction)
      if out_of_bounds?(next_row, next_col)
        @is_looping = false
        return
      elsif obstruction?(next_row, next_col)
        # Change direction
        direction = next_direction(direction)
        if seen_turns[direction].include?([row, col])
          @is_looping = true
          return
        else
          seen_turns[direction] << [row, col]
        end
      else
        # Update position
        row, col = next_row, next_col
      end
    end
  end
end

test_solver = GuardGallivantSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = GuardGallivantSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
