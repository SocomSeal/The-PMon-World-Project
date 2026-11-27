#==============================================================================
# ** Disc Changer script (Designed for Legend of Harpine)
#------------------------------------------------------------------------------
# Zeriab
# 1.05
# 2008-09-20
#------------------------------------------------------------------------------
# Allows you to change the disc, where each disc can contain 999 maps
#==============================================================================
=begin
INSTRUCTIONS
------------
This script enables the change_disc command. Use script calls to change the disc.
For disc 1 create a subfolder in your data folder called 'disc1' and place the
map files for disc 1 in there.
For disc 2 you should create a subfolder called 'disc2' and place the map files
for disc 2 in there. And so on for each of your discs.
The syntax is:

	change_disc(number, id = nil, x = nil, y = nil, direction = nil)

The nil numbers mean that those arguments are optional. When you don't use them
then they are set to whatever the current map_id, x, y and direction are at the
moment.

If you want to change to disc 2 then you can put this in a script call:

	change_disc(2)
	
You will then be transferred to disc 2 with the same map id and coordinates as
what the player currently has.
If you want to be more precise and say you want to change to disc 2 on the map
with id 10 and the player must be placed at the tile with x = 6 and y = 13 then
you should put this in a call script:

	change_disc(2, 10, 6, 13)
	
Note that when you start the game the maps directly in the data folder is used.
You can back to them by changing to disc number 0.
Basically, disc number 0 is the maps directly in the data folder and not in any
of the sub folders.

The final argument is the direction. By default the player retains the current
direction. You can put 6 different values as direction:

0, 10 : No change
2 : Turn Down
4 : Turn Left
6 : Turn Right
8 : Turn Up

If you for example want to transfer the player to disc 1, map 43 at x = 30 and
y = 4 with the player looking down you should put this in a call script:

	change_disc(1, 43, 30, 4, 2)
	
*hugs*
 - Created by Zeriab


Modded by NettoHikari
Perfected by Vendily
Variable Sync added by Pokeminer20
v21.1 and v22 port by SocomSeal
=end

class Game_System
	attr_accessor :disc
	attr_accessor :discno
	attr_accessor :discdata

	alias disc_initialize initialize
	def initialize
		disc_initialize
		@disc = ""
		@discno = 0
		@discdata = {}
	end

	def disc
		@disc ||= ""
		return @disc
	end
	
	def discno
		@discno ||= 0
		return @discno
	end

	def discdata
		@discdata ||= {}
		return @discdata
	end
end

class Game_Temp
	attr_accessor :disc_changing
end

def change_disc(number, id = nil, x = nil, y = nil, direction = nil)
	@discno = $game_system.disc.length < 6 ? "0" : $game_system.disc[4...$game_system.disc.length-1]
	if !$game_system.discdata[@discno]
		$game_system.discdata[@discno] = [$game_switches.clone, $game_variables.clone, $game_self_switches.clone]
	end
	
	# Change disc
	if number == 0
		$game_system.disc = "/"
	elsif number.is_a?(Integer)
		$game_system.disc = "disc#{number}/"
	else
		disc = number.to_s
		disc += '/' 
		$game_system.disc = disc
	end
	
	# Clear data cached from the previous disc.
	$game_temp.map_infos = nil if $game_temp
	
	# Process arguments
	num="#{number}"
	if !$game_system.discdata[num]
		$game_system.discdata[num]=[Game_Switches.new,Game_Variables.new,Game_SelfSwitches.new]
	end
	synchronizeSwitches
	synchronizeVariables
	$game_switches = $game_system.discdata[num][0]
	$game_variables = $game_system.discdata[num][1]
	$game_self_switches = $game_system.discdata[num][2]
	map_id = id.is_a?(Integer) ? id : $game_map.map_id
	x = $game_player.x unless x.is_a?(Integer)
	y = $game_player.y unless y.is_a?(Integer)
	direction = $game_player.direction unless direction.is_a?(Integer)
	
	# Set transferring player flag
	$game_temp.player_transferring = true
	
	# Set transferring player flag
	$game_temp.disc_changing = true
	
	# Set player move destination
	$game_temp.player_new_map_id = map_id
	$game_temp.player_new_x = x
	$game_temp.player_new_y = y
	$game_temp.player_new_direction = direction
	
	# Change the current map id in case the new and old are identical.
	$game_map.map_id = 0
	
	# Reloads Map Connections
    GameData.load_all
	MapFactoryHelper.clear
	MapFactoryHelper.getMapConnections
	$game_map.refresh
end

def synchronizeSwitches
	$game_system.discdata.each_value{|data|
		switches=data[0]
		Settings::SYNCRONIZED_SWITCHES.each{|id|
			switches[id]=$game_switches[id]
			}
	}
end

def synchronizeVariables
	$game_system.discdata.each_value{|data|
		variables=data[1]
		Settings::SYNCRONIZED_VARIABLES.each{|id|
			variables[id]=$game_variables[id]
			}
	}
end