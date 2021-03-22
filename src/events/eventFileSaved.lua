function eventFileSaved(id)
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
		print("[STATS] Leaderboard saved!")
		print(os.time())
		for _, player in next, leaderboardNotifyList do
			tfm.exec.chatMessage("<N>[</N><R>•</R><N>] Files have been updated!", player)
		end
		leaderboardNotifyList = {}
		leaderboard.needUpdate = false
		maps.overwriteFile = false
	end
end
