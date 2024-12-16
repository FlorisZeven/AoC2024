require_relative '../aoc'
require_relative '../helpers/graph'
require 'set'
require 'rb_heap'

class ReindeerMazeSolver < AoCExerciseSolver
  DIRECTIONS = [:up, :down, :left, :right]
  INITIAL_DIRECTION = :right
  START_CHAR = 'S'
  END_CHAR = 'E'
  WALL_CHAR = '#'

  Cell = Struct.new(:position, :cost, :direction, keyword_init: true)
  
  def initialize(*args)
    super
  end

  def preprocess
    @maze = File.read(@input_file).split(/\n/).map(&:chars)
    start_position = position_for_char(START_CHAR)
    end_position = position_for_char(END_CHAR)
    @cost, @visited = dijkstra(start_position, end_position)
  end

  def solve_part_1
    @cost
  end

  def solve_part_2
    @visited
  end
  
  def dijkstra(start_position, end_position)
    prev = Hash.new {|k,v| k[v] = []}
    costs = {[start_position, INITIAL_DIRECTION] => 0}
    frontier = Heap.new{ |a, b| a.cost < b.cost }
    frontier.add(Cell.new(position: start_position, cost: 0, direction: INITIAL_DIRECTION))

    final_cost = nil
    final_cell = nil

    until frontier.empty?      
      cell = frontier.pop

      next if final_cost && cell.cost > final_cost

      if cell.position == end_position
        final_cell = cell
      end

      # For each state
      DIRECTIONS.each do |next_direction|
        x, y = cell.position
        next_position = next_coord_for(x, y, next_direction)
        
        next_x, next_y = next_position
        next if @maze[next_y][next_x] == WALL_CHAR

        # next_direction = new_direction(cell.position, next_position)
        next_cost = if next_direction != cell.direction
                      cell.cost + 1001 # We move and rotate in one go
                    else
                      cell.cost + 1
                    end
        
        next_cell = Cell.new(position: next_position, cost: next_cost, direction: next_direction)

        next_key = [next_position, next_direction]
        current_key = [cell.position, cell.direction]
        if !costs.key?(next_key) || next_cost < costs[next_key]
          costs[next_key] = next_cost
          frontier.add(next_cell)
          prev[next_key] << current_key
        elsif next_cost == costs[next_key]
          prev[next_key] << current_key
        end
      end
    end

    # Postprocess

    visited = Set.new
    cells_to_process = [[final_cell.position, final_cell.direction]]
    until cells_to_process.empty?
      # byebug
      cell_to_process = cells_to_process.pop
      visited << cell_to_process.first
      cells_to_process.concat(prev[cell_to_process]) if prev.key?(cell_to_process)
    end
    
    @maze.each_index do |y|
      @maze[y].each_index do |x|
        @maze[y][x] = ' ' if visited.include?([x, y])
      end
    end

    @maze.each {|r| puts r.join }
    
    return [final_cell.cost, visited.size]
  end

  def new_direction(current_position, next_position)
    x, y = current_position
    next_x, next_y = next_position

    if x < next_x
      :right
    elsif x > next_x
      :left
    elsif y < next_y
      :down 
    elsif y > next_y
      :up
    else
      raise 'Cannot determine new direction'
    end
  end

  def next_coord_for(x, y, direction)
    case direction
    when :up    then [x, y - 1]
    when :down  then [x, y + 1]
    when :left  then [x - 1, y]
    when :right then [x + 1, y]
    end
  end

  def position_for_char(char)
    char_y = @maze.index { |r| r.include?(char) }
    char_x = @maze[char_y].index(char)
    [char_x, char_y]
  end
end

test_solver = ReindeerMazeSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = ReindeerMazeSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve