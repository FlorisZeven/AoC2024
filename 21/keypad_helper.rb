module KeyPadHelper
  Command = Struct.new(:direction, :amount) do
    def to_s
      direction * amount
    end
  end

  # Output a set of moves to bring the arm to that position
  # We assume it happens, so move the arm position.
  def commands_for(char) 
    arm_x,  arm_y  = @arm_position
    char_x, char_y = position_for(char)
    dx = arm_x - char_x
    dy = arm_y - char_y

    # The order of commands for directional keypads is vital. This order was found by hand.
    # In general, we want to switch directions as little as possible
    # We also always do < first, then ^v, then >. 
    # This ensures we are as close as possible to A after these commands are finished
    commands = []
    
    commands << Command.new('<', dx)     if dx.positive?
    commands << Command.new('v', dy.abs) if dy.negative?
    commands << Command.new('^', dy)     if dy.positive?
    commands << Command.new('>', dx.abs) if dx.negative?

    # Our optimal commmand order does not always work, because it may cross a gap (.)
    # The conditions for this differ per keypad because the gap is in a different position
    if instance_of?(::NumericalKeyPadRobot) &&
       (dy.negative? && dx.negative? && value_for([arm_x, char_y]) == '.' || # v> passes .
        dy.positive? && dx.positive? && value_for([char_x, arm_y]) == '.')   # <^ passes .
      commands.reverse!  
    end
    
    if instance_of?(::NumericalKeyPadRobot) &&
       (dy.negative? && dx.positive? && value_for([arm_x, char_y]) == '.' ||  # <v passes .
        dy.positive? && dx.negative? && value_for([char_x, arm_y]) == '.')    # ^> passes .
      commands.reverse!  
    end

    @arm_position = [char_x, char_y]

    commands
  end

  def position_for(char)
    layout = self.class::KEYPAD_LAYOUT
    
    char_y = layout.index { |r| r.include?(char) }
    char_x = layout[char_y].index(char)
    [char_x, char_y]
  end

  def value_for(position)
    x, y = position
    layout = self.class::KEYPAD_LAYOUT

    return nil if layout[y].nil? || layout[y][x].nil? # Out of bounds  check

    layout[y][x] 
  end
end