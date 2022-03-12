function eventKeyboard(name, key, down, x, y)
	if key == keys.SPACE or key == keys.DOWN then
		Player.players[name]:shoot(x, y)
	elseif key == keys.LEFT then
		Player.players[name].stance = -1
	elseif key == keys.RIGHT then
		Player.players[name].stance = 1
	elseif key == keys.LETTER_H then
		displayHelp(name, true)
	elseif key == keys.LETTER_P then
		displayProfile(Player.players[name], name, true)
	elseif key == keys.LETTER_L then
		leaderboard.displayLeaderboard("global", 1, name, true)
	elseif key == keys.LETTER_O then
		shop.displayShop(name, 1, true)
	elseif key == keys.LETTER_U then
		specWaitingList[name] = true
		Player.players[name]:toggleSpectator()
	end
end
