cmds = {
    ["p"] = function(args, msg, author)
        local player = Player.players[args[1] or author] or Player.players[author]
        displayProfile(player, author)
    end,
    ["lboard"] = function(args, msg, author) -- temporary commands
        local leaders = {}
        for name, player in next, Player.players do leaders[#leaders + 1] = player end
        table.sort(leaders, function(p1, p2)
            return leaderboard.scorePlayer(p1) > leaderboard.scorePlayer(p2)
        end)
        ui.addTextArea(1,
            "<a href='event:close'>X</a><br>" .. table.tostring(leaders),
            author, 300, 150, 300, 300, nil, nil, 1, true
        )
    end,
    ["glboard"] = function(args, msg, author) -- temporary commands
        print(table.tostring(leaderboard.leaders))
    end
}

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
        closeSequence[1].images = { tfm.exec.addImage(assets.items[currentItem],":1", 740, 330) }
        Timer("changeItem", function()
            if math.random(1, 3) == 3 then
                currentItem = 17 -- cannon
            else
                currentItem = items[math.random(1, #items)]
            end
            tfm.exec.removeImage(closeSequence[1].images[1])
            closeSequence[1].images = { tfm.exec.addImage(assets.items[currentItem], ":1", 740, 330) }    
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

createPrettyUI = function(id, x, y, w, h, fixed)
    
    return Panel(id * 100 + 10, "", x - 4, y - 4, w + 8, h + 8, 0x7f492d, 0x7f492d, 1, true)
        :addPanel(
            Panel(id * 100 + 20, "", x, y, w, h, 0x152d30, 0x0f1213, 1, true)
        )
        :addPanel(
            Panel(id * 100 + 30, "<a href='event:close'>\n\n\n\n\n\n</a>", x + w + 18, y - 10, 15, 20, nil, nil, 0, true)
                :addImage(Image(assets.widgets.closeButton, ":0", x + w + 15, y - 10))
        )
        :addImage(Image(assets.widgets.borders.topLeft, "&1",     x - 10,     y - 10))
        :addImage(Image(assets.widgets.borders.topRight, "&1",    x + w - 18, y - 10))
        :addImage(Image(assets.widgets.borders.bottomLeft, "&1",  x - 10,     y + h - 18))
        :addImage(Image(assets.widgets.borders.bottomRight, "&1", x + w - 18, y + h - 18))
        :setCloseButton(id * 100 + 30)
        
end

displayProfile = function(player, target)
    profileWindow:show(target)
    profileWindow.children[1 * 100 + 20]:update(player.name, target)
end

do

    rotation = shuffleMaps(maps)
    currentMapIndex = 1

    leaderboard.load()
    Timer("newRound", newRound, 6 * 1000)
    Timer("leaderboard", leaderboard.load, 2 * 60 * 1000, true)

    tfm.exec.newGame(rotation[currentMapIndex])
    tfm.exec.setGameTime(8)

    for name in next, tfm.get.room.playerList do
        eventNewPlayer(name)
    end

    --[[profileWindow = Panel(100, "", 300, 150, 300, 200, 0x7f492d, 0x7f492d, 1, true)
        :addPanel(
            Panel(110, "", 304, 154, 292, 192, 0x152d30, 0x0f1213, 1, true)
        )
        :addPanel(
            Panel(120, "<a href='event:close'>\n\n\n\n\n\n</a>", 615, 145, 10, 15, nil, nil, 0, true)
                :addImage(Image(assets.widgets.closeButton, ":0", 610, 145))
        )
        :addImage(Image(assets.widgets.borders.topLeft, "&1", 293, 142))
        :addImage(Image(assets.widgets.borders.topRight, "&1", 580, 142))
        :addImage(Image(assets.widgets.borders.bottomLeft, "&1", 293, 330))
        :addImage(Image(assets.widgets.borders.bottomRight, "&1", 580, 330))
        :setCloseButton(120)]]
    profileWindow = createPrettyUI(1, 300, 150, 300, 200, true)



end

