#===============================================================================
# Settings.
#===============================================================================
module Settings
	# The version of your game. It has to adhere to the MAJOR.MINOR.PATCH format.
	GAME_VERSION = "2.3.0"

	# The generation that the battle system follows. Used throughout the battle
	# scripts, and also by some other settings which are used in and out of battle
	# (you can of course change those settings to suit your game).
	# Note that this isn't perfect. Essentials doesn't accurately replicate every
	# single generation's mechanics. It's considered to be good enough. Only
	# generations 5 and later are reasonably supported.
	MECHANICS_GENERATION = 10
	
	#-----------------------------------------------------------------------------
	# Credits.
	#-----------------------------------------------------------------------------

	# Your game's credits, in an array. You can allow certain lines to be
	# translated by wrapping them in _INTL() as shown. Blank lines are just "".
	# To split a line into two columns, put "<s>" in it. Plugin credits and
	# Essentials engine credits are added to the end of these credits
	# automatically.
	def self.game_credits
		return [
			_INTL("This game by:"),
			"The Pokémon World Project Team",
			"Lead: SocomSeal",
			"Programming: Loopy",
			"Spriting: EnigmaThePhoenix",
			"Events: WarP123",
			"",
			_INTL("Animations from:"),
			"The Gen 9 Move Animation Project",
			"Thanks to the Reborn team for letting people use their resources. You are awesome.",
			"Gen 8 Animation Project lead by StCooler, with additional contributions by DarrylBD99, WolfPP, ardicoozer, riddlemeree",
			"Thanks to BellBlitzKing for his Pokemon Sound Effects Pack: Gen 1 to Gen 7 - All Attacks SFX.",
			"Gen 9 Animation Project led by KRLW890 and Nut0066, with additional contributions by Toxillian, QuahogTheCreator, Lcorp, and Shashu-Greninja",
			"",
			_INTL("Additional Animations from:"),
			"NikDie",
			"RetroNC",
			"",
			_INTL("Many resources from:"),
			"The Generation 9 Resource Pack",
			"https://www.pokecommunity.com/threads/generation-9-resource-pack-v21-1.527398/",
			"",
			_INTL("Many Maps adapted from work done by:"),
			"JohtoBlaziken",
			"nstav13",
			"Curt200718",
			"",
			_INTL("Emerald Essentials converted by:"),
			"Xysmaniac",
			"",
			_INTL("Spin tiles from work done by:"),
			"Vendily",
			"thepsynergist",
			"Barrel's O'Fun",
			"EagleOwl4Lyfe",
			"",
			_INTL("Other tiles by:"),
			"Ulithium_Dragon",
			"CRMM",
			"J-Treecko252",
			"Skybro14",
			"Zetavares852",
			"ZanClackRuso",
			"",
			_INTL("Badge sprites from work by:"),
			"SoaringSkies0",
			"JcFerggy",
			"",
			_INTL("Overworld Sprites by:"),
			"AveonTrainer",
			"Fersure4",
			"SphericalIce",
			"MrDollSteak",
			"5QU3L3T0N",
			"DontJoelMe",
			"",
			_INTL("Trainer Sprites by:"),
			"Kyle-Dove",
			"Jart4115",
			"",
			_INTL("Emerald Characters Set in FRLG Style by:"),
			"ChromusSama",
			"Poffin_Case",
			"",
			_INTL("Regicode by:"),
			"Spectator",
			"",
		]
	end
end