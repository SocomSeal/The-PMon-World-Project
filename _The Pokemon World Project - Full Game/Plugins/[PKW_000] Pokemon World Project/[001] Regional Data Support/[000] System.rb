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
# Regional and National Pokédexes utilities.
#===============================================================================
#-----------------------------------------------------------------------------
# Rewrites pbGetCurrentRegion to return Regions above 99 (Sub-Regions in this resource)
# as their Parent Region (0-99) instead.
#-----------------------------------------------------------------------------
# Returns the ID number of the region containing the player's current location,
# as determined by the current map's metadata.
def pbGetCurrentRegion(default = -1)
	return default if !$game_map
	map_pos = $game_map.metadata&.town_map_position	
	return default if !map_pos || !map_pos[0]
	
	region = map_pos[0].to_i	
	region /= 100 if region > 99
	
	return region
end

#===============================================================================
#
#===============================================================================
class UI::TrainerCardVisuals < UI::BaseVisuals
#-----------------------------------------------------------------------------
# Rewrites draw_badges to utilize this resource's base-10 regional badge numbering system
#-----------------------------------------------------------------------------
	def draw_badges
		x = FIRST_BADGE_X
		region = pbGetCurrentRegion(0)	# Get the current region
		BADGE_COUNT.times do |i|
			if $player.badges[i + (region * 10)]
				draw_image(graphics_folder + "icon_badges", x, FIRST_BADGE_Y,
									 i * BADGE_SIZE[0], region * BADGE_SIZE[1], *BADGE_SIZE)
			end
			x += BADGE_SIZE[0] + BADGE_SPACING
		end
	end
end

#===============================================================================
# Stored in $stats
#===============================================================================
class GameStats
	attr_accessor :times_to_enter_hall_of_fame	 # An array of times in seconds
	
	alias regional_initialize initialize
		@times_to_enter_hall_of_fame	 = []	 # Set with set_times_to_hall_of_fame(number) in Hall of Fame event
		regional_initialize
	end
	
	def set_times_to_hall_of_fame(number)
		@times_to_enter_hall_of_fame[number] = play_time if !@times_to_enter_hall_of_fame[number]
	end
end

#===============================================================================
# * Hall of Fame - by FL (Credits will be apreciated)
#-------------------------------------------------------------------------------
# This script is for Pokémon Essentials. It makes a recordable Hall of Fame
# like the Gen 3 games.
#-------------------------------------------------------------------------------
# To this scripts works, put it above main, put a 512x384 picture in
# hallfamebars and a 8x24 background picture in hallfamebg. To call this script,
# use 'pbHallOfFameEntry'. After you recorder the first entry, you can access
# the hall teams using a PC. You can also check the player Hall of Fame last
# number using '$PokemonGlobal.hallOfFameLastNumber'.
#===============================================================================
class HallOfFame_Scene
	def writeTrainerData
		if $PokemonGlobal.hallOfFameLastNumber == 1
			totalsec = $stats.times_to_enter_hall_of_fame[pbGetCurrentRegion].to_i
		else
			totalsec = $stats.play_time.to_i
		end
		hour = totalsec / 60 / 60
		min = totalsec / 60 % 60
		pubid = sprintf("%05d", $player.public_ID)
		lefttext = _INTL("Name<r>{1}", $player.name) + "<br>"
		lefttext += _INTL("ID No.<r>{1}", pubid) + "<br>"
		if hour > 0
			lefttext += _INTL("Time<r>{1}h {2}m", hour, min) + "<br>"
		else
			lefttext += _INTL("Time<r>{1}m", min) + "<br>"
		end
		lefttext += _INTL("Pokédex<r>{1}/{2}",
											$player.pokedex.owned_count, $player.pokedex.seen_count) + "<br>"
		@sprites["messagebox"] = Window_AdvancedTextPokemon.new(lefttext)
		@sprites["messagebox"].viewport = @viewport
		@sprites["messagebox"].width = 192 if @sprites["messagebox"].width < 192
		@sprites["msgwindow"] = pbCreateMessageWindow(@viewport)
		pbMessageDisplay(@sprites["msgwindow"],
										 _INTL("League champion!\nCongratulations!") + "\\^")
	end
end