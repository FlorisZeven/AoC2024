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
      pp [sum, complexity]
      sum * complexity
    end
  end

  def solve_part_2
    historian = Historian.new(num_directional_robots: 25)
    @codes.sum do |code|
      sum = historian.presses_for_code(code)
      complexity = code[/\d+/].to_i
      sum * complexity
    end
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
    @num_directional_robots = num_directional_robots

    @numerical_robot = NumericalKeyPadRobot.new
    @directional_robots = num_directional_robots.times.map do |i|
      DirectionalKeyPadRobot.new
    end

    @cache_num_commands = {}
  end

  def presses_for_code(code)
    code.chars.sum do |char|
      # These are the commands that need to be performed on the
      # numerical robot
      commands = @numerical_robot.commands_for(char)
      commands << Command.new('A', 1)
      # These are the commands that need to be performed on the
      # directional robot
      commands.sum do |command|
        num_commands_for(command, depth: @num_directional_robots)
      end
    end
  end

  # Cache the number of commands for a robot of a certain depth
  def num_commands_for(command, depth:)
    return command.amount if depth == 0
    
    new_commands = @directional_robots[depth - 1].commands_for(command.direction)
    new_commands << Command.new('A', command.amount)

    sequence = new_commands.map(&:direction)
    if @cache_num_commands.key?([sequence, depth - 1])
      return @cache_num_commands[[sequence, depth - 1]]
    end

    num_commands = new_commands.sum do |new_command|
      num_commands_for(new_command, depth: depth - 1)
    end

    @cache_num_commands[[sequence, depth - 1]] = num_commands
    num_commands
  end
end

test_solver = KeypadConundrumSovler.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = KeypadConundrumSovler.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve