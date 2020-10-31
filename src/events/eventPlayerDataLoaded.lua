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
    for name, pack in next, player.packs do 
        if name ~= "Default" then
            player.packsArray[counter] = name
            counter = counter + 1
        end
    end
    
    player.packs["Random"] = true

    local equipped = dHandler:get(name, "equipped")
    player.equipped = equipped == -1 and "Random" or shop.packsBitList:get(equipped)


end
