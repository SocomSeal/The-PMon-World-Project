module GameData
  class TerrainTag
    alias tiletag_initialize initialize
    attr_reader :spin_tile
    attr_reader :spin_direction
    attr_reader :water_current

    def initialize(hash)
      @spin_tile = hash[:spin_tile] || false
      @spin_direction = hash[:spin_direction] || -1
      @water_current = hash[:water_current] || false
      tiletag_initialize(hash)
    end
  end
end

module SpinTileSettings
  SPIN_TILE_SPEED = 3.8
end

# Update with your own id numbers.
#-------------------------------#
# Spin Tiles
#-------------------------------#
GameData::TerrainTag.register({
  :id                     => :SpinTileDown,
  :id_number              => 20,
  :spin_tile              => true,
  :spin_direction         => 0
})
GameData::TerrainTag.register({
  :id                     => :SpinTileRight,
  :id_number              => 21,
  :spin_tile              => true,
  :spin_direction         => 1
})
GameData::TerrainTag.register({
  :id                     => :SpinTileUp,
  :id_number              => 22,
  :spin_tile              => true,
  :spin_direction         => 2
})
GameData::TerrainTag.register({
  :id                     => :SpinTileLeft,
  :id_number              => 23,
  :spin_tile              => true,
  :spin_direction         => 3
})
GameData::TerrainTag.register({
  :id                     => :SpinTileStop,
  :id_number              => 24,
  :spin_tile              => false,
})
#-------------------------------#
# Water Currents
#-------------------------------#
GameData::TerrainTag.register({
  :id                     => :CurrentUp,
  :id_number              => 25,
  :can_surf		          => true,
  :water_current          => true
})
GameData::TerrainTag.register({
  :id                     => :CurrentRight,
  :id_number              => 26,
  :can_surf		          => true,
  :water_current          => true
})
GameData::TerrainTag.register({
  :id                     => :CurrentLeft,
  :id_number              => 27,
  :can_surf		          => true,
  :water_current          => true
})
GameData::TerrainTag.register({
  :id                     => :CurrentDown,
  :id_number              => 28,
  :can_surf		          => true,
  :water_current          => true
})
#-------------------------------#
# Terrain Tag Side Stairs
#-------------------------------#
GameData::TerrainTag.register({
  :id => :StairRight,
  :id_number => 29,
})
GameData::TerrainTag.register({
  :id => :StairLeft,
  :id_number => 30,
})