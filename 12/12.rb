require_relative '../aoc'
require 'set'

class GardenGroupsSolver < AoCExerciseSolver
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

  RegionInfo = Struct.new(:area, :perimeter, :sides)

  def new_coord_for(x, y, direction)
    case direction
    when :up then [x, y - 1]
    when :down then [x, y + 1]
    when :left then [x - 1, y]
    when :right then [x + 1, y]
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
    plot_value = @grid[y][x]
    @visited[y][x] = true # We're always visiting the first elem

    area = 0
    perimeter = 0
    sides = 0 # TODO: somehow compute sides? kek

    to_visit_in_region = [[x,y]]

    until to_visit_in_region.empty? do
      x, y = to_visit_in_region.shift
      additional_perimeter = 4 # Max value that can be added when processing a plot
      # Process neighbouring cells
      [:up, :down, :left, :right].each do |direction|
        new_x, new_y = new_coord_for(x, y, direction)
        if in_bounds?(new_x, new_y) && plot_value == @grid[new_y][new_x]
          additional_perimeter -= 1
          if !@visited[new_y][new_x] # Not seen before
            # We're going to visit it, so mark it as such
            @visited[new_y][new_x] = true
            to_visit_in_region << [new_x, new_y]
          end
        end
      end

      perimeter += additional_perimeter
      area += 1
    end

    # pp "Region #{plot_value} - Area #{area} - Perimeter #{perimeter}"
    RegionInfo.new(area, perimeter, sides)
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
      region.area * region.sides
    end
  end
end

test_solver = GardenGroupsSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = GardenGroupsSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve


