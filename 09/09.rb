require_relative '../aoc'

class DiskFragmenterSolver < AoCExerciseSolver
  attr_accessor :disk_map
  attr_accessor :free_blocks

  FreeBlock = Struct.new(:index, :size)

  def initialize(*args)
    @disk_map = []
    @free_blocks = []
    super
  end

  def preprocess
    @disk_map = File.read(input_file).chars
  end

  def unpack_disk_map
    unpacked_disk_map = []
    id = 0
    @disk_map.each_with_index do |char, i|
      if i.even? # Handle file
        unpacked_disk_map << Array.new(char.to_i, id)
        id += 1
      else # Handle free space
        unpacked_disk_map << Array.new(char.to_i, nil)
      end
    end
    unpacked_disk_map
  end

  def index_disk_map(disk_map)
    disk_map.each_with_index do |block, i|
      next if !block.first.nil? # free space
      
      @free_blocks << FreeBlock.new(i, block.size)
    end
  end

  def compact_disk_map(disk_map)
    # We must process one bit of a block at a time, so flatten
    disk_map.flatten!

    left = 0
    right = disk_map.length - 1

    until left > right do
      # Find next free space from left
      if !disk_map[left].nil?
        left += 1
      # Find next non-free space from right
      elsif disk_map[right].nil?
        right -= 1
      # If preconditions holds, swap
      else
        disk_map[left], disk_map[right] = disk_map[right], disk_map[left]
      end
    end

    disk_map
  end

  def calculate_checksum(disk_map)
    disk_map.map.with_index do |char, i|
      if char.nil?
        0
      else
        char.to_i * i
      end
    end.sum
  end

  def solve_part_1
    unpacked_disk_map = unpack_disk_map

    compacted_disk_map = compact_disk_map(unpacked_disk_map)

    calculate_checksum(compacted_disk_map)
  end
  
  # Very ugly ew
  def smart_compact_disk_map(disk_map)
    i = disk_map.length - 1
    disk_map.reverse_each do |block|
      if block.first.nil?
        i -= 1
        next
      end

      @free_blocks.each_with_index do |free_block, fb_i|
        break if free_block.index >= i
        # Find first index that fits
        diff = free_block.size - block.size
        if diff.zero?
          # Swap blocks in disk map
          disk_map[free_block.index], disk_map[i] = disk_map[i], disk_map[free_block.index]
          # Remove current block from free blocks
          @free_blocks.delete_at(fb_i)
          break
        elsif diff.positive?
          disk_map.insert(free_block.index, block) # Put block left of free space
          disk_map[free_block.index + 1].shift(block.size) # Remove free space
          disk_map[i+1] = disk_map[i+1].map { nil } # And remove block that was moved
          # Update free block indices
          @free_blocks.each {|b| b.index += 1 if b.index >= free_block.index}
          @free_blocks[fb_i].size -= block.size
          
          break
        end
      end

      i -= 1
    end

    disk_map
  end
  
  def solve_part_2
    unpacked_disk_map = unpack_disk_map.reject{|block| block.empty? }
    index_disk_map(unpacked_disk_map)

    compacted_disk_map = smart_compact_disk_map(unpacked_disk_map)
    #  compacted_disk_map.flatten
    calculate_checksum(compacted_disk_map.flatten)
  end
end

test_solver = DiskFragmenterSolver.new(__FILE__.sub('.rb', '_test.txt'))
test_solver.preprocess
test_solver.solve

solver = DiskFragmenterSolver.new(__FILE__.sub('.rb', '_input.txt'))
solver.preprocess
solver.solve
