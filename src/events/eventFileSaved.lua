function eventFileSaved(id)
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
		print("[STATS] Leaderboard saved!")
		leaderboard.needUpdate = false
		for rank, leader in next, leaderboard.leaders do leaderboard.cached[leader] = rank end
	end
end
