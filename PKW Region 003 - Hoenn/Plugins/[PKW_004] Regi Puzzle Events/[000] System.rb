#-----------------------------------------------------------------------------
# Edits over_trigger? to check for regievent Events
#-----------------------------------------------------------------------------
class Game_Event < Game_Character
	def over_trigger?
		return false if @map_id != $game_player.map_id
		return false if @character_name != "" && !@through
		return false if @event.name[/hiddenitem/i]
		# Add a check for Regi Events
		return false if @event.name[/regievent/i]
		each_occupied_tile do |i, j|
			return true if self.map.passable?(i, j, 0, $game_player)
		end
		return false
	end
end

# Regi Event method
# This method sets the self switch A of a facing event to true
def pbRegiEvent(event)
	return if !event
	$game_self_switches[[$game_map.map_id, event.id, "A"]] = true
	$game_map.refresh
end

#===============================================================================
# Cut
#===============================================================================
#-----------------------------------------------------------------------------
# Edits the Cut Hidden Move Handlers to trigger regievent Events
#-----------------------------------------------------------------------------
HiddenMoveHandlers::CanUseMove.add(:CUT, proc { |move, pkmn, showmsg|
	next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_CUT, showmsg)
	facingEvent = $game_player.pbFacingEvent
	# Add the Regi Event method to the cut fieldmove
	if facingEvent && (facingEvent.name[/regievent\(cut\)/i] && 
			$game_self_switches[[$game_map.map_id, facingEvent.id, "A"]] == false)
			next true
	end
	if !facingEvent || !facingEvent.name[/cuttree/i]
		pbMessage(_INTL("You can't use that here.")) if showmsg
		next false
	end
	next true
})

HiddenMoveHandlers::UseMove.add(:CUT, proc { |move, pokemon|
	if !pbHiddenMoveAnimation(pokemon)
		pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
	end
	$stats.cut_count += 1
	facingEvent = $game_player.pbFacingEvent
	# Add the Regi Event method to the cut fieldmove
	if facingEvent && facingEvent.name[/regievent\(cut\)/i]
			pbRegiEvent(facingEvent)
			next true
	end
	pbSmashEvent(facingEvent) if facingEvent && facingEvent.name[/cuttree/i]
	next true
})

#===============================================================================
# Dig
#===============================================================================
#-----------------------------------------------------------------------------
# Edits the Dig Hidden Move Handlers to trigger regievent Events
#-----------------------------------------------------------------------------
HiddenMoveHandlers::CanUseMove.add(:DIG, proc { |move, pkmn, showmsg|
	escape = ($PokemonGlobal.escapePoint rescue nil)
	# Add the Regi Event method to the dig fieldmove
	facingEvent = $game_player.pbFacingEvent
	if facingEvent && (facingEvent.name[/regievent\(dig\)/i] && 
			$game_self_switches[[$game_map.map_id, facingEvent.id, "A"]] == false)
			next true
	end
	if !escape || escape == []
		pbMessage(_INTL("You can't use that here.")) if showmsg
		next false
	end
	if !$game_player.can_map_transfer_with_follower?
		pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
		next false
	end
	next true
})

HiddenMoveHandlers::ConfirmUseMove.add(:DIG, proc { |move, pkmn|
	escape = ($PokemonGlobal.escapePoint rescue nil)
	# Add the Regi Event method to the dig fieldmove
	facingEvent = $game_player.pbFacingEvent
	if facingEvent && (facingEvent.name[/regievent\(dig\)/i] && 
			$game_self_switches[[$game_map.map_id, facingEvent.id, "A"]] == false)
			next true
	end
	next false if !escape || escape == []
	mapname = pbGetMapNameFromId(escape[0])
	next pbConfirmMessage(_INTL("Want to escape from here and return to {1}?", mapname))
})

HiddenMoveHandlers::UseMove.add(:DIG, proc { |move, pokemon|
	# Add the Regi Event method to the dig fieldmove
	facingEvent = $game_player.pbFacingEvent
	if facingEvent && facingEvent.name[/regievent\(dig\)/i]
		if !pbHiddenMoveAnimation(pokemon)
			pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		end
		pbRegiEvent(facingEvent)
		next true
	end
	escape = ($PokemonGlobal.escapePoint rescue nil)
	if escape
		if !pbHiddenMoveAnimation(pokemon)
			pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		end
		pbFadeOutIn do
			$game_temp.player_new_map_id		= escape[0]
			$game_temp.player_new_x				 = escape[1]
			$game_temp.player_new_y				 = escape[2]
			$game_temp.player_new_direction = escape[3]
			pbDismountBike
			$scene.transfer_player
			$game_map.autoplay
			$game_map.refresh
		end
		pbEraseEscapePoint
		next true
	end
	next false
})

#===============================================================================
# Flash
#===============================================================================
#-----------------------------------------------------------------------------
# Edits the Flash Hidden Move Handlers to trigger regievent Events
#-----------------------------------------------------------------------------
HiddenMoveHandlers::CanUseMove.add(:FLASH, proc { |move, pkmn, showmsg|
	next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_FLASH, showmsg)
	# Add the Regi Event method to the flash fieldmove
	facingEvent = $game_player.pbFacingEvent
	if facingEvent && (facingEvent.name[/regievent\(flash\)/i] && 
			$game_self_switches[[$game_map.map_id, facingEvent.id, "A"]] == false)
			next true
	end
	if !$game_map.metadata&.dark_map
		pbMessage(_INTL("You can't use that here.")) if showmsg
		next false
	end
	if $PokemonGlobal.flashUsed
		pbMessage(_INTL("Flash is already being used.")) if showmsg
		next false
	end
	next true
})

HiddenMoveHandlers::UseMove.add(:FLASH, proc { |move, pokemon|
	darkness = $game_temp.darkness_sprite
	# Add the Regi Event method to the flash fieldmove
	facingEvent = $game_player.pbFacingEvent
	if facingEvent && facingEvent.name[/regievent\(flash\)/i]
		if !pbHiddenMoveAnimation(pokemon)
			pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		end
		pbRegiEvent(facingEvent)
		next true
	end
	next false if !darkness || darkness.disposed?
	if !pbHiddenMoveAnimation(pokemon)
		pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
	end
	$PokemonGlobal.flashUsed = true
	$stats.flash_count += 1
	duration = 0.7
	pbWait(duration) do |delta_t|
		darkness.radius = lerp(darkness.radiusMin, darkness.radiusMax, duration, delta_t)
	end
	darkness.radius = darkness.radiusMax
	next true
})

#===============================================================================
# Rock Smash
#===============================================================================
#-----------------------------------------------------------------------------
# Edits the Rock Smash Hidden Move Handlers to trigger regievent Events
#-----------------------------------------------------------------------------

HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH, proc { |move, pkmn, showmsg|
	next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH, showmsg)
	facingEvent = $game_player.pbFacingEvent
	# Add the Regi Event method to the rocksmash fieldmove
	if facingEvent && (facingEvent.name[/regievent\(rocksmash\)/i] && 
			$game_self_switches[[$game_map.map_id, facingEvent.id, "A"]] == false)
			next true
	end
	if !facingEvent || !facingEvent.name[/smashrock/i]
		pbMessage(_INTL("You can't use that here.")) if showmsg
		next false
	end
	next true
})

HiddenMoveHandlers::UseMove.add(:ROCKSMASH, proc { |move, pokemon|
	if !pbHiddenMoveAnimation(pokemon)
		pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
	end
	$stats.rock_smash_count += 1
	facingEvent = $game_player.pbFacingEvent
	# Add the Regi Event method to the rocksmash fieldmove
	if facingEvent && facingEvent.name[/regievent\(rocksmash\)/i]
			pbRegiEvent(facingEvent)
			next true
	end
	if facingEvent
		pbSmashEvent(facingEvent)
		pbRockSmashRandomEncounter
	end
	next true
})