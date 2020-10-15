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
    Player.players[name].points = dHandler:get(name, "points")
    Player.players[name].packs = shop.packsBitList:decode(dHandler:get(name, "packs"))
    Player.players[name].equipped = shop.packsBitList:get(dHandler:get(name, "equipped"))

end
