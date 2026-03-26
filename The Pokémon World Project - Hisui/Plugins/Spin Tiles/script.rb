module SpinTileSettings
  SPIN_TILE_SPEED = 3.8
end

module GameData
  class TerrainTag
    attr_reader :is_spin_tile
    attr_reader :spin_direction

    alias custom_init initialize
    def initialize(hash)
      custom_init(hash)
      @is_spin_tile = hash[:is_spin_tile] || false
      @spin_direction = hash[:spin_direction] || -1
    end
  end
end

# Update with your own id numbers.
GameData::TerrainTag.register({
  :id                     => :SpinTileUp,
  :id_number              => 20,
  :is_spin_tile           => true,
  :spin_direction         => 2
})

GameData::TerrainTag.register({
  :id                     => :SpinTileDown,
  :id_number              => 21,
  :is_spin_tile           => true,
  :spin_direction         => 0
})

GameData::TerrainTag.register({
  :id                     => :SpinTileRight,
  :id_number              => 22,
  :is_spin_tile           => true,
  :spin_direction         => 1
})

GameData::TerrainTag.register({
  :id                     => :SpinTileLeft,
  :id_number              => 23,
  :is_spin_tile           => true,
  :spin_direction         => 3
})

GameData::TerrainTag.register({
  :id                     => :SpinTileStop,
  :id_number              => 24,
  :is_spin_tile           => false,
})

class PokemonGlobalMetadata
  attr_accessor :spinning
  
  def spinning
    @spinning = false if !@spinning
    return @spinning
  end
end

EventHandlers.add(:on_step_taken, :spin_player,
  proc { |event|
    next if !$scene.is_a?(Scene_Map)
    next if event != $game_player
    currentTag = $game_player.pbTerrainTag
    if currentTag.is_spin_tile
      pbSpinTile
    end
  }
)
 
def pbSpinTile(event=nil)  
  event = $game_player if !event
  return if !event
  tag = $game_player.pbTerrainTag
  return if !tag.is_spin_tile
  prev_walk_anime = event.walk_anime
  event.move_speed == 1
  if $PokemonGlobal.spinning == false
    event.straighten
  end
  event.walk_anime = false
  case tag.id
  when :SpinTileUp
    event.turn_up
  when :SpinTileDown
    event.turn_down
  when :SpinTileRight
    event.turn_right        
  when :SpinTileLeft
    event.turn_left
  end
  if $PokemonGlobal.spinning == false
    event.pattern = tag.spin_direction
  end
  event.walk_anime = true
  $PokemonGlobal.spinning = true
  loop do
    break if !event.passable?(event.x, event.y, event.direction)
    tag = $game_player.pbTerrainTag
    break if tag.id == :SpinTileStop
    if tag.is_spin_tile
      case tag.id
      when :SpinTileUp
        event.turn_up
      when :SpinTileDown
        event.turn_down
     when :SpinTileRight
        event.turn_right        
      when :SpinTileLeft
        event.turn_left
      end
    end    
    event.move_forward
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end  
  event.center(event.x, event.y)
  event.walk_anime = prev_walk_anime  
  $PokemonGlobal.spinning = false
end

module GameData
  class PlayerMetadata

    SPIN_PROPERTY = {
      "SpinCharset" => [:spin_charset, "s"],
    }

    if defined?(self::SCHEMA)
      self::SCHEMA.merge!(SPIN_PROPERTY)
    end
    
    alias custom_init initialize
    def initialize(hash)
      custom_init(hash)
      @spin_charset = hash[:spin_charset]
    end

    def spin_charset
      return @spin_charset || @walk_charset
    end
  end
end

module SpinPlayerMovementMethods
  def set_movement_type(type)
    if type == :spinning
      meta = GameData::PlayerMetadata.get($player&.character_ID || 1)
      new_charset = pbGetPlayerCharset(meta.spin_charset)
      self.move_speed = SpinTileSettings::SPIN_TILE_SPEED if !@move_route_forcing
      @character_name = new_charset if new_charset
    else
      super(type)
    end
  end

  def can_run?
    if $PokemonGlobal.spinning
      return false
    else
      super()
    end
  end
end

class Game_Player

  prepend SpinPlayerMovementMethods

  def update_move
    if !@moved_last_frame || @stopped_last_frame
      if $PokemonGlobal.ice_sliding || @last_terrain_tag.ice
        set_movement_type(:ice_sliding)
      elsif $PokemonGlobal.spinning
        set_movement_type(:spinning)
      elsif $PokemonGlobal.descending_waterfall
        set_movement_type(:descending_waterfall)
      elsif $PokemonGlobal.ascending_waterfall
        set_movement_type(:ascending_waterfall)
      else
        faster = can_run?
        if $PokemonGlobal&.diving
          set_movement_type((faster) ? :diving_fast : :diving)
        elsif $PokemonGlobal&.surfing
          set_movement_type((faster) ? :surfing_fast : :surfing)
        elsif $PokemonGlobal&.bicycle
          set_movement_type((faster) ? :cycling_fast : :cycling)
        else
          set_movement_type((faster) ? :running : :walking)
        end
      end
      if jumping?
        if $PokemonGlobal&.diving
          set_movement_type(:diving_jumping)
        elsif $PokemonGlobal&.surfing
          set_movement_type(:surfing_jumping)
        elsif $PokemonGlobal&.bicycle
          set_movement_type(:cycling_jumping)
        else
          set_movement_type(:jumping)   # Walking speed/charset while jumping
        end
      end
    end
    was_jumping = jumping?
    super
    if was_jumping && !jumping? && !@transparent && (@tile_id > 0 || @character_name != "")
      if !$PokemonGlobal.surfing || $game_temp.ending_surf
        spriteset = $scene.spriteset(map_id)
        spriteset&.addUserAnimation(Settings::DUST_ANIMATION_ID, self.x, self.y, true, 1)
      end
    end
  end
end