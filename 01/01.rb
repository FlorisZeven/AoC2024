require_relative '../aoc'

class HistorianHysteriaSolver < AoCExerciseSolver
  attr_accessor :left_ids
  attr_accessor :right_ids

  def initialize(*args)
    left_ids = []
    right_ids = []
    super
  end

  def preprocess
    parse_lines do |line|
      left, right = line.chomp.split(' ').map(&:to_i)
      @left_ids << left
      @right_ids << right
    end

    @left_ids.sort!
    @right_ids.sort!
  end

  def solve_part_1
    @left_ids.map.with_index do |left_id, i|
      right_id = @right_ids[i]
      (left_id - right_id).abs
    end.sum
  end

  def solve_part_2
    right_id_tally = right_ids.tally

    @left_ids.sum do |left_id|
      right_id_tally.key?(left_id) ? left_id * right_id_tally[left_id] : 0
    end
  end
end

solver = HistorianHysteriaSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve