local rotation, currentMapIndex = {}

local shuffleMaps = function(maps)
    local res = {}
    for _, map in next, maps do
        res[#res + 1] = map
        res[#res + 1] = map
    end
    table.sort(res, function(e1, e2)
        return math.random() <= 0.5
    end)
    return res
end

newRound = function()
    
    newRoundStarted = false
    suddenDeath = false
    currentMapIndex = next(rotation, currentMapIndex)
    
    tfm.exec.newGame(rotation[currentMapIndex])
    tfm.exec.setGameTime(93, true)
    
    Player.alive = {}
    Player.aliveCount = 0
    for name, player in next, Player.players do player:refresh() end
    
    if currentMapIndex >= #rotation then
        rotation = shuffleMaps(maps)
        currentMapIndex = 1
    end

    if not initialized then
        initialized = true
        closeSequence[1].images = { tfm.exec.addImage(assets.items[currentItem],":1", 630, 210) }
        Timer("changeItem", function()
            if math.random(1, 3) == 3 then
                currentItem = 17 -- cannon
            else
                currentItem = items[math.random(1, #items)]
            end
            tfm.exec.removeImage(closeSequence[1].images[1])
            closeSequence[1].images = { tfm.exec.addImage(assets.items[currentItem], ":1", 630, 210) }    
        end, 10000, true)
    end

end

getPos = function(item, stance)
	if item == 17 then		
		return { x = stance == -1 and 10 or -10, y = 18 }	
	elseif item == 24 then		
		return { x = 0, y = 10 }	
	else		
		return { x = stance == -1 and -10 or 10, y = 0 }	
	end
end

getRot = function(item, stance)	
	if item == 32 or item == 35 or item == 62 then
		return stance == -1 and 180 or 0	
	elseif item == 17 then
		return stance == -1 and -90 or 90
	else
		return 0	
	end
end

do
    rotation = shuffleMaps(maps)
    currentMapIndex = 1
    Timer("newRound", newRound, 6 * 1000)
    tfm.exec.newGame(rotation[currentMapIndex])
    tfm.exec.setGameTime(8)
    for name in next, tfm.get.room.playerList do
        eventNewPlayer(name)
    end
end

