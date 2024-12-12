require_relative '../aoc'

class RedNosedReportsSolver < AoCExerciseSolver
  attr_accessor :reports

  def initialize(*args)
    @reports = []
    super
  end

  def preprocess
    parse_lines do |line|
      @reports << line.chomp.split(' ').map(&:to_i)
    end
  end
  
  def safe_report?(report)
    diff = report[1] - report[0]
    return false if diff.zero?

    increasing = diff.positive?

    report.each_cons(2).all? do |left, right|
      diff = right - left
      safe_level?(increasing, diff)
    end
  end

  # O(n) approach using the observation that an unsafe report can only be 
  # dampened to a safe report in the vicinity of the first observed unsafe level
  def safe_report_with_dampening?(report)
    ### First elem
    diff = report[1] - report[0]
    return safe_report?(report[1..]) if diff.zero? # Dupe, try again
      
    increasing = diff.positive?

    if !safe_level?(increasing, diff)
      # Try again with the first or second element removed
      return safe_report?(report[1..]) ||
             safe_report?([report.first] + report[2..])
    end

    ### Middle elem
    (1..report.length - 3).each do |i|
      diff = report[i+1] - report[i]
      return safe_report?(report[..i-1] + report[i+1..]) if diff.zero? # Dupe, try again
        
      if !safe_level?(increasing, diff)
        # Try again by either removing the current or next element ...
        if i != 1 
          return safe_report?(report[..i-1] + report[i+1..]) || 
                 safe_report?(report[..i]   + report[i+2..])  
        # ... except for the second element, as inc/dec can still flip.
        # Ex: report [2,6,5,4] will fail at (6,5) since it no longer increases, but removing the 
        # first element allows for a decreasing report [6,5,4]
        else
          return safe_report?(report[i..])                   || 
                 safe_report?(report[..i-1] + report[i+1..]) || 
                 safe_report?(report[..i]   + report[i+2..])
        end
      end
    end

    ### Final elem
    diff = report[report.length - 1] - report[report.length - 2]
    return safe_report?(report[..report.length-2]) if diff.zero? # Dupe, try again
      
    if !safe_level?(increasing, diff)
      # Try again by either removing the last or second to last element
      return safe_report?(report[..report.length-2]) || 
             safe_report?(report[..report.length-3] + [report.last])
    end

    true
  end

  def safe_level?(increasing, diff)
    (increasing && diff.between?(1,3)) || (!increasing && diff.between?(-3, -1)) 
  end

  def solve_part_1
    reports.select do |report|
      safe_report?(report)
    end.size
  end

  def solve_part_2
    reports.select do |report|
      safe_report_with_dampening?(report)
    end.size
  end
end

solver = RedNosedReportsSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve