function eventPlayerLeft(name)
	if Player.players[name] then
		Player.players[name].lives = 1
		eventPlayerDied(name)
		Player.players[name] = nil
		Player.playerCount = Player.playerCount - 1
	end
end