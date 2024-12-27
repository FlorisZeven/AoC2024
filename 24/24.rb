require_relative '../aoc'
require_relative '../helpers/graph'
require 'ruby-graphviz'

class CrossedWiresSolver < AoCExerciseSolver
  def initialize(*args)
    super(*args)
  end

  WIRE_REGEX = /(\w\d+)/

  def preprocess
    @graph = Graph.new

    initial_wire_values, gates = File.read(@input_file).split(/\n\n/)
    @initial_wire_values = initial_wire_values.chomp.split(/\n/).map do |wire|
      wire_id, wire_value = wire.match(/(\w+)\:\s(\d)/).captures
      @graph.add_state(wire_id, wire_value.to_i)
      [wire_id, wire_value.to_i]
    end

    @gates = gates.split(/\n/).map.each_with_index do |gate, i|
      in_left, type, in_right, out = gate.match(/(\w+)\s(\w+)\s(\w+)\s->\s(\w+)/).captures
      left_wire  = @graph.add_state(in_left, nil) # Does not override existing values for wire
      right_wire = @graph.add_state(in_right, nil) # Does not override existing values for wire
      gate       = @graph.add_state("#{type}_#{i}", type) # Acts as a collecting state to represent the gate
      out_wire   = @graph.add_state(out, nil)
      @graph.add_transition(out_wire, gate)
      @graph.add_transition(gate, left_wire)
      @graph.add_transition(gate, right_wire)
    end
  end

  def solve_part_1
    target_wires = @graph.states.select {|wire| wire.id.start_with?('z')}

    wire_graph = WireGraph.new(@graph)
    vals = target_wires.sort_by(&:id).reverse.map do |wire|
      wire_graph.determine_wire_value(wire)
    end
    vals.join.to_i(2)
  end

  def solve_part_2
    # Let's hecking visualize
    g = GraphViz.new(:G, :type => :digraph)
    
    @graph.states.each do |state|
      options = {}
      options[:color] = 'red' if state.id.start_with?("XOR")
      options[:color] = 'blue' if state.id.start_with?("AND")
      options[:color] = 'green' if state.id.start_with?("OR")
      options[:style] = 'bold' if state.id.start_with?('z')
      g.add_nodes(state.id, **options)
    end

    @graph.transitions.each do |state, transitions|

      transitions.each do |transition|
        g.add_edges(transition.to.id, state.id)
      end
    end

    g.output(:png => "#{@input_file}_output.png")
  end
end

class WireGraph
  attr_accessor :graph

  def initialize(graph)
    @graph = graph      
  end

  def determine_wire_value(wire)
    return wire.value if !wire.value.nil? # Known value, can return

    gate = graph.successors(wire).first
    # Recurse for unknown in-wires
    unknown_wires = graph.successors(gate).select {|unknown_wire| unknown_wire.value.nil?}
    unknown_wires.each do |unknown_wire|
      value = determine_wire_value(unknown_wire)
      unknown_wire.value = value
    end
    in_value_1, in_value_2 = graph.successors(gate).map(&:value) # These are now all known
    case gate.value
    when 'XOR' then return in_value_1 ^ in_value_2
    when 'AND' then return in_value_1 & in_value_2
    when 'OR'  then return in_value_1 | in_value_2
    end
  end
end


test_solver = CrossedWiresSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = CrossedWiresSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
