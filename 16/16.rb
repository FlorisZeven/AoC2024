require_relative '../aoc'
require_relative '../helpers/graph'
require 'set'

class ReindeerMazeSolver < AoCExerciseSolver
  def initialize(*args)
    super
  end

  def preprocess
    @maze_grid = File.read(@input_file).split(/\n/).map(&:chars)
  end

  def solve_part_1
    maze_searcher = MazeSearcher.new(@maze_grid)
    maze_searcher.convert_to_graph
    maze_searcher.find_lowest_cost
  end

  def solve_part_2

  end
end

class MazeSearcher
  DIRECTIONS = [:up, :down, :left, :right].freeze
  WALL_CHAR  = '#'.freeze
  EMPTY_CHAR = '.'.freeze
  START_CHAR = 'S'.freeze
  END_CHAR   = 'E'.freeze

  def initialize(maze)
    @maze = maze
  end

  def find_lowest_cost
    # TODO: UCS
  end

  def convert_to_graph
    graph = Graph.new
    initial_state = current_state = graph.add_state(start_position)
    graph.initial_state = initial_state

    visited = Set.new
    to_visit = [current_state]

    # Discover all graph nodes
    until to_visit.empty?
      current_state = to_visit.pop

      x, y = current_state.value

      DIRECTIONS.each do |direction|
        next_x, next_y = next_coord_for(x, y, direction)

        # Skip walls
        next if @maze[next_y][next_x] == WALL_CHAR
        # Skip states we have seen or will see in the future
        next if visited.map(&:value).include?([next_x, next_y])
        next if to_visit.map(&:value).include?([next_x, next_y])

        next_state = graph.add_state([next_x, next_y])

        graph.final_state = next_state if @maze[next_y][next_x] == END_CHAR

        graph.add_transition(current_state, next_state)
        graph.add_transition(next_state, current_state)

        to_visit << next_state
      end

      visited << current_state
    end

    @graph = graph
  end

  def start_position
    @start_position ||= position_for_char(START_CHAR)
  end

  def end_position
    @end_position ||= position_for_char(END_CHAR)
  end

  def position_for_char(char)
    char_y = @maze.index { |r| r.include?(char) }
    char_x = @maze[char_y].index(char)
    [char_x, char_y]
  end

  def next_coord_for(x, y, direction)
    case direction
    when :up    then [x, y - 1]
    when :down  then [x, y + 1]
    when :left  then [x - 1, y]
    when :right then [x + 1, y]
    end
  end
end

test_solver = ReindeerMazeSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = ReindeerMazeSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve