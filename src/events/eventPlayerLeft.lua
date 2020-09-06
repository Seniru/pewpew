function eventPlayerLeft(name)
    if Player.players[name] then
        if Player.alive[name] then
            Player.players[name].lives = 1
            eventPlayerDied(name)
        end
		Player.players[name] = nil
		Player.playerCount = Player.playerCount - 1
	end
end