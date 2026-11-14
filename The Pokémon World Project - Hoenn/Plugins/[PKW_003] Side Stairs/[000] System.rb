#-------------------------------------------------------------------------------
# Boon's Terrain Tag Side Stairs
# v1.5a
# By Boonzeet
# Follower script by Vendily
#-------------------------------------------------------------------------------
# Sideways stairs with pseudo 'depth' effect. Please credit if used
#-------------------------------------------------------------------------------
# v1.5a - Updated for V21 (alpha)
# v1.4 - Updated for V20
# v1.3 - Updated for v19
# v1.2 - Fixed bugs with ledges, surfing and map transfers
#-------------------------------------------------------------------------------
# Config
#-------------------------------------------------------------------------------
GameData::TerrainTag.register({
  :id => :StairLeft,
  :id_number => 22,
})
GameData::TerrainTag.register({
  :id => :StairRight,
  :id_number => 23,
})
#-------------------------------------------------------------------------------
# Existing Class Extensions
#-------------------------------------------------------------------------------
def pbTurnTowardEvent(event, otherEvent)
  sx = 0
  sy = 0
  if $map_factory
    relativePos = $map_factory.getThisAndOtherEventRelativePos(otherEvent, event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  sx += (event.width - otherEvent.width) / 2.0
  sy -= (event.height - otherEvent.height) / 2.0
  return if sx == 0 && sy == 0
  if sx.abs >= sy.abs # changed to >=
    (sx > 0) ? event.turn_left : event.turn_right
  else
    (sy > 0) ? event.turn_up : event.turn_down
  end
end

class Game_Character
  alias initialize_stairs initialize
  attr_accessor :offset_x
  attr_accessor :offset_y
  attr_accessor :real_offset_x
  attr_accessor :real_offset_y

  def initialize(*args)
    @offset_x = 0
    @offset_y = 0
    @real_offset_x = 0
    @real_offset_y = 0
    initialize_stairs(*args)
  end

  alias screen_x_stairs screen_x

  def screen_x
    @real_offset_x = 0 if @real_offset_x == nil
    return screen_x_stairs + @real_offset_x
  end

  alias screen_y_stairs screen_y

  def screen_y
    @real_offset_y = 0 if @real_offset_y == nil
    return screen_y_stairs + @real_offset_y
  end

  alias updatemovestairs update_move

  def update_move
    @real_offset_x = 0 if @real_offset_x == nil
    @real_offset_y = 0 if @real_offset_y == nil
    
    if @real_offset_x != @offset_x || @real_offset_y != @offset_y
      # Ensure real-time is used in both movement and offset applications
      @real_offset_x = lerp(@real_offset_x, @offset_x, @move_time, @delta_t)
      @real_offset_y = lerp(@real_offset_y, @offset_y, @move_time, @delta_t)
    end
    
    # Call original update logic
    updatemovestairs
  end


  alias movetostairs moveto

  def moveto(x, y)
    # @real_offset_x = 0
    # @real_offset_y = 0
    # @offset_x = 0
    # @offset_y = 0
    movetostairs(x, y)
  end

  alias move_generic_stairs move_generic

  def move_generic(dir, turn_enabled = true)
    move_generic_stairs(dir, turn_enabled)
    if self.map.terrain_tag(@x, @y) == :StairLeft || self.map.terrain_tag(@x, @y) == :StairRight
      @offset_y = -16
    else
      @offset_y = 0
    end
  end

  alias move_upper_left_stairs move_upper_left
  def move_upper_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    if can_move_in_direction?(7)
      @move_initial_x = @x
      @move_initial_y = @y
      @x -= 1
      @y -= 1
      @move_timer = 0.0
      increase_steps
    end
  end

  alias move_upper_right_stairs move_upper_right
  def move_upper_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    if can_move_in_direction?(9)
      @move_initial_x = @x
      @move_initial_y = @y
      @x += 1
      @y -= 1
      @move_timer = 0.0
      increase_steps
    end
  end

  alias move_lower_left_stairs move_lower_left
  def move_lower_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    if can_move_in_direction?(1)
      @move_initial_x = @x
      @move_initial_y = @y
      @x -= 1
      @y += 1
      @move_timer = 0.0
      increase_steps
    end
  end

  alias move_lower_right_stairs move_lower_right
  def move_lower_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    if can_move_in_direction?(3)
      @move_initial_x = @x
      @move_initial_y = @y
      @x += 1
      @y += 1
      @move_timer = 0.0
      increase_steps
    end
  end

  alias can_move_from_coordinate_stairs can_move_from_coordinate?
  
  def can_move_from_coordinate?(start_x, start_y, dir, strict = false)
    # if upper right or upper left and on stairs, allow
    if dir == 7 || dir == 1
      return true if self.map.terrain_tag(start_x, start_y) == :StairLeft || self.map.terrain_tag(start_x, start_y) == :StairRight
    elsif dir == 9 || dir == 3
      return true if self.map.terrain_tag(start_x, start_y) == :StairRight || self.map.terrain_tag(start_x, start_y) == :StairLeft
    end
    return can_move_from_coordinate_stairs(start_x, start_y, dir, strict)
  end
end

class Game_Player
  alias move_generic_stairs move_generic

def move_generic(dir, turn_enabled = true)
  old_tag = self.map.terrain_tag(@x, @y).id
  old_x = @x
  old_y = @y
  new_x = @x
  new_y = @y

  has_moved = false
  if dir == 4
    if old_tag == :StairLeft && passable?(@x - 1, @y + 1, 4) && self.map.terrain_tag(@x - 1, @y + 1) == :StairLeft
      move_lower_left
      has_moved = true
    elsif old_tag == :StairRight && passable?(@x - 1, @y - 1, 6)
      move_upper_left
      has_moved = true
    end
  elsif dir == 6
    if old_tag == :StairLeft && passable?(@x + 1, @y - 1, 4)
      move_upper_right
      has_moved = true
    elsif old_tag == :StairRight && passable?(@x + 1, @y + 1, 6) && self.map.terrain_tag(@x + 1, @y + 1) == :StairRight
      move_lower_right
      has_moved = true
    end
  end
  if !has_moved
    move_generic_stairs(dir, turn_enabled)
  end
  new_tag = self.map.terrain_tag(@x, @y)
  
  if old_x != @x
    if old_tag != :StairLeft && new_tag == :StairLeft ||
       old_tag != :StairRight && new_tag == :StairRight
      self.offset_y = -16
      if (new_tag == :StairLeft && dir == 4) || (new_tag == :StairRight && dir == 6)
        @y += 1 
      end
    elsif old_tag == :StairLeft && new_tag != :StairLeft ||
          old_tag == :StairRight && new_tag != :StairRight
      self.offset_y = 0
    end
  end
end

  alias center_stairs center

  def center(x, y)
    center_stairs(x, y)
    self.map.display_x = self.map.display_x + (@offset_x || 0)
    self.map.display_y = self.map.display_y + (@offset_y || 0)
  end

  def passable?(x, y, d, strict = false)
    # Get new coordinates
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # If coordinates are outside of map
    return false if !$game_map.validLax?(new_x, new_y)
    if !$game_map.valid?(new_x, new_y)
      return false if !$map_factory
      return $map_factory.isPassableFromEdge?(new_x, new_y)
    end
    # If debug mode is ON and Ctrl key was pressed
    return true if $DEBUG && Input.press?(Input::CTRL)
    # insertion from this script
    if d == 8 && new_y > 0 # prevent player moving up past the top of the stairs
      if $game_map.terrain_tag(new_x, new_y) == :StairLeft &&
         $game_map.terrain_tag(new_x, new_y - 1) != :StairLeft
        return false
      elsif $game_map.terrain_tag(new_x, new_y) == :StairRight &&
            $game_map.terrain_tag(new_x, new_y - 1) != :StairRight
        return false
      end
    end
    #end
    return super
  end
end

class Game_Follower
  def move_through(direction)
    old_through = @through
    @through = true
    case direction
    when 1 then move_lower_left
    when 2 then move_down
    when 3 then move_lower_right
    when 4 then move_left
    when 6 then move_right
    when 7 then move_upper_left
    when 8 then move_up
    when 9 then move_upper_right
    end
    @through = old_through
  end

def move_fancy(direction, leader)
  delta_x = (direction == 6) ? 1 : (direction == 4) ? -1 : 0
  delta_y = (direction == 2) ? 1 : (direction == 8) ? -1 : 0
  dir = direction
  old_tag = self.map.terrain_tag(self.x, self.y).id
  old_x = self.x

  if direction == 4
    if old_tag == :StairLeft
      if passable?(self.x - 1, self.y + 1, 4) && self.map.terrain_tag(self.x - 1, self.y + 1) == :StairLeft
        delta_y += 1
        dir = 1
      end
    elsif old_tag == :StairRight
      if passable?(self.x - 1, self.y - 1, 6)
        delta_y -= 1
        dir = 7
      end
    end
  elsif direction == 6
    if old_tag == :StairLeft && passable?(self.x + 1, self.y - 1, 4)
      delta_y -= 1
      dir = 9
    elsif old_tag == :StairRight && passable?(self.x + 1, self.y + 1, 6) && self.map.terrain_tag(self.x + 1, self.y + 1) == :StairRight
      delta_y += 1
      dir = 3
    end
  end

  new_x = self.x + delta_x
  new_y = self.y + delta_y

  if ($game_player.x == new_x && $game_player.y == new_y) ||
     location_passable?(new_x, new_y, 10 - direction) ||
     !location_passable?(self.x, self.y, direction)
    move_through(dir)
  end

  new_tag = self.map.terrain_tag(self.x, self.y)
  if old_x != self.x
    if old_tag != :StairLeft && new_tag == :StairLeft ||
       old_tag != :StairRight && new_tag == :StairRight
      self.offset_y = -16
      @y += 1 if (new_tag == :StairLeft && direction == 4) || (new_tag == :StairRight && direction == 6)
    elsif old_tag == :StairLeft && new_tag != :StairLeft ||
          old_tag == :StairRight && new_tag != :StairRight
      self.offset_y = 0
    end
  end

  turn_towards_leader(leader)
end


  def jump_fancy(direction, leader)
    delta_x = (direction == 6) ? 2 : (direction == 4) ? -2 : 0
    delta_y = (direction == 2) ? 2 : (direction == 8) ? -2 : 0
    half_delta_x = delta_x / 2
    half_delta_y = delta_y / 2
    if location_passable?(self.x + half_delta_x, self.y + half_delta_y, 10 - direction)
      # Can walk over the middle tile normally; just take two steps
      move_fancy(direction,leader)
      move_fancy(direction,leader)
    elsif location_passable?(self.x + delta_x, self.y + delta_y, 10 - direction)
      # Can't walk over the middle tile, but can walk over the end tile; jump over
      if location_passable?(self.x, self.y, direction)
        if leader.jumping?
          @jump_speed = leader.jump_speed
        else
          # This is doubled because self has to jump 2 tiles in the time it
          # takes the leader to move one tile.
          @jump_speed = leader.move_speed * 2
        end
        jump(delta_x, delta_y)
      else
        # self's current tile isn't passable; just take two steps ignoring passability
        move_through(direction)
        move_through(direction)
      end
    end
  end

  def fancy_moveto(new_x, new_y, leader)
    if self.x - new_x == 1 && (-1..1).include?(self.y - new_y)
      move_fancy(4,leader)
    elsif self.x - new_x == -1 && (-1..1).include?(self.y - new_y)
      move_fancy(6,leader)
    elsif self.x == new_x && self.y - new_y == 1
      move_fancy(8,leader)
    elsif self.x == new_x && self.y - new_y == -1
      move_fancy(2,leader)
    elsif self.x - new_x == 2 && self.y == new_y
      jump_fancy(4, leader)
    elsif self.x - new_x == -2 && self.y == new_y
      jump_fancy(6, leader)
    elsif self.x == new_x && self.y - new_y == 2
      jump_fancy(8, leader)
    elsif self.x == new_x && self.y - new_y == -2
      jump_fancy(2, leader)
    elsif self.x != new_x || self.y != new_y
      moveto(new_x, new_y)
    end
  end

end