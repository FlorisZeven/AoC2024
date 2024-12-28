require_relative '../aoc'
require 'matrix'

class CodeChronicleSolver < AoCExerciseSolver
  def initialize(*args)
    super(*args)
  end

  def preprocess
    locks_or_keys = File.read(@input_file).split(/\n\n/)
    @locks = []
    @keys = []

    locks_or_keys.each do |lock_or_key|
      lock_or_key.start_with?('#') ? @locks << lock_or_key : @keys << lock_or_key
    end

    @locks.map! { |lock| convert_lock_or_key(lock) }
    @keys.map! { |key| convert_lock_or_key(key) }
  end

  def convert_lock_or_key(lock_or_key)
    lock_or_key.split(/\n/).map(&:chars)[1...-1].transpose.map { |col| col.count('#') }
  end

  def solve_part_1
    tumbler_unlocker = TumblerUnlocker.new(@locks, @keys)
    tumbler_unlocker.find_lock_key_combinations
  end

  def solve_part_2
    # No solution
  end
end

class TumblerUnlocker
  attr_accessor :locks, :keys

  def initialize(locks, keys)
    @locks = locks
    @keys = keys
  end

  def find_lock_key_combinations
    @locks.sum do |lock|
      @keys.sum do |key|
        lock.each_index.any? { |i| lock[i] + key[i] > 5 } ? 0 : 1
      end
    end
  end
end

test_solver = CodeChronicleSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = CodeChronicleSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
