require_relative '../aoc'
require_relative '../helpers/graph'
require 'set'

class LANPartySolver < AoCExerciseSolver
  def initialize(*args)
    super(*args)
  end

  def preprocess
    @graph = Graph.new

    # Create graph
    parse_lines do |line|
      computer_1, computer_2 = line.scan(/\w+/)
      state_1 = @graph.add_state(computer_1)
      state_2 = @graph.add_state(computer_2)
      @graph.add_transition(state_1, state_2)
      @graph.add_transition(state_2, state_1)
    end

    @lan_party = LanParty.new(@graph)
  end

  def solve_part_1
    cliques = @lan_party.find_3_cliques
    cliques.select do |clique|
      clique.any? { |pc| pc.start_with?('t') }
    end.length
  end

  def solve_part_2
    max_clique = @lan_party.find_maximum_clique
    max_clique.sort.join(',')
  end
end

class LanParty
  attr_accessor :graph

  def initialize(graph)
    @graph = graph
  end

  def find_3_cliques
    cliques = Set.new
    @graph.states.each do |state|
      neighbours = @graph.successors(state)
      neighbours.each do |neighbour|
        neighbour_neighbours = @graph.successors(neighbour)
        overlapping_states = (neighbours & neighbour_neighbours) - [state, neighbour]
        overlapping_states.each do |overlapping_state|
          cliques << [state.value, neighbour.value, overlapping_state.value].sort
        end
      end
    end

    cliques
  end

  def find_maximum_clique
    @maximal_cliques = []
    bron_kerbosch(Set.new, Set.new(@graph.states), Set.new)
    @maximal_cliques.max_by(&:length).map(&:value)
  end

  def bron_kerbosch(r, p, x)
    @maximal_cliques << r.to_a if p.empty? && x.empty? && r.length > 2

    p.each do |state|
      neighbours = @graph.successors(state)
      bron_kerbosch(r | Set[state], p & Set[*neighbours], x & Set[*neighbours])
      p -= Set[state]
      x |= Set[state]
    end
  end
end

test_solver = LANPartySolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = LANPartySolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
