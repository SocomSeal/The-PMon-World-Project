#===============================================================================
# This rb handles all regional audio edits to existing functions.
# (i.e. Cycling, Surfing, Battle BGM, Fanfare Sounds, etc.)
#===============================================================================



#===============================================================================
# Dive.
#===============================================================================
#-----------------------------------------------------------------------------
# Additionally extends pbDive and pbSurfacing to allow for
# overriding destinations through script calls.
#-----------------------------------------------------------------------------
def pbDive(x = nil, y = nil, map = nil)
	map_metadata = $game_map.metadata
	return false if !map_metadata || !map_metadata.dive_map_id
	move = :DIVE
	movefinder = $player.get_pokemon_with_move(move)
	if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE, false) || (!$DEBUG && !movefinder)
		pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
		return false
	end
	if pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
		speciesname = (movefinder) ? movefinder.name : $player.name
		pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
		pbHiddenMoveAnimation(movefinder)
		pbFadeOutIn do
			!map ? $game_temp.player_new_map_id = map_metadata.dive_map_id : $game_temp.player_new_map_id = map
			!x ? $game_temp.player_new_x		= $game_player.x : $game_temp.player_new_x = x
			!y ? $game_temp.player_new_y		= $game_player.y : $game_temp.player_new_y = y
			$game_temp.player_new_direction		= $game_player.direction
			$PokemonGlobal.surfing				= false
			$PokemonGlobal.diving				= true
			$stats.dive_count += 1
			pbUpdateVehicle
			$scene.transfer_player(false)
			$game_map.autoplay
			$game_map.refresh
		end
		return true
	end
	return false
end

def pbSurfacing(x = nil, y = nil, map = nil)
	return if !$PokemonGlobal.diving
	surface_map_id = nil
	GameData::MapMetadata.each do |map_data|
		next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
		surface_map_id = map_data.id
		break
	end
	return if !surface_map_id
	move = :DIVE
	movefinder = $player.get_pokemon_with_move(move)
	if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE, false) || (!$DEBUG && !movefinder)
		pbMessage(_INTL("Light is filtering down from above. A Pokémon may be able to surface here."))
		return false
	end
	if pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
		speciesname = (movefinder) ? movefinder.name : $player.name
		pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
		pbHiddenMoveAnimation(movefinder)
		pbFadeOutIn do
			!map ? $game_temp.player_new_map_id = surface_map_id : $game_temp.player_new_map_id = map
			!x ? $game_temp.player_new_x		= $game_player.x : $game_temp.player_new_x = x
			!y ? $game_temp.player_new_y		= $game_player.y : $game_temp.player_new_y = y
			$game_temp.player_new_direction		= $game_player.direction
			$PokemonGlobal.surfing				= true
			$PokemonGlobal.diving				= false
			pbUpdateVehicle
			$scene.transfer_player(false)
			surfbgm = Settings::REGION_MUSIC_HM_SURF_ARRAY[pbGetCurrentRegion]
			if !surfbgm || surfbgm == ""
				surfbgm = Settings::REGION_MUSIC_HM_SURF_ARRAY[0]
			end
			if !surfbgm
				surfbgm = GameData::Metadata.get.surf_BGM
			end
			(surfbgm) ? pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
			$game_map.refresh
		end
		return true
	end
	return false
end