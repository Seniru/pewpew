leaderboard = {}

leaderboard.FILE_ID = 1
leaderboard.DUMMY_DATA = [[*souris1,0,0,0,xx|*souris2,0,0,0,xx|*souris3,0,0,0,xx|*souris4,0,0,0,xx|*souris5,0,0,0,xx|*souris6,0,0,0,xx|*souris7,0,0,0,xx|*souris8,0,0,0,xx|*souris9,0,0,0,xx|*souris10,0,0,0,xx|*souris11,0,0,0,xx|*souris12,0,0,0,xx|*souris13,0,0,0,xx|*souris14,0,0,0,xx|*souris15,0,0,0,xx|*souris16,0,0,0,xx|*souris17,0,0,0,xx|*souris18,0,0,0,xx|*souris19,0,0,0,xx|*souris20,0,0,0,xx|*souris21,0,0,0,xx|*souris22,0,0,0,xx|*souris23,0,0,0,xx|*souris24,0,0,0,xx|*souris25,0,0,0,xx|*souris26,0,0,0,xx|*souris27,0,0,0,xx|*souris28,0,0,0,xx|*souris29,0,0,0,xx|*souris30,0,0,0,xx|*souris31,0,0,0,xx|*souris32,0,0,0,xx|*souris33,0,0,0,xx|*souris34,0,0,0,xx|*souris35,0,0,0,xx|*souris36,0,0,0,xx|*souris37,0,0,0,xx|*souris38,0,0,0,xx|*souris39,0,0,0,xx|*souris40,0,0,0,xx|*souris41,0,0,0,xx|*souris42,0,0,0,xx|*souris43,0,0,0,xx|*souris44,0,0,0,xx|*souris45,0,0,0,xx|*souris46,0,0,0,xx|*souris47,0,0,0,xx|*souris48,0,0,0,xx|*souris49,0,0,0,xx|*souris50,0,0,0,xx]]

leaderboard.needUpdate = false
leaderboard.leaderboardData = leaderboard.leaderboardData or leaderboard.DUMMY_DATA

leaderboard.parseLeaderboard = function(data)
	local res, cachedIndexes = {}, {}
  	for i, entry in next, string.split(data, "|") do
    	local fields = string.split(entry, ",")
		res[#res + 1] = { name = fields[1], rounds = tonumber(fields[2]), survived = tonumber(fields[3]), won = tonumber(fields[4]), commu = fields[5] }
		res[#res].score = leaderboard.scorePlayer(res[#res])
		cachedIndexes[fields[1]] = #res
  	end
  	return res, cachedIndexes
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

leaderboard.save = function()
	local started = system.saveFile(leaderboard.dumpLeaderboard(leaderboard.leaders), leaderboard.FILE_ID)
	if started then print("[STATS] Saving leaderboard...") end
end

leaderboard.scorePlayer = function(player)
    return player.rounds * 0.5 * ((player.won + player.survived) / (player.rounds == 0 and 1 or player.rounds))
end

leaderboard.addPlayer = function(player)
	local score = leaderboard.scorePlayer(player)
	--[[if score < leaderboard.leaders[#leaderboard.leaders].score then return end
	leaderboard.leaders[#leaderboard.leaders + 1] = { name = player.name, rounds = player.rounds, survived = player.survived, won = player.won, commu = player.community, score = score }
	]]
	local cachedIndex = leaderboard.cached[player.name]
	if cachedIndex then
		print(player.name .. " is cached")
		if score == leaderboard.leaders[cachedIndex].score then return print("but no need to add") end
		leaderboard.leaders[cachedIndex] = { name = player.name, rounds = player.rounds, survived = player.survived, won = player.won, commu = player.community, score = score }
	elseif score > leaderboard.leaders[#leaderboard.leaders].score then
		print("player is not cached but can be added")
		leaderboard.leaders[#leaderboard.leaders] = { name = player.name, rounds = player.rounds, survived = player.survived, won = player.won, commu = player.community, score = score }
	else return print("lol noob") end

	table.sort(leaderboard.leaders, function(p1, p2)
		return p1.score > p2.score
	end)

	leaderboard.needUpdate = true
end

leaderboard.leaders, leaderboard.cached = leaderboard.parseLeaderboard(leaderboard.leaderboardData)
