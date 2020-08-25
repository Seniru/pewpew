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

extractName = function(name)
    return name:match("^(.+)(#%d+)$")
end

createPrettyUI = function(id, x, y, w, h, fixed, closeButton)
    
    local window =  Panel(id * 100 + 10, "", x - 4, y - 4, w + 8, h + 8, 0x7f492d, 0x7f492d, 1, true)
        :addPanel(
            Panel(id * 100 + 20, "", x, y, w, h, 0x152d30, 0x0f1213, 1, true)
        )
        :addImage(Image(assets.widgets.borders.topLeft, "&1",     x - 10,     y - 10))
        :addImage(Image(assets.widgets.borders.topRight, "&1",    x + w - 18, y - 10))
        :addImage(Image(assets.widgets.borders.bottomLeft, "&1",  x - 10,     y + h - 18))
        :addImage(Image(assets.widgets.borders.bottomRight, "&1", x + w - 18, y + h - 18))
        

    if closeButton then
        window
            :addPanel(
                Panel(id * 100 + 30, "<a href='event:close'>\n\n\n\n\n\n</a>", x + w + 18, y - 10, 15, 20, nil, nil, 0, true)
                    :addImage(Image(assets.widgets.closeButton, ":0", x + w + 15, y - 10)
                )
            )
            :setCloseButton(id * 100 + 30)
    end
    
    return window

end

displayProfile = function(player, target)
    local name, tag = extractName(player.name)
    if (not name) or (not tag) then return end -- guest players
    profileWindow:show(target)
    Panel.panels[2 * 100 + 20]:update("<b><font size='20'><V>" .. name .. "</V></font><font size='10'><G>" .. tag, target)
    Panel.panels[151]:update("<b><BV><font size='14'>" .. player.rounds .. "</font></BV>", target)
    Panel.panels[152]:update("<b><BV><font size='14'>" .. player.rounds - player.survived .. "</font></BV>", target)
    Panel.panels[153]:update("<b><BV><font size='14'>" .. player.survived .. "</font></BV>     <font size='10'>(" .. math.floor(player.survived / player.rounds * 100) .."%)</font>", target)
    Panel.panels[154]:update("<b><BV><font size='14'>" .. player.won .. "</font></BV>     <font size='10'>(" .. math.floor(player.won / player.rounds * 100) .."%)</font>", target)
end

do

    rotation = shuffleMaps(maps)
    currentMapIndex = 1
    -- TODO: uncomment the leaderboard handling codes
    -- leaderboard.load()
    Timer("newRound", newRound, 6 * 1000)
    -- Timer("leaderboard", leaderboard.load, 2 * 60 * 1000, true)

    tfm.exec.newGame(rotation[currentMapIndex])
    tfm.exec.setGameTime(8)

    for name in next, tfm.get.room.playerList do
        eventNewPlayer(name)
    end

    profileWindow = createPrettyUI(1, 200, 100, 400, 200, true, true)
        :addPanel(createPrettyUI(2, 240, 80, 250, 35, true))
        :addPanel(
            Panel(150, "", 220, 140, 360, 100, 0x7f492d, 0x7f492d, 1, true)
                :addImage(Image(assets.dummy, "&1", 230, 140))
                :addPanel(Panel(151, "", 290, 150, 120, 50, nil, nil, 0, true))
                :addImage(Image(assets.dummy, "&1", 400, 140))
                :addPanel(Panel(152, "", 460, 150, 120, 50, nil, nil, 0, true))
                :addImage(Image(assets.dummy, "&1", 230, 200))
                :addPanel(Panel(153, "", 290, 210, 120, 50, nil, nil, 0, true))
                :addImage(Image(assets.dummy, "&1", 400, 200))
                :addPanel(Panel(154, "", 460, 210, 120, 50, nil, nil, 0, true))
        )



end

