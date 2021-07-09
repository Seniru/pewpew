function eventFileLoaded(id, data)
	-- print(table.tostring(leaderboard.leaders))
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
		print("[STATS] Leaderboard and map data loaded!")

		local sections = stringutils.split(data, "\n\n")
		local lBoardData = sections[1]

		if maps.dumpCache ~= sections[2] and not maps.overwriteFile then
			maps.dumpCache = sections[2]
			maps.list = stringutils.split(maps.dumpCache, ",")
		end

		if #rotation < 50 then
			rotation = shuffleMaps(maps.list)
		end

		if not (leaderboard.leaderboardData == lBoardData) then
			leaderboard.leaderboardData = lBoardData
			leaderboard.leaders = leaderboard.parseLeaderboard(lBoardData)
		end
		for name, player in next, Player.players do leaderboard.addPlayer(player) end
		leaderboard.save(leaderboard.leaders, #leaderboardNotifyList > 0) -- force save when required
	end
end
