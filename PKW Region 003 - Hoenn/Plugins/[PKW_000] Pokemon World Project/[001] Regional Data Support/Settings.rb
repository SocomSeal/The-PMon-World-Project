#===============================================================================
# Settings.
#===============================================================================
module Settings
	#-----------------------------------------------------------------------------
	# The player and NPCs.
	#-----------------------------------------------------------------------------

	# A set of arrays each containing a trainer type followed by a Game Variable
	# number. If the Variable isn't set to 0, then all trainers with the
	# associated trainer type will be named as whatever is in that Variable.
	RIVAL_NAMES = [
		[:FRLG_RIVAL1,	 48],
		[:FRLG_RIVAL2,	 48],
		[:FRLG_CHAMPION, 48],
		[:HGSS_POKEMONTRAINER_SILVER, 55]
	]
	
	#-----------------------------------------------------------------------------
	# Using moves in the overworld.
	#-----------------------------------------------------------------------------
	# Whether you need at least a certain number of Gym Badges to use some hidden
	# moves in the field (true), or whether you need one specific Gym Badge to use
	# them (false). The amounts/specific Gym Badges are defined below.
	FIELD_MOVES_COUNT_BADGES = false
	# Depending on FIELD_MOVES_COUNT_BADGES, either the number of Gym Badges
	# required to use each hidden move in the field, or the specific Gym Badge
	# required to use each move. Remember that Gym Badge 0 is the first Gym Badge,
	# Gym Badge 1 is the second Gym Badge, etc.
	#	 e.g. To specifically require the second Gym Badge, put false and 1.
	#				To require at least 2 Gym Badges, put true and 2.
		
	# HM List starting from HM01 is 
	# Cut, Fly, Surf, Strength, Flash, 
	# Rock Smash, Waterfall, Dive, Whirlpool, Defog, Rockclimb
	
	# Define array for region HMs
	# Region 0 is undefined for numbering clarity
	REGION_HM_ARRAY = [[],
						[12,13,15,14,11,16,17,-1,-1,-1,-1],
						[22,25,24,23,21,21,28,-1,27,-1,29],
						[31,36,35,34,32,33,38,37,-1,-1,-1],
						[42,44,45,46,-1,41,48,-1,-1,43,47],
						[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
						[61,64,63,62,-1,-1,68,-1,-1,-1,-1],
						[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
						[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
						[-1,-1,92,-1,-1,-1,-1,-1,-1,-1,95]
	]

	BADGE_FOR_CUT			= 0
	BADGE_FOR_FLY			= 1
	BADGE_FOR_SURF			= 2
	BADGE_FOR_STRENGTH		= 3
	BADGE_FOR_FLASH		 	= 4
	BADGE_FOR_ROCKSMASH 	= 5
	BADGE_FOR_WATERFALL 	= 6
	BADGE_FOR_DIVE			= 7
	BADGE_FOR_WHIRLPOOL 	= 8
	BADGE_FOR_DEFOG			= 9
	BADGE_FOR_ROCKCLIMB 	= 10

	#-----------------------------------------------------------------------------
	# Roaming Pokémon.
	#-----------------------------------------------------------------------------

	# A list of maps used by roaming Pokémon. Each map has an array of other maps
	# it can lead to.
	ROAMING_AREAS = {}
	
	# A set of hashes, each containing the details of a roaming Pokémon. The
	# information within each hash is as follows:
	#	 * :species
	#	 * :level
	#	 * :icon - Filename in Graphics/UI/Town Map/ of the roamer's Town Map icon.
	#	 * :game_switch - The Pokémon roams if this is nil or <=0 or if that Game
	#										Switch is ON. Optional.
	#	 * :encounter_type - One of:
	#			 :all		 = grass, walking in cave, surfing (default)
	#			 :land		= grass, walking in cave
	#			 :water	 = surfing, fishing
	#			 :surfing = surfing
	#			 :fishing = fishing
	#	 * :bgm - The BGM to play for the encounter. Optional.
	#	 * :areas - A hash of map IDs that determine where this Pokémon roams. Used
	#							instead of ROAMING_AREAS above. Optional.
	ROAMING_SPECIES = []
	
	#-----------------------------------------------------------------------------
	# Party and Pokémon storage.
	#-----------------------------------------------------------------------------

	# The number of boxes in Pokémon storage.
	NUM_STORAGE_BOXES = 80
	
	#-----------------------------------------------------------------------------
	# Pokédex.
	#-----------------------------------------------------------------------------

	# The names of the Regional Pokédex lists, in the order they are defined in
	# the PBS file "regional_dexes.txt". The National Dex is (and must be) added
	# to the end of this array of names.
	# Each entry is either just a name, or is an array containing a name and a
	# number. If there is a number, it is a region number as defined in
	# town_map.txt. If there is no number, the number of the region the player is
	# currently in will be used. The region number determines which Town Map is
	# shown in the Area page when viewing that Pokédex list.
	def self.pokedex_names
		return [
			[_INTL("Null Pokédex"), 0],
			[_INTL("Kanto Pokédex"), 1],
			[_INTL("Johto Pokédex"), 2],
			[_INTL("Hoenn Pokédex"), 3],
			[_INTL("Sinnoh Pokédex"), 4],
			[_INTL("Unova Pokédex"), 5],
			[_INTL("Kalos Pokédex"), 6],
			[_INTL("Alola Pokédex"), 7],
			[_INTL("Galar Pokédex"), 8],
			[_INTL("Paldea Pokédex"), 9],
			_INTL("National Pokédex")
		]
	end
	
	# An array of numbers, where each number is that of a Dex list (in the same
	# order as above, except the National Dex is -1). All Dex lists included here
	# will begin their numbering at 0 rather than 1 (e.g. Victini in Unova's Dex).
	DEXES_WITH_OFFSETS = [-1, 5]
	
	#-----------------------------------------------------------------------------
	# Files.
	#-----------------------------------------------------------------------------

	DEFAULT_WILD_BATTLE_BGM		 	= "Battle wild"
	DEFAULT_WILD_VICTORY_BGM		= "Battle victory"
	DEFAULT_WILD_CAPTURE_ME		 	= "Battle capture success"
	DEFAULT_TRAINER_BATTLE_BGM		= "Battle trainer"
	DEFAULT_TRAINER_VICTORY_BGM 	= "Battle victory"

	# Placeholder for the eventual audio hashes
	

	# Region music arrays go here
	# Region 0 is used for System fallback, to create numbering clarity
	REGION_MUSIC_HM_SURF_ARRAY = 
		["Surfing",
		"FRLG Misc - Surfing (The Sea)",
		"",
		"ORAS Misc - Surfing (Surf)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_CYCLING_ARRAY = 
		["Bicycle",
		"FRLG Misc - Cycling (Cycling)",
		"",
		"ORAS Misc - Cycling (Cycling)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
		
	REGION_SOUND_LEVEL_UP_ARRAY = 
		["Pkmn Level Up",
		"",
		"",
		"ORAS Fanfare - Level Up (Level Up!)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]

	REGION_MUSIC_EVOLUTION_START_ARRAY = 
		["Evolution start",
		"",
		"",
		"RSE Fanfare - Evolution Start (Evolution Jingle)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_EVOLUTION_ARRAY = 
		["Evolution",
		"FRLG Misc - Evolution (Evolution)",
		"",
		"ORAS Misc - Evolution (Evolution)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_EVOLUTION_SUCCESS_ARRAY = 
		["Evolution success",
		"FRLG Fanfare - Evolution Success (Fanfare! Evolution)",
		"",
		"ORAS Fanfare - Evolution Success (Congratulations! Your Pokemon Evolved!)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	
	REGION_MUSIC_ITEM_ARRAY = 
		["Item get",
		"FRLG Fanfare - Item (Fanfare Item Get 1)",
		"",
		"ORAS Fanfare - Item (Obtained an Item!)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_ITEM_KEY_ARRAY = 
		["Key item get",
		"FRLG Fanfare - Item Key (Fanfare! Key Item)",
		"",
		"ORAS Fanfare - Item Key (Obtained a Key Item!)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_ITEM_MACHINE_ARRAY = 
		["Machine get",
		"FRLG Fanfare - Item Machine (Fanfare! Item Obtained (Version 2))",
		"",
		"ORAS Fanfare - Item Machine (Obtained a TM!)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_ITEM_BERRY_ARRAY = 
		["Berry get",
		"",
		"",
		"ORAS Fanfare - Berry (Obtained a Berry!)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
		
	REGION_MUSIC_POKEMON_EGG_OBTAINED_ARRAY = 
		["Pkmn get",
		"",
		"",
		"ORAS Fanfare - Egg (Obtained an Egg!)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_POKEMON_OBTAINED_ARRAY = 
		["Pkmn get",
		"FRLG Fanfare - Pokemon Obtained (Fanfare! Pokemon Obtained)",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_POKEMON_CAPTURED_ARRAY = 
		["Battle capture success",
		"FRLG Fanfare - Pokemon Captured (Fanfare! Pokemon Caught)",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]

	REGION_MUSIC_BATTLE_TRAINER_INTRO_ARRAY = 
		["",
		"",
		"",
		"ORAS Battle Intro - Trainer Suspicious (Trainers_ Eyes Meet (Hex Maniac))",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_BATTLE_TRAINER_INTRO_F_ARRAY = 
		["",
		"FRLG Battle Intro - Trainer Female (A Trainer Appears (Girl Version))",
		"",
		"ORAS Battle Intro - Trainer Female (Trainers_ Eyes Meet (Lass))",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_BATTLE_TRAINER_INTRO_M_ARRAY = 
		["",
		"FRLG Battle Intro - Trainer Male (A Trainer Appears (Boy Version))",
		"",
		"ORAS Battle Intro - Trainer Male (Trainers_ Eyes Meet (Youngster))",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]

	REGION_MUSIC_BATTLE_WILD_ARRAY = 
		["Battle wild",
		"FRLG Battle Music - Wild Pokemon (Battle (VS Wild Pokemon))",
		"",
		"ORAS Battle Music - Wild Pokemon (Battle! (Wild Pokemon))",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_BATTLE_TRAINER_ARRAY = 
		["Battle trainer",
		"FRLG Battle Music - Trainer (Battle (VS Trainer))",
		"",
		"ORAS Battle Music - Trainer (Battle! (Trainer Battle))",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	
	REGION_MUSIC_BATTLE_WILD_VICTORY_ARRAY = 
		["Battle victory wild",
		"FRLG Battle Victory - Wild Pokemon (Victory (VS Wild Pokemon))",
		"",
		"ORAS Battle Victory - Wild Pokemon (Victory! (Wild Pokemon))",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	REGION_MUSIC_BATTLE_TRAINER_VICTORY_ARRAY = 
		["Battle victory trainer",
		"FRLG Battle Victory - Trainer (Victory (VS Trainer))",
		"",
		"ORAS Battle Victory - Trainer (Victory! (Trainer Battle))",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]

	REGION_MUSIC_HALL_OF_FAME_ARRAY = 
		["Hall of Fame",
		"FRLG Misc - Hall of Fame (Induction Into the Hall of Fame)",
		"",
		"ORAS Misc - Hall of Fame (The Hall of Fame)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
		
	REGION_GRAPHICS_CREDITS_ARRAY = 
		[[],
		["credits1", "credits2", "credits3", "credits4", "credits5"],
		["credits1", "credits2", "credits3", "credits4", "credits5"],
		["credits1", "credits2", "credits3", "credits4", "credits5"],
		["credits1", "credits2", "credits3", "credits4", "credits5"],
		["credits1", "credits2", "credits3", "credits4", "credits5"],
		["credits1", "credits2", "credits3", "credits4", "credits5"],
		["credits1", "credits2", "credits3", "credits4", "credits5"],
		["credits1", "credits2", "credits3", "credits4", "credits5"],
		["credits1", "credits2", "credits3", "credits4", "credits5"],
		["credits1", "credits2", "credits3", "credits4", "credits5"]
		]
	REGION_MUSIC_CREDITS_ARRAY = 
		["Credits",
		"FRLG Misc - Credits (Ending)",
		"",
		"ORAS Misc - Credits (Ending Theme)",
		"",
		"",
		"",
		"",
		"",
		"",
		""
		]
	
end