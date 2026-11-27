#===============================================================================
# Method relating to map infos data.
#===============================================================================
def pbLoadMapInfos
	$game_temp = Game_Temp.new if !$game_temp
	if !$game_temp.map_infos
		# Multi Disc Data Load Update
		disc = $game_system ? $game_system.disc : ""
		$game_temp.map_infos = load_data("Data/#{disc}MapInfos.rxdata")
	end
	return $game_temp.map_infos
end

#===============================================================================
# Map Factory Helper (stores map connection and size data and calculations
# involving them)
#===============================================================================
module MapFactoryHelper
	def self.getMapConnections
		if !@@MapConnections
			@@MapConnections = []
			# Multi Disc Data Load Update
			disc = $game_system ? $game_system.disc : ""
			conns = load_data("Data/#{disc}map_connections.dat")
			conns.each do |conn|
				# Ensure both maps in a connection are valid
				dimensions = getMapDims(conn[0])
				next if dimensions[0] == 0 || dimensions[1] == 0
				dimensions = getMapDims(conn[3])
				next if dimensions[0] == 0 || dimensions[1] == 0
				# Convert first map's edge and coordinate to pair of coordinates
				edge = getMapEdge(conn[0], conn[1])
				case conn[1]
				when "N", "S"
					conn[1] = conn[2]
					conn[2] = edge
				when "E", "W"
					conn[1] = edge
				end
				# Convert second map's edge and coordinate to pair of coordinates
				edge = getMapEdge(conn[3], conn[4])
				case conn[4]
				when "N", "S"
					conn[4] = conn[5]
					conn[5] = edge
				when "E", "W"
					conn[4] = edge
				end
				# Add connection to arrays for both maps
				@@MapConnections[conn[0]] = [] if !@@MapConnections[conn[0]]
				@@MapConnections[conn[0]].push(conn)
				@@MapConnections[conn[3]] = [] if !@@MapConnections[conn[3]]
				@@MapConnections[conn[3]].push(conn)
			end
		end
		return @@MapConnections
	end
end
		
#===============================================================================
#
#===============================================================================
module GameData
	#===============================================================================
	# A mixin module for data classes which provides common class methods (called
	# by GameData::Thing.method) that provide access to data held within.
	# Assumes the data class's data is stored in a class constant hash called DATA.
	# For data that is stored in a project's 'disc' data folders.
	#===============================================================================
	module DiscLoader
		def load
			# Multi Disc Data Load Update
			disc = $game_system ? $game_system.disc : ""
			const_set(:DATA, load_data("Data/#{disc}#{self::DATA_FILENAME}"))
		end
		
		def save
			# Multi Disc Data Load Update
			disc = $game_system ? $game_system.disc : ""
			save_data(self::DATA, "Data/#{disc}#{self::DATA_FILENAME}")
		end
	end
		
	#===============================================================================
	# Extend DiscLoader into relevant classes
	#===============================================================================
	class Encounter
		extend DiscLoader
	end

	class MapMetadata
		extend DiscLoader
	end
end

#===============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#	This class handles the map. It includes scrolling and passable determining
#	functions. Refer to "$game_map" for the instance of this class.
#===============================================================================
class Game_Map
	def self.map_data_exists?(map_id)
		# Multi Disc Data Load Update
		disc = $game_system ? $game_system.disc : ""
		return pbRgssExists?(sprintf("Data/#{disc}Map%03d.rxdata", map_id))
	end

	def self.load_map_data(map_id)
		# Multi Disc Data Load Update
		disc = $game_system ? $game_system.disc : ""
		return load_data(sprintf("Data/#{disc}Map%03d.rxdata", map_id)) rescue nil
	end
end

#===============================================================================
# Contains the save values defined in Essentials by default.
#===============================================================================
SaveData.register(:game_system) do
	load_in_bootup
	ensure_class :Game_System
	save_value { $game_system }
	load_value { |value| $game_system = value }
	new_game_value { Game_System.new }
end

module Game
	module_function
	# Loads the game from the given save data and starts the map scene.
	# @param save_data [Hash] hash containing the save data
	# @raise [SaveData::InvalidValueError] if an invalid value is being loaded
	def load(save_data)
		validate save_data => Hash
		SaveData.load_all_values(save_data)
		$game_temp.last_uptime_refreshed_play_time = System.uptime
		$stats.play_sessions += 1
		load_map
		pbAutoplayOnSave
		$game_map.update
		$PokemonMap.updateMap
		$scene = Scene_Map.new
		GameData.load_all
	end
end