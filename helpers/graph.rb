# A graph class
class GraphNode
  attr_accessor :value
  attr_accessor :edges

  def initialize(value)
    @value = value
    @edges = []
  end

  def add_edge(index)
    @edges << index
  end
end

class Graph
  attr_accessor :nodes

  def initialize
    @nodes = []
  end

  def add_node(value)
    node = GraphNode.new(value)
    @nodes << node
    node
  end
end