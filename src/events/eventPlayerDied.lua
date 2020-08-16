function eventPlayerDied(name)
	local player = Player.players[name]
	player:setLives(player.lives - 1)
	player.alive = false

	if player.lives == 0 then
		
		Player.alive[name] = nil
		tfm.exec.chatMessage(translate("LOST_ALL", player.community), name)
		Player.aliveCount = Player.aliveCount - 1
		
		if Player.aliveCount == 1 then
			local winner = next(Player.alive)
			tfm.exec.chatMessage(translate("SOLE", tfm.get.room.community, nil, {player = winner}))
			tfm.exec.giveCheese(winner)
			tfm.exec.playerVictory(winner)					
			Timer("newRound", newRound, 3 * 1000)
		end
		
		
	else

		tfm.exec.chatMessage(translate("LIVES_LEFT", player.community, nil, {lives = player.lives}), name)
		Timer("respawn_" .. name, function()
			tfm.exec.respawnPlayer(name)
			player.alive = true
		end, 3000, false)

	end
end
