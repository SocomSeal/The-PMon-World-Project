#-----------------------------------------------------------------------------
# Infinite Rare Candy Item
#-----------------------------------------------------------------------------
ItemHandlers::UsableOnPokemon.add(:INFINICANDY, proc { |item, pkmn|
	next pkmn.level < GameData::GrowthRate.max_level
})
ItemHandlers::UseOnPokemonMaximum.add(:INFINICANDY, proc { |item, pkmn|
	next GameData::GrowthRate.max_level - pkmn.level
})
ItemHandlers::UseOnPokemon.add(:INFINICANDY, proc { |item, qty, pkmn, screen|
	if pkmn.shadowPokemon?
		screen.show_message(_INTL("It won't have any effect."))
		next false
	end
	if pkmn.level >= GameData::GrowthRate.max_level
		new_species = pkmn.check_evolution_on_level_up
		if !Settings::RARE_CANDY_USABLE_AT_MAX_LEVEL || !new_species
			screen.show_message(_INTL("It won't have any effect."))
			next false
		end
		# Check for evolution
		pbFadeOutInWithMusic do
			evo_screen = PokemonEvolutionScene.new
			evo_screen.pbStartScreen(pkmn, new_species)
			evo_screen.pbEvolution
			evo_screen.pbEndScreen
			screen.refresh if screen.is_a?(UI::Party)
		end
		next true
	end
	# Level up
	levelUpEffect = Settings::REGION_MUSIC_LEVEL_UP_ARRAY[pbGetCurrentRegion]
	if !levelUpEffect || levelUpEffect == ""
		levelUpEffect = Settings::REGION_MUSIC_LEVEL_UP_ARRAY[0]
	end
	pbSEPlay(levelUpEffect)
	pbChangeLevel(pkmn, pkmn.level + qty, screen)
	screen.refresh_party
	screen.refresh
	next true
})

#-----------------------------------------------------------------------------
# Infinite Max Repel Item
#-----------------------------------------------------------------------------
ItemHandlers::UseInField.add(:INFINIREPEL, proc { |item|
	next pbRepel(item, 250)
})