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
		if current_tag.spin_tile
			direction = {
				:down	=> 2,
				:left	=> 4,
				:right => 6,
				:up		=> 8
			}[current_tag.force_direction]
			loop do
				break if !event.passable?($game_player.x, $game_player.y, $game_player.direction)
				tag = $game_player.pbTerrainTag
				break if tag.id == :SpinTileStop
				if $game_player.can_move_in_direction?(direction)
					$PokemonGlobal.spinning = true
					$game_player.straighten
					$game_player.direction = direction
					new_charset = pbGetPlayerCharset(meta.spin_charset)
					$game_player.move_forward					
					return
				end
			end
		end
	end
	$PokemonGlobal.spinning = false
end