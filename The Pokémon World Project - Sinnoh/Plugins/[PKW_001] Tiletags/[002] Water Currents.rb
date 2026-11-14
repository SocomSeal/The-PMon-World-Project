class PokemonGlobalMetadata
  attr_accessor :current_sliding
  
  def current_sliding
    @current_sliding = false if !@current_sliding
    return @current_sliding
  end
end

EventHandlers.add(:on_step_taken, :slide_player,
  proc { |event|
    next if !$scene.a?(Scene_Map)
    next if event != $game_player
    currentTag = $game_player.pbTerrainTag
    if currentTag.water_current || $PokemonGlobal.current_sliding
	  pbWaterCurrent
    end
  }
)

def pbWaterCurrent(event = nil)
  $game_temp.surf_base_coords = nil
  event = $game_player if !event
  return if !event
  tag = event.pbTerrainTag
  return if !tag.water_current
  case tag.id
    when :CurrentUp
	  event.turn_up
	when :CurrentRight
	  event.turn_right
	when :CurrentLeft
	  event.turn_left
	when :CurrentDown
	  event.turn_down
  end
  return if !event.passable?(event.x, event.y, event.direction)
  return if !$game_player.pbFacingTerrainTag.can_surf
  if $PokemonGlobal.current_sliding == false
    event.straighten
  end
  $PokemonGlobal.current_sliding = true
  loop do
    tag = event.pbTerrainTag
    break if !tag.water_current
	case tag.id
      when :CurrentUp
		event.turn_up
	  when :CurrentRight
		event.turn_right
	  when :CurrentLeft
		event.turn_left
	  when :CurrentDown
		event.turn_down
	end
    break if !event.passable?(event.x, event.y, event.direction)
    break if !$game_player.pbFacingTerrainTag.can_surf
    event.move_forward
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  event.center(event.x, event.y)
  $PokemonGlobal.current_sliding = false
end

# Overwrites base function
def encounter_possible_here?
  terrain_tag = $game_map.terrain_tag($game_player.x, $game_player.y)
  return false if terrain_tag.water_current
  return true if $PokemonGlobal.surfing
  return false if terrain_tag.ice
  return true if has_cave_encounters?   # i.e. this map is a cave
  return true if has_land_encounters? && terrain_tag.land_wild_encounters
  return false
end