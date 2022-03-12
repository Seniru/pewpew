function eventPlayerDied(name)
	local player = Player.players[name]
	if not player then return end
	if player.isSpecMode and not specWaitingList[name] then return end
	if not newRoundStarted then
		tfm.exec.respawnPlayer(name)
		return player:refresh()
	end

	player.lives = player.lives - 1
	tfm.exec.setPlayerScore(name, player.lives)
	player.alive = false

	if player.lives == 0 then
		player:die()
	else
		tfm.exec.chatMessage(translate("LIVES_LEFT", player.community, nil, {lives = player.lives}), name)
		Timer("respawn_" .. name, function()
			tfm.exec.respawnPlayer(name)
			setNameColor(name)
			player:setLives(player.lives)
			player.alive = true
		end, 3000, false)
	end
end
