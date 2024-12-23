# A graph transition
class Transition
  attr_accessor :from, :to, :weight

  def initialize(from, to, weight)
    @from = from
    @to = to
    @weight = weight
  end
end

# A graph state
class State
  attr_accessor :value

  def initialize(value)
    @value = value
  end
end

# A graph
class Graph
  attr_accessor :states, :transitions, :initial_state, :final_state

  def initialize
    @states = []
    @transitions = Hash.new { |k, v| k[v] = [] }
  end

  def add_state(value)
    state = @states.find { |s| s.value == value }
    unless state
      state = State.new(value)
      @states << state
    end
    state
  end

  def add_transition(from, to, weight = nil)
    transition = Transition.new(from, to, weight)
    @transitions[from] << transition
    transition
  end
end
