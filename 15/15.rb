require_relative '../aoc'

class WareHouseWoesSolver < AoCExerciseSolver
  def initialize(*args); super; end

  def preprocess
    raw_grid_data, moves = File.read(@input_file).split(/\n\n/) # Separate grid from moves
    @raw_grid_data = raw_grid_data
    @moves = moves.gsub(/\n/, '').chars.map { |move| parse_move(move) }
  end

  def parse_move(move)
    case move
    when '>' then :right
    when '<' then :left
    when '^' then :up
    when 'v' then :down
    end
  end

  def solve_part_1
    warehouse = WareHouse.new(@raw_grid_data)
    @moves.each do |move|
      warehouse.update(move)
    end
    warehouse.gps_sum
  end

  def solve_part_2
    wide_warehouse = WareHouse.new(@raw_grid_data, wide: true)
    @moves.each do |move|
      wide_warehouse.update(move)
    end
    wide_warehouse.gps_sum
  end
end

class WareHouse
  attr_accessor :grid
  attr_accessor :robot_position
  attr_reader :wide

  WALL_CHAR           = '#'
  BOX_CHAR            = 'O'
  WIDE_BOX_LEFT_CHAR  = '['
  WIDE_BOX_RIGHT_CHAR = ']'
  EMPTY_CHAR          = '.'
  ROBOT_CHAR          = '@'

  # @param [String] A long string
  def initialize(grid_data, wide: false)
    @wide = wide
    @grid = grid_data.split(/\n/).map do |row|
      @wide ? widen_row(row.chars) : row.chars
    end

    robot_y = @grid.index {|r| r.include?(ROBOT_CHAR)}
    robot_x = @grid[robot_y].index(ROBOT_CHAR)
    @robot_position = [robot_x, robot_y]

    # We keep track of robot position, no need to replace it on the grid
    @grid[robot_y][robot_x] = '.'
  end

  # Update the grid after a robot_move
  # @reeturn [<Integer, Integer>] new location of robot
  def update(direction)
    robot_x, robot_y = @robot_position
    next_x, next_y = next_coord_for(robot_x, robot_y, direction)
    next_cell = @grid[next_y][next_x]
    case next_cell
    when WALL_CHAR  then nil                                # Don't move the robot
    when EMPTY_CHAR then @robot_position = [next_x, next_y] # Move the robot
    when BOX_CHAR   then
      @robot_position = [next_x, next_y] if move_thin_boxes(next_x, next_y, direction)
    when WIDE_BOX_LEFT_CHAR, WIDE_BOX_RIGHT_CHAR
      @robot_position = [next_x, next_y] if move_wide_boxes(next_x, next_y, direction)
    end
  end

  def gps_sum
    @grid.each_with_index.sum do |row, y|
      row.each_with_index.sum do |cell, x|
        [BOX_CHAR, WIDE_BOX_LEFT_CHAR].include?(cell) ? x + 100 * y : 0
      end
    end
  end
  
  # Print Grid - With robot put in temporarily
  def print_grid
    robot_x, robot_y = @robot_position
    @grid[robot_y][robot_x] = '@'
    @grid.each {|row| puts row.join}
    @grid[robot_y][robot_x] = '.'
  end

  private

  # Converts a row to a wider one
  def widen_row(row)
    row.map do |char|
      case char
      when WALL_CHAR, EMPTY_CHAR then [char, char]
      when ROBOT_CHAR            then [char, EMPTY_CHAR]
      when BOX_CHAR              then [WIDE_BOX_LEFT_CHAR, WIDE_BOX_RIGHT_CHAR]
      end
    end.flatten
  end

  # @return [Boolean] whether the robot can mvoe
  def move_thin_boxes(x, y, direction)
    empty_x, empty_y = next_empty_char_in_direction(x, y, direction)
    return false if empty_x.nil?

    # Swapping this element with the first box essentially moves all boxes
    @grid[y][x], @grid[empty_y][empty_x] = @grid[empty_y][empty_x], @grid[y][x]
    return true
  end

  def move_wide_boxes(x, y, direction)
    if [:up, :down].include?(direction)
      move_wide_boxes_y(x, y, direction)
    else
      move_wide_boxes_x(x, y, direction)
    end
  end

  def move_wide_boxes_x(x, y, direction)
    empty_x, empty_y = next_empty_char_in_direction(x, y, direction)
    return false if empty_x.nil?
    
    # Swap first box with last one, then invert all box chars
    @grid[empty_y][empty_x], @grid[y][x] = @grid[y][x], @grid[empty_y][empty_x]
    
    indices_to_flip = case direction
      when :left  then (empty_x..x - 1)
      when :right then (x + 1..empty_x)
    end
    
    indices_to_flip.each { |x_index| flip_box_char(x_index, y) }

    return true
  end

  # Search for walls with BFS, move all visited boxes upward if no walls
  def move_wide_boxes_y(x, y, direction) 
    box_coordinates_to_visit = [[x,y], other_box_coord(x, y)]
    box_coordinates_visited = [[x,y], other_box_coord(x, y)]
    
    # BFS start here
    until box_coordinates_to_visit.empty?
      x, y = box_coordinates_to_visit.shift

      next_x, next_y = next_coord_for(x, y, direction)
      next_char = @grid[next_y][next_x]

      return false if next_char == WALL_CHAR # No move possible, dont even try
      
      next if box_coordinates_visited.include?([next_x, next_y]) # Prevent duplicates

      if next_char != EMPTY_CHAR          
        box_coordinates_to_visit += [[next_x, next_y], other_box_coord(next_x, next_y)]
        box_coordinates_visited  += [[next_x, next_y], other_box_coord(next_x, next_y)]
      end
    end

    # No walls interfere, determine values for coords that need to move
    coordinates_to_change = box_coordinates_visited.to_h do |x, y|
      [next_coord_for(x, y, direction), @grid[y][x]]
    end

    # But before replacing the coords, first yeet the existing boxes from existence
    box_coordinates_visited.each { |x, y| @grid[y][x] = '.' }

    coordinates_to_change.each do |(x, y), value|
      @grid[y][x] = value
    end

    return true
  end

  def next_coord_for(x, y, direction)
    case direction
    when :up    then [x, y - 1]
    when :down  then [x, y + 1]
    when :left  then [x - 1, y]
    when :right then [x + 1, y]
    end
  end

  def flip_box_char(x, y)
    @grid[y][x] = case @grid[y][x]
      when WIDE_BOX_LEFT_CHAR  then WIDE_BOX_RIGHT_CHAR
      when WIDE_BOX_RIGHT_CHAR then WIDE_BOX_LEFT_CHAR
    end
  end

  def next_empty_char_in_direction(x, y, direction)
    current_char = @grid[y][x]

    until current_char == EMPTY_CHAR do
      x, y = next_coord_for(x, y, direction)
      current_char = @grid[y][x]

      return [nil, nil] if current_char == WALL_CHAR
    end

    [x, y]
  end

  def other_box_coord(x, y)
    case @grid[y][x]
    when WIDE_BOX_LEFT_CHAR  then [x + 1, y]
    when WIDE_BOX_RIGHT_CHAR then [x - 1, y]
    else raise 'not a box coord'
    end
  end
end

test_solver = WareHouseWoesSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = WareHouseWoesSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve