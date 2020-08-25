leaderboard = {}

leaderboard.FILE_ID = 1
leaderboard.DUMMY_DATA = [[*souris1,0,0,0,xx|*souris2,0,0,0,xx|*souris3,0,0,0,xx|*souris4,0,0,0,xx|*souris5,0,0,0,xx|*souris6,0,0,0,xx|*souris7,0,0,0,xx|*souris8,0,0,0,xx|*souris9,0,0,0,xx|*souris10,0,0,0,xx|*souris11,0,0,0,xx|*souris12,0,0,0,xx|*souris13,0,0,0,xx|*souris14,0,0,0,xx|*souris15,0,0,0,xx|*souris16,0,0,0,xx|*souris17,0,0,0,xx|*souris18,0,0,0,xx|*souris19,0,0,0,xx|*souris20,0,0,0,xx|*souris21,0,0,0,xx|*souris22,0,0,0,xx|*souris23,0,0,0,xx|*souris24,0,0,0,xx|*souris25,0,0,0,xx|*souris26,0,0,0,xx|*souris27,0,0,0,xx|*souris28,0,0,0,xx|*souris29,0,0,0,xx|*souris30,0,0,0,xx|*souris31,0,0,0,xx|*souris32,0,0,0,xx|*souris33,0,0,0,xx|*souris34,0,0,0,xx|*souris35,0,0,0,xx|*souris36,0,0,0,xx|*souris37,0,0,0,xx|*souris38,0,0,0,xx|*souris39,0,0,0,xx|*souris40,0,0,0,xx|*souris41,0,0,0,xx|*souris42,0,0,0,xx|*souris43,0,0,0,xx|*souris44,0,0,0,xx|*souris45,0,0,0,xx|*souris46,0,0,0,xx|*souris47,0,0,0,xx|*souris48,0,0,0,xx|*souris49,0,0,0,xx|*souris50,0,0,0,xx]]

leaderboard.needUpdate = false
leaderboard.leaderboardData = leaderboard.leaderboardData or leaderboard.DUMMY_DATA

leaderboard.parseLeaderboard = function(data)
	local res = {}
  	for i, entry in next, string.split(data, "|") do
		local fields = string.split(entry, ",")
		local name = fields[1]
		res[name] = { name = name, rounds = tonumber(fields[2]), survived = tonumber(fields[3]), won = tonumber(fields[4]), commu = fields[5] }
		res[name].score = leaderboard.scorePlayer(res[name])
  	end
  	return res
end

leaderboard.dumpLeaderboard = function(lboard)
	local res = ""
	for i, entry in next, lboard do
  		res = res .. entry.name .. "," .. entry.rounds .. "," .. entry.survived .. "," .. entry.won .. "," .. entry.commu .. "|"
	end 
	return res:sub(1, -2)
end

leaderboard.load = function()
	local started = system.loadFile(leaderboard.FILE_ID)
	if started then print("[STATS] Loading leaderboard...") end
end

leaderboard.save = function(leaders)
	local serialised = leaderboard.prepare(leaders)
	if serialised == leaderboard.leaderboardData then return end
	local started = system.saveFile(serialised, leaderboard.FILE_ID)
	if started then print("[STATS] Saving leaderboard...") end
end

leaderboard.scorePlayer = function(player)
    return player.rounds * 0.5 * ((player.won + player.survived) / (player.rounds == 0 and 1 or player.rounds))
end

leaderboard.addPlayer = function(player)
	local score = leaderboard.scorePlayer(player)
	leaderboard.leaders[player.name] = { name = player.name, rounds = player.rounds, survived = player.survived, won = player.won, commu = player.community, score = score }
end

leaderboard.prepare = function(leaders)
	
	local res, i = {}, 0

	for name, leader in next, leaders do
		i = i + 1
		res[i] = leader
		if i >= 50 then break end
	end

	table.sort(res, function(p1, p2)
		return p1.score > p2.score
	end)

	return leaderboard.dumpLeaderboard(res)

end

leaderboard.leaders = leaderboard.parseLeaderboard(leaderboard.leaderboardData)
