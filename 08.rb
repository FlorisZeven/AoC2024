require_relative 'aoc'
require 'matrix'

class ResonantCollinearity < AoCExerciseSolver
  attr_accessor :grid
  attr_accessor :antennas

  Coord = Struct.new(:x, :y)

  ANTENNA_REGEX = /\w+/
  def initialize(*args)
    @grid = []
    @antennas = {}
    super
  end

  def preprocess
    parse_lines do |line|
      @grid << line.chomp.chars
    end

    locate_antennas
  end

  def locate_antennas
    @grid.each_index do |row|
      @grid[row].each_index do |col|
        char = @grid[row][col]
        next if !char.match?(ANTENNA_REGEX)\
        
        coord = Coord.new(row, col)
        if @antennas.key?(char)
          @antennas[char] << coord
        else
          @antennas[char] = [coord]
        end
      end
    end
  end

  def out_of_bounds?(vector)
    x = vector[0]
    y = vector[1]
    x < 0 || x >= grid.length || y < 0 || y >= grid.length
  end

  def solve_part_1
    # Copy of grid
    marked_grid = Array.new(grid.length){Array.new(grid[0].length, false)}

    @antennas.each do |char, coords|
      coords.combination(2).each do |coord_a, coord_b|
        a = Vector[coord_a.x, coord_a.y]
        b = Vector[coord_b.x, coord_b.y]
        d_ab = a - b          # vector difference between a pair of antennas
        antinode_a = a + d_ab # Add difference to antenna a
        antinode_b = b - d_ab # Subtract difference from antenna b
        marked_grid[antinode_a[0]][antinode_a[1]] = true if !out_of_bounds?(antinode_a)
        marked_grid[antinode_b[0]][antinode_b[1]] = true if !out_of_bounds?(antinode_b)
      end
    end

    marked_grid.flatten!.count{|el| el == true}
  end
  
  def solve_part_2
    # Copy of grid
    marked_grid = Array.new(grid.length){Array.new(grid[0].length, false)}

    @antennas.each do |char, coords|
      coords.combination(2).each do |coord_a, coord_b|
        a = Vector[coord_a.x, coord_a.y]
        b = Vector[coord_b.x, coord_b.y]
        d_ab = a - b          # vector difference between a pair of antennas
        
        marked_grid[a[0]][a[1]] = true
        antinode = a
        loop do
          antinode = antinode + d_ab
          if out_of_bounds?(antinode)
            break
          else
            marked_grid[antinode[0]][antinode[1]] = true 
          end
        end

        marked_grid[b[0]][b[1]] = true
        antinode = b
        loop do
          antinode = antinode - d_ab
          if out_of_bounds?(antinode)
            break
          else
            marked_grid[antinode[0]][antinode[1]] = true 
          end
        end
      end
    end

    marked_grid.flatten!.count{|el| el == true}
  end
end

test_solver = ResonantCollinearity.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = ResonantCollinearity.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
