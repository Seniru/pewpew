cmds = {
    ["profile"] = function(args, msg, author)
        local player = Player.players[args[1] or author] or Player.players[author]
        displayProfile(player, author)
    end,
    ["help"] = function(args, msg, author)
        displayHelp(author)
    end,
    ["shop"] = function(args, msg, author)
        shop.displayShop(author)
    end,
    ["changelog"] = function(args, msg, author)
        displayChangelog(author)
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
    statsEnabled = (not isTribeHouse) and tfm.get.room.uniquePlayers >= MIN_PLAYERS


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
                currentItem = ENUM_ITEMS.CANNON
            else
                currentItem = items[math.random(1, #items)]
            end
            tfm.exec.removeImage(closeSequence[1].images[1])
            closeSequence[1].images = { tfm.exec.addImage(assets.items[currentItem], ":1", 740, 330) }
        end, 10000, true)
    end

end

getPos = function(item, stance)
	if item == ENUM_ITEMS.CANNON then		
		return { x = stance == -1 and 10 or -10, y = 18 }	
	elseif item == ENUM_ITEMS.SPIRIT then		
		return { x = 0, y = 10 }	
	else		
		return { x = stance == -1 and -10 or 10, y = 0 }	
	end
end

getRot = function(item, stance)	
	if item == ENUM_ITEMS.RUNE or item == ENUM_ITEMS.CUPID_ARROW or item == ENUM_ITEMS.STABLE_RUNE then
		return stance == -1 and 180 or 0	
	elseif item == ENUM_ITEMS.CANNON then
		return stance == -1 and -90 or 90
	else
		return 0	
	end
end

extractName = function(username)
    username = username or ""
    local name, tag = username:match("^(.+)(#%d+)$")
    if name and tag then return name, tag
    else return username, "" end
end

createPrettyUI = function(id, x, y, w, h, fixed, closeButton)

    local window =  Panel(id * 100 + 10, "", x - 4, y - 4, w + 8, h + 8, 0x7f492d, 0x7f492d, 1, fixed)
        :addPanel(
            Panel(id * 100 + 20, "", x, y, w, h, 0x152d30, 0x0f1213, 1, fixed)
        )
        :addImage(Image(assets.widgets.borders.topLeft, "&1",     x - 10,     y - 10))
        :addImage(Image(assets.widgets.borders.topRight, "&1",    x + w - 18, y - 10))
        :addImage(Image(assets.widgets.borders.bottomLeft, "&1",  x - 10,     y + h - 18))
        :addImage(Image(assets.widgets.borders.bottomRight, "&1", x + w - 18, y + h - 18))


    if closeButton then
        window
            :addPanel(
                Panel(id * 100 + 30, "<a href='event:close'>\n\n\n\n\n\n</a>", x + w + 18, y - 10, 15, 20, nil, nil, 0, fixed)
                    :addImage(Image(assets.widgets.closeButton, ":0", x + w + 15, y - 10)
                )
            )
            :setCloseButton(id * 100 + 30)
    end

    return window

end

displayProfile = function(player, target)
    local targetPlayer = Player.players[target]
    if targetPlayer.openedWindow then targetPlayer.openedWindow:hide(target) end
    local name, tag = extractName(player.name)
    if (not name) or (not tag) then return end -- guest players
    profileWindow:show(target)
    Panel.panels[220]:update("<b><font size='20'><V>" .. name .. "</V></font><font size='10'><G>" .. tag, target)
    Panel.panels[151]:update(translate("ROUNDS", player.community) .. "<br><b><BV><font size='14'>" .. player.rounds .. "</font></BV>", target)
    Panel.panels[152]:update(translate("DEATHS", player.community) .. "<br><b><BV><font size='14'>" .. player.rounds - player.survived .. "</font></BV>", target)
    Panel.panels[153]:update(translate("SURVIVED", player.community) .. "<br><b><BV><font size='14'>" .. player.survived .. "</font></BV>     <font size='10'>(" .. math.floor(player.survived / player.rounds * 100) .."%)</font>", target)
    Panel.panels[154]:update(translate("WON", player.community) .. "<br><b><BV><font size='14'>" .. player.won .. "</font></BV>     <font size='10'>(" .. math.floor(player.won / player.rounds * 100) .."%)</font>", target)
    targetPlayer.openedWindow = profileWindow
end

displayHelp = function(target)
    tfm.exec.chatMessage("<br>" .. translate("WELCOME", tfm.get.room.playerList[target].community), target)
    tfm.exec.chatMessage("<N>Report any bug to </N><VP>King_seniru</VP><G>#5890</G><br><br><b><VI>Commands</VI></b><br><br>[ <b>H</b> ] <N><ROSE>!help</ROSE> (displays this help menu)</N><br>[ <b>P</b> ] <N><ROSE>!profile <i>[player]</i></ROSE> (displays the profile of the player)</N><br>[ <b>L</b> ] <N>(displays the leaderboard)</N><br><br><N><ROSE>!changelog</ROSE> (displays the changelog)</N><br>", target)
end

displayChangelog = function(target)
    local targetPlayer = Player.players[target]
    if targetPlayer.openedWindow then targetPlayer.openedWindow:hide(target) end
    changelogWindow:show(target)
    targetPlayer.openedWindow = changelogWindow
end


do

    rotation = shuffleMaps(maps)
    currentMapIndex = 1
    statsEnabled = (not isTribeHouse) and tfm.get.room.uniquePlayers >= MIN_PLAYERS

    leaderboard.load()
    Timer("newRound", newRound, 6 * 1000)
    Timer("leaderboard", leaderboard.load, 2 * 60 * 1000, true)

    tfm.exec.newGame(rotation[currentMapIndex])
    tfm.exec.setGameTime(8)

    for cmd in next, cmds do system.disableChatCommandDisplay(cmd) end

    for name in next, tfm.get.room.playerList do
        eventNewPlayer(name)
    end

    profileWindow = createPrettyUI(1, 200, 100, 400, 200, true, true)
        :addPanel(createPrettyUI(2, 240, 80, 250, 35, true))
        :addPanel(
            Panel(150, "", 220, 140, 360, 100, 0x1A3846 , 0x1A3846, 1, true)
                :addImage(Image(assets.iconRounds, "&1", 230, 125))
                :addPanel(Panel(151, "", 290, 140, 120, 50, nil, nil, 0, true))
                :addImage(Image(assets.iconDeaths, "&1", 400, 125))
                :addPanel(Panel(152, "", 460, 140, 120, 50, nil, nil, 0, true))
                :addImage(Image(assets.iconSurvived, "&1", 230, 185))
                :addPanel(Panel(153, "", 290, 200, 120, 50, nil, nil, 0, true))
                :addImage(Image(assets.iconWon, "&1", 400, 185))
                :addPanel(Panel(154, "", 460, 200, 120, 50, nil, nil, 0, true))
        )

    leaderboardWindow = createPrettyUI(3, 70, 50, 670, 330, true, true)
        :addPanel(Panel(350, "", 90, 100, 50, 240, 0x1A3846, 0x1A3846, 1, true))
        :addPanel(Panel(351, "", 160, 100, 200, 240, 0x1A3846, 0x1A3846, 1, true))
        :addPanel(
            Panel(352, "", 380, 100, 70, 240, 0x1A3846, 0x1A3846, 1, true)
                :addImage(Image(assets.iconRounds, "&1", 380, 70))
        )
        :addPanel(
            Panel(353, "", 470, 100, 70, 240, 0x1A3846, 0x1A3846, 1, true)
                :addImage(Image(assets.iconDeaths, "&1", 470, 70))
        )
        :addPanel(
            Panel(354, "", 560, 100, 70, 240, 0x1A3846, 0x1A3846, 1, true)
                :addImage(Image(assets.iconSurvived, "&1", 560, 70))
        )
        :addPanel(
            Panel(355, "", 650, 100, 70, 240, 0x1A3846, 0x1A3846, 1, true)
                :addImage(Image(assets.iconWon, "&1", 650, 70))
        )
        :addPanel(
            Panel(356, "", 70, 350, 670, 50, nil, nil, 0, true)
                :setActionListener(function(id, name, event)
                    local page = tonumber(event)
                    if page then
                        leaderboardWindow:hide(name)
                        leaderboard.displayLeaderboard("global", page, name)
                    end
                end)
            )
        :addPanel(
            Panel(357, "<a href='event:switch'>Room \t ▼</a>", 90, 55, 80, 20, 0x152d30, 0x7f492d, 1, true)
                :setActionListener(function(id, name, event)
                    Panel.panels[id]:addPanelTemp(
                        Panel(358, "<a href='event:room'>Room</a><br><a href='event:global'>Global</a>", 90, 85, 80, 30, 0x152d30, 0x7f492d, 1, true)
                            :setActionListener(function(id, name, event)
                                leaderboardWindow:hide(name)
                                leaderboard.displayLeaderboard(event, 1, name)
                            end),
                    name)
                end)
        )

    changelogWindow = createPrettyUI(4, 70, 50, 670, 330, true, true)
        :addPanel(Panel(450, CHANGELOG, 70, 50, 670, 330, nil, nil, 0, true))
        :addImage(Image(assets.widgets.scrollbarBg, "&1", 720, 80))
        :addImage(Image(assets.widgets.scrollbarFg, "&1", 720, 90))

    shopWindow = createPrettyUI(5, 360, 50, 380, 330, true, true) -- main shop window
        :addPanel(  -- preview window 
            createPrettyUI(6, 70, 50, 260, 330, true, false)
                :addPanel(
                    Panel(650, "", 80, 350, 240, 20, nil, 0x324650, 1, true)
                        :setActionListener(function(id, name, event)
                            local player = Player.players[name]
                            local key, value = table.unpack(string.split(event, ":"))
                            if key == "buy" then
                                -- TODO: Add checks
                                player.packs[value] = true
                                player.equipped = value
                                print(table.tostring(player.packs))
                                print(shop.packsBitList:encode(player.packs))
                            end
                        end)
                )
                :addPanel(Panel(651, "", 160, 60, 150, 90, nil, nil, 0, true))
                :addPanel(Panel(652, "", 80, 160, 100, 100, nil, nil, 0, true))
        )

end

