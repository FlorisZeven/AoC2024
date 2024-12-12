require_relative 'aoc'
require_relative 'helpers/graph'


class PlutonianPebblesSolver < AoCExerciseSolver
  attr_accessor :input_stones

  BLINKS_PART_1 = 25
  BLINKS_PART_2 = 75

  def initialize(*args)
    @input_stones = nil
    @blink = {}      # Store blink results
    @num_stones = {} # Store the number of stones after blinking n times for a stone
    super
  end

  def preprocess
    @input_stones = File.read(@input_file).split(' ').map(&:to_i)
  end

  def count_stones_after_n_blinks(stones, n)
    stones.sum do |stone|
      num_stones_after_n_blinks(stone, n)
    end
  end

  def num_stones_after_n_blinks(stone, n)
    return 1 if n.zero?                                               # Base case
    return num_stones_after_n_blinks(stone + 1, n - 1) if stone.zero? # First rule is trivial

    # Check if we already know the final number of stones after blinking this stone n times
    return @num_stones[[stone, n]] if @num_stones.key?([stone, n])

    new_stone_1, new_stone_2 = blink(stone)

    # Check both stones if the stone has split
    num_stones = if new_stone_2
                   num_stones_after_n_blinks(new_stone_1, n - 1) +
                     num_stones_after_n_blinks(new_stone_2, n - 1)
                 else
                   num_stones_after_n_blinks(new_stone_1, n - 1)
                 end

    @num_stones[[stone, n]] = num_stones
    num_stones
  end

  # @return [<Integer, Integer>] The resulting stone(s) from the blink. If the stone does not split
  #   the second stone is nil.
  def blink(stone)
    # Check if we have seen the result of the blink before
    return @blink[stone] if @blink.key?(stone)

    num_digits = stone.digits.length
    new_stones = if num_digits.even?
                   half = num_digits.length / 2
                   [stone.to_s[..half - 1], stone.to_s[half..]].map(&:to_i)
                 else
                   [stone * 2024, nil]
                 end

    @blink[stone] = new_stones
    new_stones
  end

  def solve_part_1
    count_stones_after_n_blinks(@input_stones, BLINKS_PART_1)
  end

  def solve_part_2
    count_stones_after_n_blinks(@input_stones, BLINKS_PART_2)
  end
end

solver = PlutonianPebblesSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
