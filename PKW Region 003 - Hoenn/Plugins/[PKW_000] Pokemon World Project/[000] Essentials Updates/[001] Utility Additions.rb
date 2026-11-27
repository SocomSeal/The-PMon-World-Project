class Game_Character
	#-----------------------------------------------------------------------------
	# Extends the turn_random function to only turn specific directions
	#-----------------------------------------------------------------------------
	
	def turn_random_URL
		case rand(3)
		when 0 then turn_up
		when 1 then turn_right
		when 2 then turn_left
		end
	end

	def turn_random_URD
		case rand(3)
		when 0 then turn_up
		when 1 then turn_right
		when 2 then turn_down
		end
	end

	def turn_random_ULD
		case rand(3)
		when 0 then turn_up
		when 1 then turn_left
		when 2 then turn_down
		end
	end
	
	def turn_random_RLD
		case rand(3)
		when 0 then turn_right
		when 1 then turn_left
		when 2 then turn_down
		end
	end

	def turn_random_UR
		case rand(3)
		when 0 then turn_up
		when 1 then turn_right
		end
	end

	def turn_random_UL
		case rand(3)
		when 0 then turn_up
		when 1 then turn_left
		end
	end

	def turn_random_UD
		case rand(3)
		when 0 then turn_up
		when 1 then turn_down
		end
	end

	def turn_random_RL
		case rand(3)
		when 0 then turn_right
		when 1 then turn_left
		end
	end

	def turn_random_RD
		case rand(3)
		when 0 then turn_right
		when 1 then turn_down
		end
	end

	def turn_random_LD
		case rand(3)
		when 0 then turn_left
		when 1 then turn_down
		end
	end
end

#===============================================================================
#
#===============================================================================
class Phone
	#-----------------------------------------------------------------------------
	# Adds doublebattle support to Phone rematches with proper trainer versioning
	#-----------------------------------------------------------------------------
	def self.doublebattle(trainer_type, name, version_modifier = 0, start_version = 0)
		contact = $PokemonGlobal.phone.get(true, trainer_type, name, start_version)
		return false if !contact
		return TrainerBattle.start(trainer_type, name, (contact.next_version * 2) + version_modifier)
	end
end

#===============================================================================
# ** Interpreter
#-------------------------------------------------------------------------------
#	This interpreter runs event commands. This class is used within the
#	Game_System class and the Game_Event class.
#===============================================================================
class Interpreter
	#-----------------------------------------------------------------------------
	# Adds a function to set event time on any map
	#-----------------------------------------------------------------------------
	def pbSetEventTimeGlobal(mapid, eventid)
		$PokemonGlobal.eventvars = {} if !$PokemonGlobal.eventvars
		time = pbGetTimeNow
		time = time.to_i
		pbSetSelfSwitch(eventid, "A", true, mapid)
		$PokemonGlobal.eventvars[[mapid, eventid]] = time
	end
end

#-----------------------------------------------------------------------------
# Adds a function to trade pokemon with yourself for trade evolutions
#-----------------------------------------------------------------------------
def pbStartTradeYourself(pkmn1,pkmn2)
	$stats.trade_count += 1
	pbFadeOutInWithMusic do
		evo = PokemonTrade_Scene.new
		evo.pbStartScreen(pkmn2, pkmn1, $player.name, $player.name)
		evo.pbTrade
		evo.pbEndScreen
	end
end