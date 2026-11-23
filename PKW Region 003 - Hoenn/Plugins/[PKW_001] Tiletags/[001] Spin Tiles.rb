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
		if currentTag.spin_tile
			pbSpinTile
		end
	}
)

def pbSpinTile
	if !$DEBUG || !Input.press?(Input::CTRL)
		current_tag = $game_player.pbTerrainTag
		meta = GameData::PlayerMetadata.get($player&.character_ID || 1)
		new_charset = pbGetPlayerCharset(meta.spin_charset)
		$game_player.move_speed = SpinTileSettings::SPIN_TILE_SPEED if !@move_route_forcing
		@character_name = new_charset if new_charset
		if current_tag.spin_tile
			direction = {
				:down	=> 2,
				:left	=> 4,
				:right => 6,
				:up		=> 8
			}[current_tag.force_direction]
			case current_tag.id
				when :SpinTileUp
					$game_player.turn_up
				when :SpinTileDown
					$game_player.turn_down
				when :SpinTileRight
					$game_player.turn_right				
				when :SpinTileLeft
					$game_player.turn_left
			end
			loop do
				break if !$game_player.passable?($game_player.x, $game_player.y, $game_player.direction)
				current_tag = $game_player.pbTerrainTag
				break if current_tag.id == :SpinTileStop
				if $game_player.can_move_in_direction?(direction)
					$PokemonGlobal.spinning = true
					$game_player.straighten
					$game_player.direction = direction
					$game_player.move_forward					
					return
				end
			end
		end
	end
	$PokemonGlobal.spinning = false
end