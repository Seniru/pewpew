function eventKeyboard(name, key, down, x, y)
	if key == keys.SPACE or key == keys.DOWN then
		Player.players[name]:shoot(x, y)
	elseif key == keys.LEFT then
		Player.players[name].stance = -1
	elseif key == keys.RIGHT then
		Player.players[name].stance = 1
    elseif key == keys.LETTER_H then
        displayHelp(name)
    elseif key == keys.LETTER_P then
        displayProfile(Player.players[name], name)
    elseif key == keys.LETTER_L then
        leaderboard.displayLeaderboard("global", 1, name)
    elseif key == keys.LETTER_O then
        shop.displayShop(name, 1)
    end
end
