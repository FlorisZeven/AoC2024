require_relative '../aoc'

class MonkeyMarketSolver < AoCExerciseSolver
  def initialize(*args)
    @initial_secrets = []
    super(*args)
  end

  def preprocess
    parse_lines do |line|
      @initial_secrets << line.chomp.to_i
    end
  end

  def solve_part_1
    return 'skipped'

    secret_finder = SecretFinder.new(@initial_secrets)
    secret_finder.sum_n_secrets(nth_secret: 2000)
  end

  def solve_part_2
    secret_finder = SecretFinder.new(@initial_secrets)
    secret_finder.find_best_sequence(nth_secret: 2000)
  end
end

class SecretFinder
  PRUNE_SECRET = 16777216

  def initialize(initial_secrets)
    @initial_secrets = initial_secrets
  end

  def sum_n_secrets(nth_secret:)
    @initial_secrets.sum do |initial_secret|
      nth_secret(initial_secret, nth_secret)
    end
  end

  def nth_secret(secret, n)
    n.times do |i|
      secret = next_secret(secret)
    end
    secret
  end

  # BROTHER EWWWWWWWWWWWWWWWWWWWWWW BRUTE FORCE (but < 1 minute of runtime so who cares)
  # Literally keep a hash with all possible sequences mapped to the number of bananas it gets 
  # For each secret merge it with the current hash. If sequence has been seen before, add the new number of bananas to it
  def find_best_sequence(nth_secret:)
    sequence_to_bananas = {}
    @initial_secrets.each_with_index do |initial_secret, i|
      sequence_to_bananas.merge!(sequences_for(initial_secret, nth_secret)) do |sequence, num_bananas, new_bananas|
        num_bananas + new_bananas
      end
    end
    sequences.max_by {|sequence, num_bananas| num_bananas }
  end

  def sequences_for(secret, n)
    sequence_to_price = {}
    sequence = []
    price = 0
    n.times do |i|
      next_secret = next_secret(secret)
      next_price = next_secret.digits.first # Actually last digit kek
      
      price_change = next_price - price

      sequence += [price_change]
      if sequence.length > 4
        sequence = sequence.drop(1)
        if !sequence_to_price.key?(sequence)
          sequence_to_price[sequence] = next_price # Do not override, monkey finds first sequence
        end
      end

      secret = next_secret
      price = next_price
    end
    sequence_to_price
  end
  
  def next_secret(secret)
    secret = prune(mix(secret, secret * 64))
    secret = prune(mix(secret, secret / 32))
    prune(mix(secret, secret * 2048))
  end

  def mix(secret, value)
    secret ^= value
  end

  def prune(secret)
    secret % PRUNE_SECRET
  end
end

test_solver = MonkeyMarketSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = MonkeyMarketSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve