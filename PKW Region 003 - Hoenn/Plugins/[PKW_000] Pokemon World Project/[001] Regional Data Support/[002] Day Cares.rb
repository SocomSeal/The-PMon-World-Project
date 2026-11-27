#-----------------------------------------------------------------------------
# Adds additional Day Cares for each region to PokemonGlobalMetadata
#-----------------------------------------------------------------------------
class PokemonGlobalMetadata
	# Additional Day Cares
	attr_accessor :day_care_Kanto
	attr_accessor :day_care_Sevii
	attr_accessor :day_care_Johto
	attr_accessor :day_care_Hoenn
	attr_accessor :day_care_Sinnoh
	attr_accessor :day_care_Unova
	attr_accessor :day_care_Kalos
	attr_accessor :day_care_Alola
	attr_accessor :day_care_Galar1
	attr_accessor :day_care_Galar2
	attr_accessor :day_care_Orre
	attr_accessor :day_care_Picnic
	attr_accessor :day_care_R10
	attr_accessor :day_care_R11
	attr_accessor :day_care_R12
	attr_accessor :day_care_R13
	attr_accessor :day_care_R14
	attr_accessor :day_care_R15
	attr_accessor :day_care_Spare1
	attr_accessor :day_care_Spare2
	attr_accessor :day_care_Spare3
	attr_accessor :day_care_Spare4
	attr_accessor :day_care_Spare5
	
	alias daycare_initialize initialize
	def initialize
		# Additional Day Cares
		@day_care_Kanto			= DayCare.new
		@day_care_Sevii			= DayCare.new
		@day_care_Johto			= DayCare.new
		@day_care_Hoenn			= DayCare.new
		@day_care_Sinnoh		= DayCare.new
		@day_care_Unova			= DayCare.new
		@day_care_Kalos			= DayCare.new
		@day_care_Alola			= DayCare.new
		@day_care_Galar1		= DayCare.new
		@day_care_Galar2		= DayCare.new
		@day_care_Orre			= DayCare.new
		@day_care_Picnic		= DayCare.new
		@day_care_R10			= DayCare.new
		@day_care_R11			= DayCare.new
		@day_care_R12			= DayCare.new
		@day_care_R13			= DayCare.new
		@day_care_R14			= DayCare.new
		@day_care_R15			= DayCare.new
		@day_care_Spare1		= DayCare.new
		@day_care_Spare2		= DayCare.new
		@day_care_Spare3		= DayCare.new
		@day_care_Spare4		= DayCare.new
		@day_care_Spare5		= DayCare.new
		daycare_initialize
	end
end

class DayCare
	#-----------------------------------------------------------------------------
	# Additional Day Cares
	#-----------------------------------------------------------------------------
	# Kanto
	
	def self.count_Kanto
		return $PokemonGlobal.day_care_Kanto.count
	end

	def self.egg_generated_Kanto?
		return $PokemonGlobal.day_care_Kanto.egg_generated
	end

	def self.reset_egg_counters_Kanto
		$PokemonGlobal.day_care_Kanto.reset_egg_counters
	end

	def self.get_details_Kanto(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Kanto
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Kanto(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Kanto
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Kanto(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Kanto.get_compatibility if compat_var > 0
	end

	def self.deposit_Kanto(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Kanto
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Kanto(index)
		day_care = $PokemonGlobal.day_care_Kanto
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Kanto(message, choice_var)
		day_care = $PokemonGlobal.day_care_Kanto
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Kanto
		day_care = $PokemonGlobal.day_care_Kanto
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Sevii
	
	def self.count_Sevii
		return $PokemonGlobal.day_care_Sevii.count
	end

	def self.egg_generated_Sevii?
		return $PokemonGlobal.day_care_Sevii.egg_generated
	end

	def self.reset_egg_counters_Sevii
		$PokemonGlobal.day_care_Sevii.reset_egg_counters
	end

	def self.get_details_Sevii(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Sevii
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Sevii(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Sevii
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Sevii(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Sevii.get_compatibility if compat_var > 0
	end

	def self.deposit_Sevii(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Sevii
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Sevii(index)
		day_care = $PokemonGlobal.day_care_Sevii
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Sevii(message, choice_var)
		day_care = $PokemonGlobal.day_care_Sevii
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Sevii
		day_care = $PokemonGlobal.day_care_Sevii
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Johto
	
	def self.count_Johto
		return $PokemonGlobal.day_care_Johto.count
	end

	def self.egg_generated_Johto?
		return $PokemonGlobal.day_care_Johto.egg_generated
	end

	def self.reset_egg_counters_Johto
		$PokemonGlobal.day_care_Johto.reset_egg_counters
	end

	def self.get_details_Johto(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Johto
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Johto(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Johto
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Johto(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Johto.get_compatibility if compat_var > 0
	end

	def self.deposit_Johto(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Johto
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Johto(index)
		day_care = $PokemonGlobal.day_care_Johto
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Johto(message, choice_var)
		day_care = $PokemonGlobal.day_care_Johto
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Johto
		day_care = $PokemonGlobal.day_care_Johto
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Hoenn
	
	def self.count_Hoenn
		return $PokemonGlobal.day_care_Hoenn.count
	end

	def self.egg_generated_Hoenn?
		return $PokemonGlobal.day_care_Hoenn.egg_generated
	end

	def self.reset_egg_counters_Hoenn
		$PokemonGlobal.day_care_Hoenn.reset_egg_counters
	end

	def self.get_details_Hoenn(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Hoenn
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Hoenn(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Hoenn
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Hoenn(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Hoenn.get_compatibility if compat_var > 0
	end

	def self.deposit_Hoenn(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Hoenn
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Hoenn(index)
		day_care = $PokemonGlobal.day_care_Hoenn
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Hoenn(message, choice_var)
		day_care = $PokemonGlobal.day_care_Hoenn
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Hoenn
		day_care = $PokemonGlobal.day_care_Hoenn
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Sinnoh
	
	def self.count_Sinnoh
		return $PokemonGlobal.day_care_Sinnoh.count
	end

	def self.egg_generated_Sinnoh?
		return $PokemonGlobal.day_care_Sinnoh.egg_generated
	end

	def self.reset_egg_counters_Sinnoh
		$PokemonGlobal.day_care_Sinnoh.reset_egg_counters
	end

	def self.get_details_Sinnoh(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Sinnoh
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Sinnoh(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Sinnoh
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Sinnoh(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Sinnoh.get_compatibility if compat_var > 0
	end

	def self.deposit_Sinnoh(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Sinnoh
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Sinnoh(index)
		day_care = $PokemonGlobal.day_care_Sinnoh
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Sinnoh(message, choice_var)
		day_care = $PokemonGlobal.day_care_Sinnoh
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Sinnoh
		day_care = $PokemonGlobal.day_care_Sinnoh
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Unova
	
	def self.count_Unova
		return $PokemonGlobal.day_care_Unova.count
	end

	def self.egg_generated_Unova?
		return $PokemonGlobal.day_care_Unova.egg_generated
	end

	def self.reset_egg_counters_Unova
		$PokemonGlobal.day_care_Unova.reset_egg_counters
	end

	def self.get_details_Unova(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Unova
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Unova(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Unova
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Unova(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Unova.get_compatibility if compat_var > 0
	end

	def self.deposit_Unova(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Unova
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Unova(index)
		day_care = $PokemonGlobal.day_care_Unova
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Unova(message, choice_var)
		day_care = $PokemonGlobal.day_care_Unova
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Unova
		day_care = $PokemonGlobal.day_care_Unova
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Kalos
	
	def self.count_Kalos
		return $PokemonGlobal.day_care_Kalos.count
	end

	def self.egg_generated_Kalos?
		return $PokemonGlobal.day_care_Kalos.egg_generated
	end

	def self.reset_egg_counters_Kalos
		$PokemonGlobal.day_care_Kalos.reset_egg_counters
	end

	def self.get_details_Kalos(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Kalos
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Kalos(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Kalos
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Kalos(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Kalos.get_compatibility if compat_var > 0
	end

	def self.deposit_Kalos(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Kalos
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Kalos(index)
		day_care = $PokemonGlobal.day_care_Kalos
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Kalos(message, choice_var)
		day_care = $PokemonGlobal.day_care_Kalos
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Kalos
		day_care = $PokemonGlobal.day_care_Kalos
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Alola
	
	def self.count_Alola
		return $PokemonGlobal.day_care_Alola.count
	end

	def self.egg_generated_Alola?
		return $PokemonGlobal.day_care_Alola.egg_generated
	end

	def self.reset_egg_counters_Alola
		$PokemonGlobal.day_care_Alola.reset_egg_counters
	end

	def self.get_details_Alola(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Alola
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Alola(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Alola
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Alola(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Alola.get_compatibility if compat_var > 0
	end

	def self.deposit_Alola(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Alola
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Alola(index)
		day_care = $PokemonGlobal.day_care_Alola
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Alola(message, choice_var)
		day_care = $PokemonGlobal.day_care_Alola
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Alola
		day_care = $PokemonGlobal.day_care_Alola
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Galar1
	
	def self.count_Galar1
		return $PokemonGlobal.day_care_Galar1.count
	end

	def self.egg_generated_Galar1?
		return $PokemonGlobal.day_care_Galar1.egg_generated
	end

	def self.reset_egg_counters_Galar1
		$PokemonGlobal.day_care_Galar1.reset_egg_counters
	end

	def self.get_details_Galar1(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Galar1
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Galar1(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Galar1
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Galar1(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Galar1.get_compatibility if compat_var > 0
	end

	def self.deposit_Galar1(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Galar1
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Galar1(index)
		day_care = $PokemonGlobal.day_care_Galar1
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Galar1(message, choice_var)
		day_care = $PokemonGlobal.day_care_Galar1
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Galar1
		day_care = $PokemonGlobal.day_care_Galar1
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Galar2
	
	def self.count_Galar2
		return $PokemonGlobal.day_care_Galar2.count
	end

	def self.egg_generated_Galar2?
		return $PokemonGlobal.day_care_Galar2.egg_generated
	end

	def self.reset_egg_counters_Galar2
		$PokemonGlobal.day_care_Galar2.reset_egg_counters
	end

	def self.get_details_Galar2(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Galar2
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Galar2(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Galar2
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Galar2(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Galar2.get_compatibility if compat_var > 0
	end

	def self.deposit_Galar2(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Galar2
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Galar2(index)
		day_care = $PokemonGlobal.day_care_Galar2
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Galar2(message, choice_var)
		day_care = $PokemonGlobal.day_care_Galar2
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Galar2
		day_care = $PokemonGlobal.day_care_Galar2
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Orre
	
	def self.count_Orre
		return $PokemonGlobal.day_care_Orre.count
	end

	def self.egg_generated_Orre?
		return $PokemonGlobal.day_care_Orre.egg_generated
	end

	def self.reset_egg_counters_Orre
		$PokemonGlobal.day_care_Orre.reset_egg_counters
	end

	def self.get_details_Orre(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Orre
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Orre(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Orre
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Orre(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Orre.get_compatibility if compat_var > 0
	end

	def self.deposit_Orre(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Orre
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Orre(index)
		day_care = $PokemonGlobal.day_care_Orre
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Orre(message, choice_var)
		day_care = $PokemonGlobal.day_care_Orre
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Orre
		day_care = $PokemonGlobal.day_care_Orre
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Picnic
	
	def self.count_Picnic
		return $PokemonGlobal.day_care_Picnic.count
	end

	def self.egg_generated_Picnic?
		return $PokemonGlobal.day_care_Picnic.egg_generated
	end

	def self.reset_egg_counters_Picnic
		$PokemonGlobal.day_care_Picnic.reset_egg_counters
	end

	def self.get_details_Picnic(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Picnic
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Picnic(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Picnic
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Picnic(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Picnic.get_compatibility if compat_var > 0
	end

	def self.deposit_Picnic(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Picnic
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Picnic(index)
		day_care = $PokemonGlobal.day_care_Picnic
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Picnic(message, choice_var)
		day_care = $PokemonGlobal.day_care_Picnic
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Picnic
		day_care = $PokemonGlobal.day_care_Picnic
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# R10
	
	def self.count_R10
		return $PokemonGlobal.day_care_R10.count
	end

	def self.egg_generated_R10?
		return $PokemonGlobal.day_care_R10.egg_generated
	end

	def self.reset_egg_counters_R10
		$PokemonGlobal.day_care_R10.reset_egg_counters
	end

	def self.get_details_R10(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_R10
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_R10(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_R10
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_R10(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_R10.get_compatibility if compat_var > 0
	end

	def self.deposit_R10(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_R10
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_R10(index)
		day_care = $PokemonGlobal.day_care_R10
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_R10(message, choice_var)
		day_care = $PokemonGlobal.day_care_R10
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_R10
		day_care = $PokemonGlobal.day_care_R10
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# R11
	
	def self.count_R11
		return $PokemonGlobal.day_care_R11.count
	end

	def self.egg_generated_R11?
		return $PokemonGlobal.day_care_R11.egg_generated
	end

	def self.reset_egg_counters_R11
		$PokemonGlobal.day_care_R11.reset_egg_counters
	end

	def self.get_details_R11(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_R11
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_R11(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_R11
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_R11(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_R11.get_compatibility if compat_var > 0
	end

	def self.deposit_R11(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_R11
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_R11(index)
		day_care = $PokemonGlobal.day_care_R11
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_R11(message, choice_var)
		day_care = $PokemonGlobal.day_care_R11
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_R11
		day_care = $PokemonGlobal.day_care_R11
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# R12
	
	def self.count_R12
		return $PokemonGlobal.day_care_R12.count
	end

	def self.egg_generated_R12?
		return $PokemonGlobal.day_care_R12.egg_generated
	end

	def self.reset_egg_counters_R12
		$PokemonGlobal.day_care_R12.reset_egg_counters
	end

	def self.get_details_R12(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_R12
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_R12(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_R12
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_R12(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_R12.get_compatibility if compat_var > 0
	end

	def self.deposit_R12(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_R12
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_R12(index)
		day_care = $PokemonGlobal.day_care_R12
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_R12(message, choice_var)
		day_care = $PokemonGlobal.day_care_R12
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_R12
		day_care = $PokemonGlobal.day_care_R12
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# R13
	
	def self.count_R13
		return $PokemonGlobal.day_care_R13.count
	end

	def self.egg_generated_R13?
		return $PokemonGlobal.day_care_R13.egg_generated
	end

	def self.reset_egg_counters_R13
		$PokemonGlobal.day_care_R13.reset_egg_counters
	end

	def self.get_details_R13(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_R13
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_R13(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_R13
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_R13(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_R13.get_compatibility if compat_var > 0
	end

	def self.deposit_R13(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_R13
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_R13(index)
		day_care = $PokemonGlobal.day_care_R13
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_R13(message, choice_var)
		day_care = $PokemonGlobal.day_care_R13
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_R13
		day_care = $PokemonGlobal.day_care_R13
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# R14
	
	def self.count_R14
		return $PokemonGlobal.day_care_R14.count
	end

	def self.egg_generated_R14?
		return $PokemonGlobal.day_care_R14.egg_generated
	end

	def self.reset_egg_counters_R14
		$PokemonGlobal.day_care_R14.reset_egg_counters
	end

	def self.get_details_R14(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_R14
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_R14(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_R14
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_R14(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_R14.get_compatibility if compat_var > 0
	end

	def self.deposit_R14(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_R14
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_R14(index)
		day_care = $PokemonGlobal.day_care_R14
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_R14(message, choice_var)
		day_care = $PokemonGlobal.day_care_R14
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_R14
		day_care = $PokemonGlobal.day_care_R14
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# R15
	
	def self.count_R15
		return $PokemonGlobal.day_care_R15.count
	end

	def self.egg_generated_R15?
		return $PokemonGlobal.day_care_R15.egg_generated
	end

	def self.reset_egg_counters_R15
		$PokemonGlobal.day_care_R15.reset_egg_counters
	end

	def self.get_details_R15(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_R15
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_R15(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_R15
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_R15(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_R15.get_compatibility if compat_var > 0
	end

	def self.deposit_R15(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_R15
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_R15(index)
		day_care = $PokemonGlobal.day_care_R15
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_R15(message, choice_var)
		day_care = $PokemonGlobal.day_care_R15
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_R15
		day_care = $PokemonGlobal.day_care_R15
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Spare1
	
	def self.count_Spare1
		return $PokemonGlobal.day_care_Spare1.count
	end

	def self.egg_generated_Spare1?
		return $PokemonGlobal.day_care_Spare1.egg_generated
	end

	def self.reset_egg_counters_Spare1
		$PokemonGlobal.day_care_Spare1.reset_egg_counters
	end

	def self.get_details_Spare1(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Spare1
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Spare1(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Spare1
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Spare1(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Spare1.get_compatibility if compat_var > 0
	end

	def self.deposit_Spare1(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Spare1
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Spare1(index)
		day_care = $PokemonGlobal.day_care_Spare1
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Spare1(message, choice_var)
		day_care = $PokemonGlobal.day_care_Spare1
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Spare1
		day_care = $PokemonGlobal.day_care_Spare1
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Spare2
	
	def self.count_Spare2
		return $PokemonGlobal.day_care_Spare2.count
	end

	def self.egg_generated_Spare2?
		return $PokemonGlobal.day_care_Spare2.egg_generated
	end

	def self.reset_egg_counters_Spare2
		$PokemonGlobal.day_care_Spare2.reset_egg_counters
	end

	def self.get_details_Spare2(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Spare2
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Spare2(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Spare2
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Spare2(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Spare2.get_compatibility if compat_var > 0
	end

	def self.deposit_Spare2(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Spare2
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Spare2(index)
		day_care = $PokemonGlobal.day_care_Spare2
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Spare2(message, choice_var)
		day_care = $PokemonGlobal.day_care_Spare2
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Spare2
		day_care = $PokemonGlobal.day_care_Spare2
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Spare3
	
	def self.count_Spare3
		return $PokemonGlobal.day_care_Spare3.count
	end

	def self.egg_generated_Spare3?
		return $PokemonGlobal.day_care_Spare3.egg_generated
	end

	def self.reset_egg_counters_Spare3
		$PokemonGlobal.day_care_Spare3.reset_egg_counters
	end

	def self.get_details_Spare3(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Spare3
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Spare3(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Spare3
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Spare3(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Spare3.get_compatibility if compat_var > 0
	end

	def self.deposit_Spare3(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Spare3
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Spare3(index)
		day_care = $PokemonGlobal.day_care_Spare3
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Spare3(message, choice_var)
		day_care = $PokemonGlobal.day_care_Spare3
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Spare3
		day_care = $PokemonGlobal.day_care_Spare3
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Spare4
	
	def self.count_Spare4
		return $PokemonGlobal.day_care_Spare4.count
	end

	def self.egg_generated_Spare4?
		return $PokemonGlobal.day_care_Spare4.egg_generated
	end

	def self.reset_egg_counters_Spare4
		$PokemonGlobal.day_care_Spare4.reset_egg_counters
	end

	def self.get_details_Spare4(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Spare4
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Spare4(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Spare4
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Spare4(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Spare4.get_compatibility if compat_var > 0
	end

	def self.deposit_Spare4(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Spare4
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Spare4(index)
		day_care = $PokemonGlobal.day_care_Spare4
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Spare4(message, choice_var)
		day_care = $PokemonGlobal.day_care_Spare4
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Spare4
		day_care = $PokemonGlobal.day_care_Spare4
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end

	#-----------------------------------------------------------------------------
	# Spare5
	
	def self.count_Spare5
		return $PokemonGlobal.day_care_Spare5.count
	end

	def self.egg_generated_Spare5?
		return $PokemonGlobal.day_care_Spare5.egg_generated
	end

	def self.reset_egg_counters_Spare5
		$PokemonGlobal.day_care_Spare5.reset_egg_counters
	end

	def self.get_details_Spare5(index, name_var, cost_var)
		day_care = $PokemonGlobal.day_care_Spare5
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[cost_var] = day_care[index].cost if cost_var > 0
	end

	def self.get_level_gain_Spare5(index, name_var, level_var)
		day_care = $PokemonGlobal.day_care_Spare5
		index = day_care.slots.index { |slot| slot.filled? } || 0 if index < 0
		$game_variables[name_var] = day_care[index].pokemon_name if name_var > 0
		$game_variables[level_var] = day_care[index].level_gain if level_var > 0
	end

	def self.get_compatibility_Spare5(compat_var)
		$game_variables[compat_var] = $PokemonGlobal.day_care_Spare5.get_compatibility if compat_var > 0
	end

	def self.deposit_Spare5(party_index)
		$stats.day_care_deposits += 1
		day_care = $PokemonGlobal.day_care_Spare5
		pkmn = $player.party[party_index]
		raise _INTL("No Pokémon at index {1} in party.", party_index) if pkmn.nil?
		day_care.slots.each do |slot|
			next if slot.filled?
			slot.deposit(pkmn)
			$player.party.delete_at(party_index)
			day_care.reset_egg_counters
			deposited = true
			break
		end
		raise _INTL("No room to deposit a Pokémon.") if !deposited
	end

	def self.withdraw_Spare5(index)
		day_care = $PokemonGlobal.day_care_Spare5
		slot = day_care[index]
		if !slot.filled?
			raise _INTL("No Pokémon found in slot {1}.", index)
		elsif $player.party_full?
			raise _INTL("No room in party for Pokémon.")
		end
		$stats.day_care_levels_gained += slot.level_gain
		$player.party.push(slot.pokemon)
		slot.reset
		day_care.reset_egg_counters
	end

	def self.choose_Spare5(message, choice_var)
		day_care = $PokemonGlobal.day_care_Spare5
		case day_care.count
		when 0
			raise _INTL("No Pokémon found in Day Care to choose from.")
		when 1
			$game_variables[choice_var] = (day_care.slots.index { |slot| slot.filled? } || 0)
		else
			commands = []
			indices = []
			day_care.slots.each_with_index do |slot, i|
				choice_text = slot.choice_text
				next if !choice_text
				commands.push(choice_text)
				indices.push(i)
			end
			commands.push(_INTL("CANCEL"))
			command = pbMessage(message, commands, commands.length)
			$game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
		end
	end

	def self.collect_egg_Spare5
		day_care = $PokemonGlobal.day_care_Spare5
		egg = day_care.generate_egg
		raise _INTL("Couldn't generate the egg.") if egg.nil?
		raise _INTL("No room in party for egg.") if $player.party_full?
		$player.party.push(egg)
		day_care.reset_egg_counters
	end
end

#-----------------------------------------------------------------------------
# Updates the Hidden Move function to utilize the regional HM array defined in Settings.rb
#-----------------------------------------------------------------------------
def pbCheckHiddenMoveBadge(badge = -1, showmsg = true)
	return true if badge < 0	# No badge requirement
	return true if $DEBUG
	if (Settings::FIELD_MOVES_COUNT_BADGES) ? $player.badge_count >= badge : 
		$player.badges[Settings::REGION_HM_ARRAY[pbGetCurrentRegion][badge]]
		return true
	end
	pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
	return false
end







#===============================================================================
# With each step taken, add Exp to Pokémon in the Day Care and try to generate
# an egg.
#===============================================================================
EventHandlers.add(:on_player_step_taken, :update_day_care,
	proc {
		$PokemonGlobal.day_care.update_on_step_taken
		$PokemonGlobal.day_care_Kanto.update_on_step_taken
		$PokemonGlobal.day_care_Sevii.update_on_step_taken
		$PokemonGlobal.day_care_Johto.update_on_step_taken
		$PokemonGlobal.day_care_Hoenn.update_on_step_taken
		$PokemonGlobal.day_care_Sinnoh.update_on_step_taken
		$PokemonGlobal.day_care_Unova.update_on_step_taken
		$PokemonGlobal.day_care_Kalos.update_on_step_taken
		$PokemonGlobal.day_care_Alola.update_on_step_taken
		$PokemonGlobal.day_care_Galar1.update_on_step_taken
		$PokemonGlobal.day_care_Galar2.update_on_step_taken
		$PokemonGlobal.day_care_Orre.update_on_step_taken
		$PokemonGlobal.day_care_Picnic.update_on_step_taken
		$PokemonGlobal.day_care_R10.update_on_step_taken
		$PokemonGlobal.day_care_R11.update_on_step_taken
		$PokemonGlobal.day_care_R12.update_on_step_taken
		$PokemonGlobal.day_care_R13.update_on_step_taken
		$PokemonGlobal.day_care_R14.update_on_step_taken
		$PokemonGlobal.day_care_R15.update_on_step_taken
		$PokemonGlobal.day_care_Spare1.update_on_step_taken
		$PokemonGlobal.day_care_Spare2.update_on_step_taken
		$PokemonGlobal.day_care_Spare3.update_on_step_taken
		$PokemonGlobal.day_care_Spare4.update_on_step_taken
		$PokemonGlobal.day_care_Spare5.update_on_step_taken
	}
)