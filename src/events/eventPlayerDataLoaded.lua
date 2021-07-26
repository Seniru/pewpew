function eventPlayerDataLoaded(name, data)
	-- reset player data if they are stored according to the old version
	if data:find("^v2") then
		dHandler:newPlayer(name, data:sub(3))
	else
		system.savePlayerData(name, "")
		dHandler:newPlayer(name, "")
	end

	local player = Player.players[name]

	player.rounds = dHandler:get(name, "rounds")
	player.survived = dHandler:get(name, "survived")
	player.won = dHandler:get(name, "won")
	player.points = dHandler:get(name, "points")

	player.packs = shop.packsBitList:decode(dHandler:get(name, "packs"))
	local counter = 1
	for pack, hasPack in next, player.packs do
		if pack ~= "Default" and hasPack then
			player.packsArray[counter] = pack
			counter = counter + 1
		end
	end

	player.packs["Random"] = true

	local equipped = dHandler:get(name, "equipped")
	player.equipped = equipped == -1 and "Random" or shop.packsBitList:get(equipped)

	player.roles = roles.list:decode(dHandler:get(name, "roles"))
	player.highestRole = roles.getHighestRole(player)
	setNameColor(name)

	player.version = dHandler:get(name, "version")
	if player.version ~= VERSION then
		player.version = VERSION
		player:savePlayerData()
		if VERSION_IMG then
			player.openedWindow = newsWindow
			newsWindow:show(name)
			Panel.panels[1050]:update(translate("SHOW_CLOGS", player.community))
			Panel.panels[1051]:update(translate("NEW_VERSION", player.community, nil, { version = VERSION }))
		end
	end

end
