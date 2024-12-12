require_relative '../aoc'
require 'set'

class GardenGroupsSolver < AoCExerciseSolver
  CARDINAL_DIRECTIONS = [:left, :right, :up, :down]
  ALL_DIRECTIONS = [:up_left, :up, :up_right, :left, :right, :down_left, :down, :down_right]

  # Holds info about a region
  RegionInfo = Struct.new(:area, :perimeter, :corners)

  def initialize(*args)
    @grid = []
    @regions = []
    super
  end

  def preprocess
    parse_lines do |line|
      @grid << line.chomp.chars
    end

    build_regions
  end

  def next_coord_for(x, y, direction)
    case direction
    when :up then [x, y - 1]
    when :down then [x, y + 1]
    when :left then [x - 1, y]
    when :right then [x + 1, y]
    when :middle then [x, y]
    when :up_left then [x - 1, y - 1]
    when :up_right then [x + 1, y - 1]
    when :down_left then [x - 1, y + 1]
    when :down_right then [x + 1, y + 1]
    end
  end

  def build_regions
    @visited = Array.new(@grid.length) {Array.new(@grid[0].length, false)}

    @grid.each_index do |y|
      @grid.each_index do |x|
        if !@visited[y][x]
          @regions << build_region_for(x, y)
        end
      end
    end
  end

  # @param [Integer] x horizontal index of plot in grid
  # @param [Integer] y vertical index of plot in grid
  # @return [RegionInfo] A region object with area and perimiter
  def build_region_for(x, y)
    area = 0
    perimeter = 0
    corners = 0

    # Initialization
    plot_value     = @grid[y][x] # The value of the current plot
    to_visit       = [[x,y]]     # A 'to-visit' FIFO queue, starts out with the initial coordinate
    @visited[y][x] = true        # Visit the first plot

    until to_visit.empty? do
      x, y = to_visit.shift

      # Process neighbouring plots, store map direction to whether it is in the same plot
      # For cardinal directions, determine perimeter and next plots to visit in the region 
      same_plot_for = ALL_DIRECTIONS.to_h do |direction|
        next_x, next_y = next_coord_for(x, y, direction)

        same_plot = in_bounds?(next_x, next_y) && @grid[next_y][next_x] == plot_value

        if CARDINAL_DIRECTIONS.include?(direction)
          if same_plot
            # If not visited, we must visit it in the future. Mark it already 
            # so we do not accidentally add it again when adding other plots
            if !@visited[next_y][next_x]
              @visited[next_y][next_x] = true
              to_visit << [next_x, next_y]
            end
          else
            # Is an edge (of grid or other plot) so update perimeter
            perimeter += 1
          end
        end

        [direction, same_plot]
      end

      corners += count_corners(same_plot_for)
      area += 1
    end

    RegionInfo.new(area, perimeter, corners)
  end

   # @param [{Symbol => Boolean}] same_plot_for
   #   Maps directions to whether the currently processed cell shares the same plot
   def count_corners(same_plot_for)
    corners = 0

    # A cell has an outside corner if its neighbours in two adjacent cardinal
    #   directions are not in the same plot
    corners += 1 if !same_plot_for[:up]   && !same_plot_for[:left]  
    corners += 1 if !same_plot_for[:up]   && !same_plot_for[:right]
    corners += 1 if !same_plot_for[:down] && !same_plot_for[:left]
    corners += 1 if !same_plot_for[:down] && !same_plot_for[:right]

    # A cell has an inside corner if its neighbours in two adjacent cardinal directions
    #   are in the same plot but its combined direction is not
    corners += 1 if same_plot_for[:up]   && same_plot_for[:left]  && !same_plot_for[:up_left]
    corners += 1 if same_plot_for[:up]   && same_plot_for[:right] && !same_plot_for[:up_right]
    corners += 1 if same_plot_for[:down] && same_plot_for[:left]  && !same_plot_for[:down_left]
    corners += 1 if same_plot_for[:down] && same_plot_for[:right] && !same_plot_for[:down_right]

    corners
  end

  def in_bounds?(x, y)
    x.between?(0, @grid.length - 1) && y.between?(0, @grid[0].length - 1)
  end

  def solve_part_1
    @regions.sum do |region|
      region.area * region.perimeter
    end
  end

  def solve_part_2
    @regions.sum do |region|
      region.area * region.corners # Corners == Sides
    end
  end
end

test_solver = GardenGroupsSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = GardenGroupsSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve


