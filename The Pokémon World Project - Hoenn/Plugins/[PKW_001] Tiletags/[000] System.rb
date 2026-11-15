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