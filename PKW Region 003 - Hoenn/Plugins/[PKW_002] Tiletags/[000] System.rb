module GameData
	class TerrainTag
		alias tiletag_initialize initialize
		attr_reader :spin_tile
		attr_reader :spin_direction

		def initialize(hash)
			@spin_tile = hash[:spin_tile] || false
			@spin_direction = hash[:spin_direction] || -1
			tiletag_initialize(hash)
		end
	end
end

module SpinTileSettings
	SPIN_TILE_SPEED = 3.8
end

# Update with your own id numbers.
#-------------------------------#
# Filler Tags for V22
#-------------------------------#
GameData::TerrainTag.register({
	:id					=> :Filler2,
	:id_number			=> 22
})
GameData::TerrainTag.register({
	:id					=> :Filler3,
	:id_number			=> 23
})
GameData::TerrainTag.register({
	:id					=> :Filler4,
	:id_number			=> 24
})
GameData::TerrainTag.register({
	:id					=> :Filler5,
	:id_number			=> 25
})
GameData::TerrainTag.register({
	:id					=> :Filler6,
	:id_number			=> 26
})
GameData::TerrainTag.register({
	:id					=> :Filler7,
	:id_number			=> 27
})
GameData::TerrainTag.register({
	:id					=> :Filler8,
	:id_number			=> 28
})
GameData::TerrainTag.register({
	:id					=> :Filler9,
	:id_number			=> 29
})
#-------------------------------#
# Spin Tiles
#-------------------------------#
GameData::TerrainTag.register({
	:id					=> :SpinTileDown,
	:id_number			=> 30,
	:spin_tile			=> true,
	:force_direction	=> :down
})
GameData::TerrainTag.register({
	:id					=> :SpinTileRight,
	:id_number			=> 31,
	:spin_tile			=> true,
	:force_direction	=> :right
})
GameData::TerrainTag.register({
	:id					=> :SpinTileUp,
	:id_number			=> 32,
	:spin_tile			=> true,
	:force_direction	=> :up
})
GameData::TerrainTag.register({
	:id					=> :SpinTileLeft,
	:id_number			=> 33,
	:spin_tile			=> true,
	:force_direction	=> :left
})
GameData::TerrainTag.register({
	:id					=> :SpinTileStop,
	:id_number			=> 34,
})
#-------------------------------#
# Terrain Tag Side Stairs
#-------------------------------#
GameData::TerrainTag.register({
	:id					=> :StairRight,
	:id_number			=> 35,
})
GameData::TerrainTag.register({
	:id					=> :StairLeft,
	:id_number			=> 36,
})