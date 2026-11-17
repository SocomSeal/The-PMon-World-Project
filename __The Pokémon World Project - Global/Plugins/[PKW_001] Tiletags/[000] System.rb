module GameData
  class TerrainTag
    alias tiletag_initialize initialize
    attr_reader :spin_tile
    attr_reader :spin_direction
    attr_reader :water_current
	
    attr_reader :stairs
    attr_reader :diagonal_stairs

    def initialize(hash)
      @spin_tile = hash[:spin_tile] || false
      @spin_direction = hash[:spin_direction] || -1
      @water_current = hash[:water_current] || false
	  
	  
        @stairs          = hash[:stairs] || false
        @diagonal_stairs = hash[:diagonal_stairs]
	  
      tiletag_initialize(hash)
    end
  end
end