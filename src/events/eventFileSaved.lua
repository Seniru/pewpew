function eventFileSaved(id)
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
		print("[STATS] Leaderboard saved!")
		leaderboard.needUpdate = false
	end
end
