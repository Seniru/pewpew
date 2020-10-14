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
                local winners = ""
                local winner = ""
				for name, player in next, Player.alive do
                    if statsEnabled then
                        player.rounds = player.rounds + 1
						player.survived = player.survived + 1
						player.points = player.points + 2
                        player:savePlayerData()
                    end
					if aliveCount == 1 then
                        winners = winners:sub(1, -3)
                        local n, t = extractName(name)
                        winner = "<b><VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font></b>"
						break
                    end
                    local n, t = extractName(name)
					winners = winners .. "<b><VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font></b>" .. ", "
					aliveCount = aliveCount - 1			
                end
                tfm.exec.chatMessage(translate("SURVIVORS", tfm.get.room.community, nil, { winners = winners, winner = winner }))
			end
			Timer("newRound", newRound, 3 * 1000)
			tfm.exec.setGameTime(4, true)
		end
	end

end