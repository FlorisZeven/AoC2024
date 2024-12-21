require_relative '../aoc'

class LinenLayoutSolver < AoCExerciseSolver
  def initialize(*args)
    super(*args)
  end

  def preprocess
    raw_patterns, raw_designs = File.read(@input_file).split(/\n\n/)
    @patterns = raw_patterns.chomp.split(', ')
    @designs = raw_designs.split(/\n/)
  end

  def solve_part_1
    tower_designer = TowerDesigner.new(@patterns, @designs)
    tower_designer.num_possible_designs
  end

  def solve_part_2
    tower_designer = TowerDesigner.new(@patterns, @designs)
    tower_designer.num_all_possible_designs
  end
end

class TowerDesigner
  attr_accessor :patterns, :designs, :possible_designs

  def initialize(patterns, designs)
    @patterns = patterns
    @designs = designs
    # Map a design (or part of a design) to the number of designs possible for that design
    @possible_designs = {}
  end
  
  def num_possible_designs
    @designs.count { |design| possible_design?(design) }
  end

  def num_all_possible_designs
    @designs.sum { |design| possible_designs_for(design) }
  end

  def possible_design?(design)
    @patterns.each do |pattern|
      return true if design == pattern # Base case

      if design.start_with?(pattern)
        remaining_design = design[pattern.length..]
        
        return true if possible_design?(remaining_design)
      end
    end

    return false 
  end

  def possible_designs_for(design)
    design_count = 0
    @patterns.each do |pattern|
      if design == pattern
        design_count += 1
      elsif design.start_with?(pattern)
        remaining_design = design[pattern.length..]
        design_count += if @possible_designs.key?(remaining_design)
                          @possible_designs[remaining_design]
                        else
                          possible_designs_for(remaining_design)
                        end
      end
    end
    # Save the number of designs possible for this design
    @possible_designs[design] = design_count

    return design_count
  end
end


test_solver = LinenLayoutSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = LinenLayoutSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve