class SpinnerBehavior
  attr_reader :event

  def initialize(event, allowed_dirs = [2,4,6,8], radius = 4, frequency = 0)
    @event = event
    @allowed_dirs = allowed_dirs
    @radius = radius
    @next_spin_time = 0
	@frequency = frequency
	
	@spin_delay 	=	[0.8]						# Default minimum - this variable dynamically updates based on the last triggered spinner
	@short_delay 	=	[0.8,1.2,1.6,2.0]
	@medium_delay 	=	[0.8,1.6,2.4,3.2]
	@long_delay 	=	[0.8,2.0,3.2,4.4]			# There is no official 'long delay' range
  end

  def update
    return if !@event || (@event.respond_to?(:erased?) && @event.erased?) || !$game_map

    if player_in_range? && player_running?
      face_player_if_possible
	  # Updates next spin interval based on currently stored range
      @next_spin_time = $stats.play_time + @spin_delay[rand(0..(@spin_delay.length - 1))]
    else
      random_spin(@frequency)
    end
  end

  #===============================================================================
  # Player detection
  #===============================================================================
  def player_in_range?
    px = $game_player.x
    py = $game_player.y
    ex = @event.x
    ey = @event.y

    dx = (px - ex).abs
    dy = (py - ey).abs

    return dx <= @radius && dy <= @radius
  end

  #===============================================================================
  # Turn toward player
  #===============================================================================
  def face_player_if_possible
    dir = direction_to_player

    if @allowed_dirs.include?(dir)
      apply_direction(dir)
    else
      apply_direction(nearest_allowed_direction(dir))
    end
  end

  def direction_to_player
    px = $game_player.x
    py = $game_player.y
    ex = @event.x
    ey = @event.y

    dx = px - ex
    dy = py - ey

    if dx.abs > dy.abs
      return dx > 0 ? 6 : 4
    else
      return dy > 0 ? 2 : 8
    end
  end

  #===============================================================================
  # Time-based randomized idle spinning
  #===============================================================================
  def random_spin(frequency = 0)
    return if $stats.play_time < @next_spin_time
	
	case frequency
		when 0
			@spin_delay = @short_delay
		when 1
			@spin_delay = @medium_delay
		when 2
			@spin_delay = @long_delay
	end
	
    # Spin happens randomly based on assigned frequency's range
    @next_spin_time = $stats.play_time + @spin_delay[rand(0..(@spin_delay.length - 1))]

    apply_direction(@allowed_dirs.sample)
  end

  #===============================================================================
  # change dir
  #===============================================================================
  def apply_direction(dir)
    return if !@event

    case dir
    when 2 then @event.turn_down
    when 4 then @event.turn_left
    when 6 then @event.turn_right
    when 8 then @event.turn_up
    end
  end

  #===============================================================================
  # Nearest allowed direction
  #===============================================================================
  def nearest_allowed_direction(target_dir)
    return target_dir if @allowed_dirs.include?(target_dir)

    case target_dir
    when 2, 8
      return (@allowed_dirs & [4,6]).sample || @allowed_dirs.sample
    when 4, 6
      return (@allowed_dirs & [2,8]).sample || @allowed_dirs.sample
    end

    return @allowed_dirs.sample
  end
 
  def player_running?
    return false if !$game_player
    return $game_player.move_speed == 4
  end
 
end