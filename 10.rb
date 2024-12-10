require_relative 'aoc'
require_relative 'helpers/graph'

class HoofItSolver < AoCExerciseSolver
  attr_accessor :grid
  attr_accessor :node_index

  Coord = Struct.new(:x, :y, :height)

  def initialize(*args)
    @grid = []
    @node_index = {}
    super
  end

  def preprocess
    parse_lines do |line|
      @grid << line.chomp.chars.map(&:to_i)
    end
  end

  # A hiking map is a graph with directed edges to
  def build_hiking_paths
    graph = Graph.new

    # Create node for every grid cell and populate index
    @grid.each_index do |row|
      @grid[row].each_index do |col|
        node = graph.add_node(Coord.new(row, col, @grid[row][col]))
        @node_index[[row, col]] = node
      end
    end

    # Add edges when neighbouring value is 1 higher
    graph.nodes.each do |node|
      neighbour_nodes(node).each do |neighbour_node|
        if neighbour_node.value.height - node.value.height == 1
          node.add_edge(graph.nodes.index(neighbour_node))
        end
      end
    end

    graph
  end

  # Find nodes in graph that are neighbours in the grid, this is where the
  # index comes in handy: (O(1) lookup instead of O(n))
  def neighbour_nodes(node)
    value = node.value
    neighbours = []
    neighbours << @node_index[[value.x + 1, value.y]] if @node_index.key?([value.x + 1, value.y]) # up
    neighbours << @node_index[[value.x - 1, value.y]] if @node_index.key?([value.x - 1, value.y]) # down
    neighbours << @node_index[[value.x, value.y + 1]] if @node_index.key?([value.x, value.y + 1]) # right
    neighbours << @node_index[[value.x, value.y - 1]] if @node_index.key?([value.x, value.y - 1]) # left
    neighbours
  end

  def find_trailhead_score(graph, node, visited, distinct: false)
    return 0 if !distinct && visited.include?(node)
    return 1 if node.value.height == 9 # End of path
    return 0 if node.edges.empty? # Empty path

    node.edges.sum do |edge|
      next_node = graph.nodes[edge]
      score = find_trailhead_score(graph, next_node, visited, distinct:)
      visited << next_node
      score
    end
  end

  def solve_part_1
    graph = build_hiking_paths

    trailheads = graph.nodes.select {|node| node.value.height.zero?}

    trailheads.sum do |trailhead|
      visited = []
      find_trailhead_score(graph, trailhead, visited, distinct: false)
    end
  end

  def solve_part_2
    graph = build_hiking_paths

    trailheads = graph.nodes.select {|node| node.value.height.zero?}

    trailheads.sum do |trailhead|
      visited = []
      find_trailhead_score(graph, trailhead, visited, distinct: true)
    end
  end
end

test_solver = HoofItSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = HoofItSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
