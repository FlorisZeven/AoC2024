require_relative 'aoc'

class CeresSearchSolver < AoCExerciseSolver
  attr_accessor :letter_table

  def initialize(*args)
    @letter_table = []
    super
  end

  def preprocess
    parse_lines do |line|
      @letter_table << line.chomp
    end
  end

  def count_xmas(str)
    str.scan(/XMAS/).length + str.scan(/SAMX/).length
  end

  def solve_part_1
    total = 0

    # HORIZONTAL
    total += @letter_table.sum do |row|
      count_xmas(row)
    end

    # VERTICAL
    @letter_table.length.times do |i|
      vert = @letter_table.map {|row| row[i]}.join
      total += count_xmas(vert)
    end

    # DIAGONAL
    # Sliding table of size 4
    len = @letter_table.length - 3
    len.times do |i|
      len.times do |j|
        subtable = @letter_table[i..i+3].map {|row| row[j..j+3]}
        total += count_xmas(subtable[0][0] + subtable[1][1] + subtable[2][2] + subtable[3][3])
        total += count_xmas(subtable[0][3] + subtable[1][2] + subtable[2][1] + subtable[3][0])
      end
    end

    total
  end

  def solve_part_2
    total = 0

    # Sliding table of size 3
    len = @letter_table.length - 2
    len.times do |i|
      len.times do |j|
        subtable = @letter_table[i..i+2].map {|row| row[j..j+2]}
        total += 1 if x_mas_in_3x3?(subtable)
      end
    end

    total
  end

  def x_mas_in_3x3?(table)
    is_mas?(table[0][0] + table[1][1] + table[2][2]) &&
      is_mas?(table[0][2] + table[1][1] + table[2][0])
  end

  def is_mas?(str)
    str == 'MAS' || str == 'SAM'
  end
end

test_solver = CeresSearchSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = CeresSearchSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
