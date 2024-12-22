require_relative '../aoc'
require_relative 'keypad_helper'

class KeypadConundrumSovler < AoCExerciseSolver
  def initialize(*args)
    @codes = []
    super(*args)
  end

  def preprocess
    parse_lines do |line|
      next if line.start_with?('#')
      @codes << line.chomp
    end
  end

  def solve_part_1
    historian = Historian.new(num_directional_robots: 2)
    @codes.sum do |code|
      sum = historian.presses_for_code(code)
      complexity = code[/\d+/].to_i
      sum * complexity
    end
  end

  def solve_part_2
    # historian = Historian.new(num_directional_robots: 25)
    # @codes.sum do |code|
    #   sum = historian.presses_for_code(code)
    #   complexity = code[/\d+/].to_i
    #   sum * complexity
    # end
  end
end

class NumericalKeyPadRobot
  include KeyPadHelper
  attr_accessor :arm_position

  KEYPAD_LAYOUT = [
    ['7','8','9'],
    ['4','5','6'],
    ['1','2','3'],
    ['.','0','A']
  ].freeze

  def initialize
    @arm_position = position_for('A')
  end
end

class DirectionalKeyPadRobot
  include KeyPadHelper
  attr_accessor :arm_position

  KEYPAD_LAYOUT = [
    ['.', '^', 'A'],
    ['<', 'v', '>']
  ].freeze

  def initialize
    @arm_position = position_for('A')
  end
end

class Historian
  include KeyPadHelper

  def initialize(num_directional_robots:)
    @numerical_robot = NumericalKeyPadRobot.new
    @directional_robots = []
    num_directional_robots.times do |i|
      @directional_robots << DirectionalKeyPadRobot.new
    end
    @commands_for = {}
  end

  def presses_for_code(code)
    code.chars.sum do |char|
      # These are the commands that need to be performed on the
      # numerical robot
      commands = @numerical_robot.commands_for(char)
      commands << Command.new('A', 1)

      # These are the commands that need to be performed on the 
      # directional robots
      @directional_robots.each do |robot|
        commands.map! do |command|
          new_commands = robot.commands_for(command.direction)
          new_commands << Command.new('A', command.amount)
          new_commands
        end
        commands.flatten!
      end
      # puts commands.map(&:to_s).join(' ')
      commands.sum(&:amount)
    end
  end

  def num_commands_for(char, robots_processed)
    
  end
end

test_solver = KeypadConundrumSovler.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = KeypadConundrumSovler.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve