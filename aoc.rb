# Require useful modules

require 'byebug'
require 'awesome_print'

# Useful class

class AoCExerciseSolver
  attr_accessor :input_file

  # @param [String] input_file A relative path to the input_file
  def initialize(input_file)
    @input_file = input_file
  end
  
  # A wrapper for reading lines from the input file
  def parse_lines
    File.readlines(@input_file).each do |line|
      yield line
    end
  end

  # Implement the solve methods
  def solve_part_1; raise 'implement!' end
  def solve_part_2; raise 'implement!' end

  # Nicely print both solutions
  def solve
    puts "Solution for input file: #{@input_file}"
    puts "PART 1: #{solve_part_1}"
    puts "PART 2: #{solve_part_2}"
  end
end