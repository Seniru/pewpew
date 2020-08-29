leaderboard = {}

leaderboard.FILE_ID = 1
leaderboard.DUMMY_DATA = [[*souris1,0,0,0,xx|*souris2,0,0,0,xx|*souris3,0,0,0,xx|*souris4,0,0,0,xx|*souris5,0,0,0,xx|*souris6,0,0,0,xx|*souris7,0,0,0,xx|*souris8,0,0,0,xx|*souris9,0,0,0,xx|*souris10,0,0,0,xx|*souris11,0,0,0,xx|*souris12,0,0,0,xx|*souris13,0,0,0,xx|*souris14,0,0,0,xx|*souris15,0,0,0,xx|*souris16,0,0,0,xx|*souris17,0,0,0,xx|*souris18,0,0,0,xx|*souris19,0,0,0,xx|*souris20,0,0,0,xx|*souris21,0,0,0,xx|*souris22,0,0,0,xx|*souris23,0,0,0,xx|*souris24,0,0,0,xx|*souris25,0,0,0,xx|*souris26,0,0,0,xx|*souris27,0,0,0,xx|*souris28,0,0,0,xx|*souris29,0,0,0,xx|*souris30,0,0,0,xx|*souris31,0,0,0,xx|*souris32,0,0,0,xx|*souris33,0,0,0,xx|*souris34,0,0,0,xx|*souris35,0,0,0,xx|*souris36,0,0,0,xx|*souris37,0,0,0,xx|*souris38,0,0,0,xx|*souris39,0,0,0,xx|*souris40,0,0,0,xx|*souris41,0,0,0,xx|*souris42,0,0,0,xx|*souris43,0,0,0,xx|*souris44,0,0,0,xx|*souris45,0,0,0,xx|*souris46,0,0,0,xx|*souris47,0,0,0,xx|*souris48,0,0,0,xx|*souris49,0,0,0,xx|*souris50,0,0,0,xx]]

leaderboard.needUpdate = false
leaderboard.indexed = {}
leaderboard.leaderboardData = leaderboard.leaderboardData or leaderboard.DUMMY_DATA

leaderboard.parseLeaderboard = function(data)
	local res = {}
  	for i, entry in next, string.split(data, "|") do
		local fields = string.split(entry, ",")
		local name = fields[1]
		res[name] = { name = name, rounds = tonumber(fields[2]), survived = tonumber(fields[3]), won = tonumber(fields[4]), community = fields[5] }
		res[name].score = leaderboard.scorePlayer(res[name])
  	end
  	return res
end

leaderboard.dumpLeaderboard = function(lboard)
	local res = ""
	for i, entry in next, lboard do
  		res = res .. entry.name .. "," .. entry.rounds .. "," .. entry.survived .. "," .. entry.won .. "," .. entry.community .. "|"
	end 
	return res:sub(1, -2)
end

leaderboard.load = function()
	local started = system.loadFile(leaderboard.FILE_ID)
	if started then print("[STATS] Loading leaderboard...") end
end

leaderboard.save = function(leaders)
	local serialised, indexes = leaderboard.prepare(leaders)
	if serialised == leaderboard.leaderboardData then return end
	leaderboard.indexed = indexes
	local started = system.saveFile(serialised, leaderboard.FILE_ID)
	if started then print("[STATS] Saving leaderboard...") end
end

leaderboard.scorePlayer = function(player)
    return player.rounds * 0.5 * ((player.won + player.survived) / (player.rounds == 0 and 1 or player.rounds))
end

leaderboard.addPlayer = function(player)
    local score = leaderboard.scorePlayer(player)
	leaderboard.leaders[player.name] = { name = player.name, rounds = player.rounds, survived = player.survived, won = player.won, community = player.community, score = score }
end

leaderboard.prepare = function(leaders)
	
	local temp, res = {}, {} 
    
	for name, leader in next, leaders do temp[#temp + 1] = leader end
    
	table.sort(temp, function(p1, p2)
		return p1.score > p2.score
    end)
    
    for i = 1, 50 do res[i] = temp[i] end
    
	return leaderboard.dumpLeaderboard(res), res

end

leaderboard.displayLeaderboard = function(mode, page, target)
	leaderboardWindow:show(target)
	local leaders = {}
	local rankTxt, nameTxt, roundsTxt, deathsTxt, survivedTxt, wonTxt 
		= "<br><br>", "<br><br>", "<br><br>", "<br><br>", "<br><br>", "<br><br>"

	if mode == "global" then
		for leader = (page - 1) * 10, page * 10 do leaders[#leaders + 1] = leaderboard.indexed[leader] end
		Panel.panels[356]:update("<font size='20'><BV><p align='center'><a href='event:1'>•</a>  <a href='event:2'>•</a>  <a href='event:3'>•</a>  <a href='event:4'>•</a>  <a href='event:5'>•</a></p>")
		Panel.panels[357]:update("<a href='event:switch'>Global \t ▼</a>", target)
	else
		local selfRank
		
		for name, player in next, Player.players do
			leaders[#leaders + 1] = player
		end
		
		table.sort(leaders, function(p1, p2)
			return leaderboard.scorePlayer(p1) > leaderboard.scorePlayer(p2)
		end)
		
		for i, leader in ipairs(leaders) do if leader.name == target then selfRank = i break end end
		-- TODO: Add translations v
		Panel.panels[356]:update("<p align='center'>Your rank: " .. selfRank .. "</p>")
		Panel.panels[357]:update("<a href='event:switch'>Room \t ▼</a>", target)
	end
	
	
	local counter = 0
	for i, leader in next, leaders do
		local name, tag = extractName(leader.name)
		if not (name and tag) then name, tag = leader.name, "" end
		counter = counter + 1
		rankTxt = rankTxt .. "# " .. counter .. "<br>"
		nameTxt = nameTxt .. "\t<b><V>" .. name .. "</V><N><font size='8'>" .. tag .. "</font></N></b><br>"
		roundsTxt = roundsTxt .. leader.rounds .. "<br>"
		deathsTxt = deathsTxt .. (leader.rounds - leader.survived) .. "<br>"
		survivedTxt = survivedTxt .. leader.survived .. " <V><i>(" .. math.floor(leader.survived / (leader.rounds == 0 and 1 or leader.rounds) * 100) .. " %)</i></V><br>"
		wonTxt = wonTxt .. leader.won .. " <V><i>(" .. math.floor(leader.won / (leader.rounds == 0 and 1 or leader.rounds) * 100) .. " %)</i></V><br>"
		Panel.panels[351]:addImageTemp(Image(assets.community[leader.community], "&1", 170, 115 + 13 * counter), target)
		if counter >= 10 then break end
	end

	Panel.panels[350]:update(rankTxt, target)	
	Panel.panels[351]:update(nameTxt, target)
	Panel.panels[352]:update(roundsTxt, target)
	Panel.panels[353]:update(deathsTxt, target)
	Panel.panels[354]:update(survivedTxt, target)
	Panel.panels[355]:update(wonTxt, target)


end

leaderboard.leaders = leaderboard.parseLeaderboard(leaderboard.leaderboardData)
