require_relative 'aoc'

class MullItOverSolver < AoCExerciseSolver
  attr_accessor :raw_string

  # Ex: mul(1,2) - Capture the digits immediately for later use
  MUL_REGEX = /mul\((\d+),(\d+)\)/

  def initialize(*args); super; end

  def preprocess
    @raw_string = File.read(@input_file)
  end

  # Find all valid multiplications in a string and sum the result of their multiplications
  def sum_muls_in_str(str)
    str.scan(MUL_REGEX).sum do |mul|
      left, right = mul.map(&:to_i)
      left * right
    end
  end

  def solve_part_1
    sum_muls_in_str(@raw_string)
  end

  def solve_part_2
    # Split input with delimiter do() or don't() - but keep the delimiter
    # per split using a positive lookahead so we can filter don't()
    dos_or_donts = @raw_string.split(/(?=do\(\)|don't\(\))/)

    # Filter don't() and sum the valid multiplications of the remaining substrings
    dos_or_donts.filter_map do |substring|
      if !substring.start_with?("don't()")
        sum_muls_in_str(substring)
      end
    end.sum
  end
end

solver = MullItOverSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve