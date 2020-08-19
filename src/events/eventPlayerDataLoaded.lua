function eventPlayerDataLoaded(name, data)
	-- reset player data if they are stored according to the old version
	if data:find("^v2") then
        dHandler:newPlayer(name, data:sub(3))
    else
        system.savePlayerData(name, "")
        dHandler:newPlayer(name, "")
    end

	Player.players[name].rounds = dHandler:get(name, "rounds")
	Player.players[name].survived = dHandler:get(name, "survived")
	Player.players[name].won = dHandler:get(name, "won")

	print(table.tostring(Player.players[name]))
	print(dHandler:dumpPlayer(name))

end