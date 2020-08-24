function eventLoop(tc, tr)
	
	Timer.process()

	if tr < 0 and initialized then
		if not suddenDeath then			
			suddenDeath = true		
			tfm.exec.chatMessage(translate("SD", tfm.get.room.community))
			for name, player in next, Player.alive do
				player:setLives(1)
			end
			tfm.exec.setGameTime(30, true)
		else
			local aliveCount = Player.aliveCount
			if aliveCount > 1 then
				local winnerString = ""
				for name, player in next, Player.alive do
					player.rounds = player.rounds + 1
					player.survived = player.survived + 1
					player:savePlayerData()
					if aliveCount == 1 then
						winnerString = winnerString:sub(1, -3) .. " and " .. name
						break
					end
					winnerString = winnerString .. name .. ", "
					aliveCount = aliveCount - 1			
				end
				tfm.exec.chatMessage("we have some loads of winners this time: " .. winnerString)
			end
			tfm.exec.chatMessage("starting a new round")
			Timer("newRound", newRound, 3 * 1000)
			tfm.exec.setGameTime(4, true)
		end
	end

end