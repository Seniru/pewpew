function eventFileSaved(id)
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
		print("[STATS] Leaderboard saved!")
		print(os.time())
		leaderboard.needUpdate = false
	end
end
