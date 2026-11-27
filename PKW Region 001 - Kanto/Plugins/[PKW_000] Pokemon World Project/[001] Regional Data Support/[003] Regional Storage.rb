#===============================================================================
# These functions are used alongside Game Variables to store
# the player's storage and party in unique regional variables.
# 
# pbMergeStorage is used to merge these regional variables into one
# Global or 'National' storage variable.
# 
# See the script calls in the regional Intro and Hall of Fame events for examples
#===============================================================================
def pbEachPokemonEx
	(-1...$PokemonStorage.maxBoxes).each do |i|
		$PokemonStorage.maxPokemon(i).times do |j|
			pkmn = $PokemonStorage[i][j]
			yield(pkmn, i, j) if pkmn
		end
	end
end

def pbMergeStorage(storageDst, storageSrc)
	$PokemonStorage = storageSrc
	pbEachPokemonEx do |pkmn, i, j|
		$PokemonStorage = storageDst
		return false if $PokemonStorage.full?
		$PokemonStorage.pbStoreCaught(pkmn)
		$PokemonStorage = storageSrc
		$PokemonStorage.pbDelete(i, j)
	end
end