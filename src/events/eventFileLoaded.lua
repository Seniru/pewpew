function eventFileLoaded(id, data)
	-- print(table.tostring(leaderboard.leaders))
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
		print("[STATS] Leaderboard data loaded!")
		if not (leaderboard.leaderboardData == data) then
			leaderboard.leaderboardData = data
			leaderboard.leaders = leaderboard.parseLeaderboard(data)
		end
		for name, player in next, Player.players do leaderboard.addPlayer(player) end
		leaderboard.save(leaderboard.leaders)
	end
end
