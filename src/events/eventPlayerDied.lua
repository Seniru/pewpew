function eventPlayerDied(name)
    local player = Player.players[name]
    
	if not player then return end
	if not newRoundStarted then
		tfm.exec.respawnPlayer(name)
		return player:refresh()
    end
    if not Player.alive[name] then return end -- leaving the room

	player.lives = player.lives - 1
	tfm.exec.setPlayerScore(name, player.lives)
	player.alive = false

	if player.lives == 0 then
		
		Player.alive[name] = nil
		tfm.exec.chatMessage(translate("LOST_ALL", player.community), name)
		player.rounds = player.rounds + 1
		Player.aliveCount = Player.aliveCount - 1
        player:savePlayerData()
        		
		if Player.aliveCount == 1 then
			local winner = next(Player.alive)
			local winnerPlayer = Player.players[winner]
			tfm.exec.chatMessage(translate("SOLE", tfm.get.room.community, nil, {player = winner}))
			tfm.exec.giveCheese(winner)
			tfm.exec.playerVictory(winner)
			winnerPlayer.rounds = winnerPlayer.rounds + 1
			winnerPlayer.survived = winnerPlayer.survived + 1
			winnerPlayer.won = winnerPlayer.won + 1
			winnerPlayer:savePlayerData()	
			Timer("newRound", newRound, 3 * 1000)
		elseif Player.aliveCount == 0  then
			Timer("newRound", newRound, 3 * 1000)
		end
		
	else

		tfm.exec.chatMessage(translate("LIVES_LEFT", player.community, nil, {lives = player.lives}), name)
		Timer("respawn_" .. name, function()
			tfm.exec.respawnPlayer(name)
			player:setLives(player.lives)
			player.alive = true
		end, 3000, false)

	end
end
