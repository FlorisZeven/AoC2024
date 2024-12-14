require_relative '../aoc'

class RestroomRedoubtSolver < AoCExerciseSolver
  attr_accessor :robots, :width, :height

  def initialize(input_file, width:, height:)
    @width = width
    @height = height
    @robots = []
    super(input_file)
  end

  def preprocess
    @robots = []

    parse_lines do |line|
      next if line.start_with?('#')
      pos_x, pos_y, vel_x, vel_y = line.match(/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/).captures.map(&:to_i)
      @robots << Robot.new(pos_x, pos_y, vel_x, vel_y, width, height)
    end
  end

  def draw_grid
    grid = Array.new(height) {Array.new(width, 0)}

    @robots.each do |robot|
      grid[robot.position_y][robot.position_x] += 1
    end

    height.times do |y| 
      width.times do |x|
        if grid[y][x].zero?
          grid[y][x] = '.'
        else
          grid[y][x] = '#'
        end
      end
    end

    grid
  end

  def write_grid_to_file(file_name, grid)
    File.open(file_name, 'w') do |file|
      file.write('┏' + '-' * width + '┓' + "\n")
      grid.each do |row|
        file.write('|' + row.join + '|' + "\n")
      end
      file.write('┗' + '-' * width  + '┛' + "\n")
    end
  end

  def calculate_safety_factor
    top_left = top_right = bottom_left = bottom_right = 0
    @robots.each do |robot|
      half_width = width / 2
      half_height = height / 2

      if robot.position_x < half_width && robot.position_y < half_height
        top_left += 1
      elsif robot.position_x > half_width && robot.position_y < half_height
        top_right += 1
      elsif robot.position_x < half_width && robot.position_y > half_height
        bottom_left += 1
      elsif robot.position_x > half_width && robot.position_y > half_height
        bottom_right += 1
      end
    end

    top_left * top_right * bottom_left * bottom_right
  end

  def solve_part_1
    100.times do |i|
      @robots.each do |robot|
        robot.move
      end
    end

    calculate_safety_factor
  end

  def solve_part_2
    preprocess # Resets robot positions
    
    (1..50_000).each do |i|
      grid = draw_grid

      grid.each do |row|
        if row.join.include?('#' * (width / 5))
          write_grid_to_file('output.txt', grid)
          return i
        end
      end
      # Else, move robots
      @robots.each do |robot|
        robot.move
      end
    end
  end
end

class Robot
  attr_reader :velocity_x, :velocity_y
  attr_accessor :position_x, :position_y

  def initialize(position_x, position_y, velocity_x, velocity_y, max_x, max_y)
    @position_x = position_x
    @position_y = position_y
    @velocity_x = velocity_x
    @velocity_y = velocity_y
    @max_x = max_x
    @max_y = max_y
  end

  def move
    @position_x = (@position_x + @velocity_x) % @max_x
    @position_y = (@position_y + @velocity_y) % @max_y
    [@position_x, @position_y]
  end
end

# test_solver = RestroomRedoubtSolver.new(__FILE__.sub('.rb', '_test.txt'), width: 11, height: 7)
# test_solver.preprocess
# test_solver.solve

solver = RestroomRedoubtSolver.new(__FILE__.sub('.rb', '_input.txt'), width: 101, height: 103)
solver.preprocess
solver.solve
