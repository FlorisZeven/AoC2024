require_relative '../aoc'
require 'set'

class RaceConditionSolver < AoCExerciseSolver
  def initialize(min_cheat_report, *args)
    @min_cheat_report = min_cheat_report
    super(*args)
  end

  def preprocess
    @track = File.read(@input_file).split(/\n/).map(&:chars)
  end

  def solve_part_1
    race_cheater = RaceCheater.new(@track, min_cheat_report: @min_cheat_report, max_cheat_duration: 2)
    race_cheater.discover_track
    race_cheater.find_cheats
  end

  def solve_part_2
    race_cheater = RaceCheater.new(@track, min_cheat_report: @min_cheat_report, max_cheat_duration: 20)
    race_cheater.discover_track
    race_cheater.find_cheats
  end
end

class RaceCheater
  attr_accessor :track, :track_index, :max_cheat_duration

  DIRECTIONS = [:up, :down, :left, :right]
  START_CHAR = 'S'
  END_CHAR = 'E'
  WALL_CHAR = '#'

  def initialize(track, min_cheat_report: 2, max_cheat_duration: 2)
    @track = track
    @max_cheat_duration = max_cheat_duration
    @min_cheat_report = min_cheat_report
    @track_index = {}
  end

  def start_position
    @start_position ||= position_for_char(END_CHAR)
  end

  def end_position
    @end_position ||= position_for_char(END_CHAR)
  end

  # Discovers the track and stores the run through it (assumes only one way to exit)
  def discover_track
    index = 0
    current_position = position_for_char(START_CHAR)
    prev_position = nil
    
    loop do
      @track_index[current_position] = index

      break if current_position == end_position

      DIRECTIONS.each do |direction|
        new_position = next_position_for(current_position, direction)
        next if position_value(new_position) == WALL_CHAR || new_position == prev_position

        # Now, new position stores a track position we have not seen yet
        prev_position = current_position
        current_position = new_position
        index += 1
        break # Don't process more directions
      end
    end
  end

  # Finds cheats by comparing pairs of path indices. Compare their position on
  # the track if their manhattan is less than 20.
  def find_cheats
    raise 'We need a track index before we can find cheats' if @track_index.empty?

    @track_index.sum do |position, index|
      @track_index.count do |cheat_position, cheat_index|
        distance = manhattan_distance(position, cheat_position)
        next if distance > @max_cheat_duration # We cooked too much, Jesse

        cheat_index - distance >= index + @min_cheat_report
      end
    end
  end

  def position_value(position)
    x, y = position
    @track[y][x]
  end

  def next_position_for(position, direction, distance: 1)
    x, y = position
    case direction
    when :up    then [x, y - distance]
    when :down  then [x, y + distance]
    when :left  then [x - distance, y]
    when :right then [x + distance, y]
    end
  end

  def manhattan_distance(pos1, pos2)
    x1, y1 = pos1
    x2, y2 = pos2
    (x1 - x2).abs + (y1 - y2).abs
  end

  def in_bounds?(position)
    x, y = position
    x.between?(0, @track[0].length - 1) && y.between?(0, @track.length - 1)
  end

  def position_for_char(char)
    char_y = @track.index { |r| r.include?(char) }
    char_x = @track[char_y].index(char)
    [char_x, char_y]
  end
end

test_solver = RaceConditionSolver.new(50, __FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = RaceConditionSolver.new(100, __FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve