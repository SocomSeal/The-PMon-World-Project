GameData::Weather.register({
  :id               => :Filler1,
  :category         => :None,
  :id_number        => 9,
  :graphics         => [nil]
})

GameData::Weather.register({
  :id               => :Filler2,
  :category         => :None,
  :id_number        => 10,
  :graphics         => [nil]
})

GameData::Weather.register({
  :id               => :RSE_Rain,
  :id_number        => 11,
  :category         => :Rain,
  :graphics         => [["RSE_RAIN_1", "RSE_RAIN_2", "RSE_RAIN_3", "RSE_RAIN_4", "RSE_RAIN_5", "RSE_RAIN_6"]],   # Last is splash
  :particle_delta_x => -600,
  :particle_delta_y => 2400,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength / 2, -strength / 2, -strength / 2, 10)
  }
})

# NOTE: This randomly flashes the screen in RPG::Weather#update.
GameData::Weather.register({
  :id               => :RSE_Storm,
  :id_number        => 12,
  :category         => :Rain,
  :graphics         => [["RSE_RAIN_1", "RSE_RAIN_2", "RSE_RAIN_3", "RSE_RAIN_4", "RSE_RAIN_5", "RSE_RAIN_6"]],   # Last is splash
  :particle_delta_x => -3600,
  :particle_delta_y => 3600,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength / 2, -strength / 2, -strength / 2, 10)
  }
})

GameData::Weather.register({
  :id               => :RSE_Sandstorm,
  :id_number        => 13,
  :category         => :Sandstorm,
  :graphics         => [nil, ["RSE_SANDSTORM_TILE"]],
  :particle_delta_x => -1200,
  :particle_delta_y => 640,
  :tile_delta_x     => -800,
  :tile_delta_y     => 400,
  :tone_proc        => proc { |strength|
    next Tone.new(strength / 2, 0, -strength / 2, 0)
  }
})

GameData::Weather.register({
  :id               => :RSE_Ash,
  :id_number        => 14,
  :category         => :None,
  :tile_delta_x => 0,
  :tile_delta_y => 32,
  :graphics         => [nil, ["RSE_ASH_TILE"]]
})

# NOTE: This alters the movement of snow particles in RPG::Weather#update_sprite_position.
GameData::Weather.register({
  :id               => :RSE_Snow,
  :id_number        => 15,
  :category         => :Hail,
  :graphics         => [["RSE_SNOW_1", "RSE_SNOW_2"]],
  :particle_delta_x => -240,
  :particle_delta_y => 240,
  :tone_proc        => proc { |strength|
    next Tone.new(strength / 2, strength / 2, strength / 2, 0)
  }
})