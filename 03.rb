require_relative 'aoc'

class MullItOverSolver < AoCExerciseSolver
  attr_accessor :raw_lines

  MUL_REGEX = /mul\((\d+),(\d+)\)/
  DO_OR_DONT_REGEX = /(?=do\(\)|don't\(\))/

  def initialize(*args)
    @raw_lines = []
    super
  end

  def preprocess
    parse_lines do |line|
      @raw_lines << line
    end
  end

  def sum_muls_in_str(str)
    str.scan(MUL_REGEX).sum do |mul|
      left, right = mul.map(&:to_i)
      left * right
    end
  end

  def solve_part_1
    raw_lines.sum do |line|
      sum_muls_in_str(line)
    end
  end

  def solve_part_2
    raw_lines.sum do |line|
      dos_or_donts = line.split(DO_OR_DONT_REGEX)

      valid = dos_or_donts.select! do |do_or_dont|
        !do_or_dont.start_with?("don't()")
      end

      valid.sum do |str|
        sum_muls_in_str(str)
      end
    end
  end
end

# PART 2: 106266128 TOO HIGH
solver = MullItOverSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve