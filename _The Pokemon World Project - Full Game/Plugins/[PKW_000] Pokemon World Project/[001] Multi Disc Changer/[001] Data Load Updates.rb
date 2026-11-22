#===============================================================================
# Method relating to map infos data.
#===============================================================================
def pbLoadMapInfos
	$game_temp = Game_Temp.new if !$game_temp
	if !$game_temp.map_infos
		if !$game_system
			$game_temp.map_infos = load_data(sprintf("Data/MapInfos.rxdata"))
		else
			# Multi Disc Data Load Update
			$game_temp.map_infos = load_data(sprintf("Data/%sMapInfos.rxdata", $game_system.disc))
		end
	end
	return $game_temp.map_infos
end

#===============================================================================
# Map Factory Helper (stores map connection and size data and calculations
# involving them)
#===============================================================================
module MapFactoryHelper
	def getMapConnections
		if !@@MapConnections
			@@MapConnections = []
			# Multi Disc Data Load Update
			if !game_system
				conns = load_data("Data/map_connections.dat")
			else
				conns = load_data(sprintf("Data/%smap_connections.dat", $game_system.disc))				
			end
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
	#=============================================================================
	# A mixin module for data classes which provides common class methods (called
	# by GameData::Thing.method) that provide access to data held within.
	# Assumes the data class's data is stored in a class constant hash called DATA.
	# For data that is known by a symbol or an ID number.
	#=============================================================================
	module ClassMethods
		def load
			# Multi Disc Data Load Update
			if !$game_system
				const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
			else
				const_set(:DATA, load_data(sprintf("Data/%s#{self::DATA_FILENAME}", $game_system.disc)))
			end
		end
		
		def save
			# Multi Disc Data Load Update
			if !$game_system
				save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
			else
				save_data(sprintf(self::DATA, "Data/%s#{self::DATA_FILENAME}", $game_system.disc))
			end
		end
	end

	#=============================================================================
	# A mixin module for data classes which provides common class methods (called
	# by GameData::Thing.method) that provide access to data held within.
	# Assumes the data class's data is stored in a class constant hash called DATA.
	# For data that is only known by a symbol.
	#=============================================================================
	module ClassMethodsSymbols
		def load
			# Multi Disc Data Load Update
			if !$game_system
				const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
			else
				const_set(:DATA, load_data(sprintf("Data/%s#{self::DATA_FILENAME}", $game_system.disc)))
			end
		end
		
		def save
			# Multi Disc Data Load Update
			if !$game_system
				save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
			else
				save_data(sprintf(self::DATA, "Data/%s#{self::DATA_FILENAME}", $game_system.disc))
			end
		end
	end

	#=============================================================================
	# A mixin module for data classes which provides common class methods (called
	# by GameData::Thing.method) that provide access to data held within.
	# Assumes the data class's data is stored in a class constant hash called DATA.
	# For data that is only known by an ID number.
	#=============================================================================
	module ClassMethodsIDNumbers
		def load
			# Multi Disc Data Load Update
			if !$game_system
				const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
			else
				const_set(:DATA, load_data(sprintf("Data/%s#{self::DATA_FILENAME}", $game_system.disc)))
			end
		end
		
		def save
			# Multi Disc Data Load Update
			if !$game_system
				save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
			else
				save_data(sprintf(self::DATA, "Data/%s#{self::DATA_FILENAME}", $game_system.disc))
			end
		end
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
		if !$game_system
			return pbRgssExists?(sprintf("Data/Map%03d.rxdata", map_id))
		else
			return pbRgssExists?(sprintf("Data/%sMap%03d.rxdata", $game_system.disc, map_id))
		end
	end

	def self.load_map_data(map_id)
		# Multi Disc Data Load Update
		if !$game_system
			return load_data(sprintf("Data/Map%03d.rxdata", map_id)) rescue nil
		else
			return load_data(sprintf("Data/%sMap%03d.rxdata", $game_system.disc, map_id)) rescue nil
		end		
	end
end