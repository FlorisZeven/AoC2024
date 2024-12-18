require_relative '../aoc'
require 'rb_heap'

class RamRunSolver < AoCExerciseSolver
  def initialize(*args)
    @bytes = []

    super(*args)

    # Ew but I hate switching numbers
    if @input_file == __FILE__.sub('.rb', '_test.txt')
      @memory_size = 7
      @num_bytes_part1 = 12
    elsif @input_file == __FILE__.sub('.rb', '_input.txt')
      @memory_size = 71
      @num_bytes_part1 = 1024
    end
  end

  def preprocess
    parse_lines do |line|
      @bytes << line.match(/(\d+),(\d+)/).captures.map(&:to_i)
    end
  end

  def solve_part_1
    memory_space = MemorySpace.new(@memory_size, @bytes)
    memory_space.process_bytes_from_start(@num_bytes_part1)
    memory_space.lowest_cost_start_to_end
  end

  def solve_part_2
    memory_space = MemorySpace.new(@memory_size, @bytes)

    # Brute force solution (~20 seconds)
    # part_2_brute_force(memory_space)

    # Binary Search solution (< 1 second)
    part_2_binary_search(memory_space)
  end

  def part_2_brute_force(memory_space)
    # We know there is a path up to part 1
    memory_space.process_bytes_from_start(@num_bytes_part1)

    @num_bytes_part1.upto(@bytes.length) do |byte_index|
      byte = @bytes[byte_index]
      memory_space.process_byte(byte)
      result = memory_space.lowest_cost_start_to_end
      return byte if result == 'No solution'
    end
  end

  def part_2_binary_search(memory_space)
    # We know there is a path up to part 1
    left = @num_bytes_part1
    right = @bytes.length
    index = nil
    middle = (left + right) / 2

    # If the index has not updated, we have found the first index where there is no solution
    until index == middle
      index = middle
      memory_space.process_bytes_from_start(index)
      result = memory_space.lowest_cost_start_to_end
      # Update left/right index based on result
      result == 'No solution' ? right = index : left = index

      middle = (left + right) / 2
    end

    @bytes[index]
  end
end

class MemorySpace
  attr_reader :memory, :bytes

  DIRECTIONS      = %i[up down left right].freeze
  CORRUPTED_CHAR  = '#'.freeze
  EMPTY_CHAR      = '.'.freeze

  Cell = Struct.new(:position, :cost, keyword_init: true)

  def initialize(memory_size, bytes)
    @memory = nil
    @memory_size = memory_size
    @bytes = bytes
    @start_position = [0, 0]
    @end_position = [@memory_size - 1, @memory_size - 1]

    clear_memory
  end

  def clear_memory
    @memory = Array.new(@memory_size) { Array.new(@memory_size, '.') }
  end

  def process_bytes_from_start(num_bytes)
    clear_memory
    @bytes.take(num_bytes).each { |byte| process_byte(byte) }
  end

  def process_byte(byte)
    byte_x, byte_y = byte
    @memory[byte_y][byte_x] = CORRUPTED_CHAR
  end

  # Essentially Dijkstra
  def lowest_cost_start_to_end
    initial_cell = Cell.new(position: @start_position, cost: 0)
    frontier = Heap.new { |a, b| a.cost < b.cost }
    frontier.add(initial_cell)
    costs = { initial_cell.position => initial_cell.cost }

    until frontier.empty?
      cell = frontier.pop
      return cell.cost if cell.position == @end_position

      DIRECTIONS.each do |direction|
        next_position = next_coord_for(cell.position, direction)
        next if out_of_bounds?(next_position) || corrupted?(next_position)

        next_cost = cell.cost + 1

        next_cell = Cell.new(position: next_position, cost: next_cost)

        if !costs.key?(next_position) || next_cost < costs[next_position]
          costs[next_position] = next_cost
          frontier.add(next_cell)
        end
      end
    end

    'No solution'
  end

  private

  def corrupted?(position)
    x, y = position
    @memory[y][x] == CORRUPTED_CHAR
  end

  def out_of_bounds?(position)
    x, y = position
    !x.between?(0, @memory_size - 1) || !y.between?(0, @memory_size - 1)
  end

  def next_coord_for(position, direction)
    x, y = position
    case direction
    when :up    then [x, y - 1]
    when :down  then [x, y + 1]
    when :left  then [x - 1, y]
    when :right then [x + 1, y]
    end
  end
end

test_solver = RamRunSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = RamRunSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve