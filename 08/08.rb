require_relative '../aoc'
require 'matrix'

class ResonantCollinearity < AoCExerciseSolver
  attr_accessor :grid
  attr_accessor :antennas
  attr_accessor :marked_grid

  Coord = Struct.new(:x, :y)

  def initialize(*args)
    @grid = []
    @antennas = {}
    super
  end

  def preprocess
    parse_lines do |line|
      @grid << line.chomp.chars
    end

    reset_marked_grid

    # Map antenna types to their positions
    @grid.each_index do |x|
      @grid[x].each_index do |y|
        char = @grid[x][y]
        next if !char.match?(/\w+/) # Only process antennas
        
        coord = Coord.new(x, y)
        @antennas.key?(char) ? @antennas[char] << coord : @antennas[char] = [coord]
      end
    end
  end

  def reset_marked_grid
    @marked_grid = Array.new(grid.length){Array.new(grid[0].length, '.')}
  end

  def out_of_bounds?(vector)
    x = vector[0]
    y = vector[1]
    x < 0 || x >= grid.length || y < 0 || y >= grid.length
  end

  def each_antenna_vector_pair
    @antennas.each do |_char, coords|
      coords.combination(2).map do |c1, c2|
        yield Vector[c1.x, c1.y], Vector[c2.x, c2.y]
      end
    end
  end

  def solve_part_1
    reset_marked_grid

    each_antenna_vector_pair do |a, b|
      d_ab = a - b          
      antinode_a = a + d_ab
      antinode_b = b - d_ab
      @marked_grid[antinode_a[0]][antinode_a[1]] = '#' if !out_of_bounds?(antinode_a)
      @marked_grid[antinode_b[0]][antinode_b[1]] = '#' if !out_of_bounds?(antinode_b)
    end

    @marked_grid.flatten.count{|el| el == '#'}
  end
  
  def solve_part_2
    reset_marked_grid

    each_antenna_vector_pair do |a, b|
      d_ab = a - b
    
      antinode = a
      until out_of_bounds?(antinode) do
        @marked_grid[antinode[0]][antinode[1]] = '#' 
        antinode = antinode + d_ab
      end

      antinode = b
      until out_of_bounds?(antinode) do
        @marked_grid[antinode[0]][antinode[1]] = '#' 
        antinode = antinode - d_ab
      end
    end

    @marked_grid.flatten.count{|el| el == '#'}
  end
end

test_solver = ResonantCollinearity.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = ResonantCollinearity.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
