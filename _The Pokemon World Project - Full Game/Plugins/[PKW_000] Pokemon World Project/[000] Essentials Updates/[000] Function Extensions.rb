#-----------------------------------------------------------------------------
# Extends pbPokemonMart to include an endSpeech customization variable
#-----------------------------------------------------------------------------
def pbPokemonMart(stock, introSpeech = nil, endSpeech = nil, cannot_sell = false)
	commands = {}
	commands[:buy]		= _INTL("BUY")
	commands[:sell]	 	= _INTL("SELL") if !cannot_sell
	commands[:cancel] 	= _INTL("EXIT")
	cmd = pbMessage(introSpeech || _INTL("Welcome! How may I help you?"), commands.values, commands.length)
	loop do
		case commands.keys[cmd]
		when :buy
			UI::Mart.new(stock, $bag).main
		when :sell
			pbFadeOutIn { UI::BagSell.new($bag).sell_items }
		else
			pbMessage(_INTL("Do come again!"))
			break
		end
		cmd = pbMessage(endSpeech || _INTL("Is there anything else I can do for you?"), commands.values, commands.length, nil, cmd)
	end
	$game_temp.clear_mart_prices
end