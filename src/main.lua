shuffleMaps = function(maps)
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
	statsEnabled = (not isTribeHouse) and tfm.get.room.uniquePlayers >= MIN_PLAYERS

	if #queuedMaps > 0 then
		tfm.exec.newGame(queuedMaps[1])
		table.remove(queuedMaps, 1)
	else
		currentMapIndex = next(rotation, currentMapIndex)
		tfm.exec.newGame(rotation[currentMapIndex])
		if currentMapIndex >= #rotation then
			rotation = shuffleMaps(maps.list)
			currentMapIndex = 1
		end
	end

	tfm.exec.setGameTime(93, true)

	Player.alive = {}
	Player.aliveCount = 0

	for name, player in next, Player.players do player:refresh() end

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

setNameColor = function(name)
	local player = Player.players[name]
	if (not player) or player.highestRole == "default" then return end
	local color = roles.colors[player.highestRole]
	if not color then return end
	tfm.exec.setNameColor(name, color)
end

isInRotation = function(map)
	map = tostring(map):match("@?(%d+)")
	for i, m in next, maps.list do if m == map then return true, i end end
	return false
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

displayProfile = function(player, target, keyPressed)
	local targetPlayer = Player.players[target]

	if targetPlayer.openedWindow then
		targetPlayer.openedWindow:hide(target)
		if targetPlayer.openedWindow == profileWindow and keyPressed then
			targetPlayer.openedWindow = nil
			return
		end
	end

	local lboardPos
	for i, p in next, leaderboard.indexed do
		if p.name == player.name then
			lboardPos = i
			break
		end
	end

	local count = 0
	for i, role in next, roles.list.featureArray do
		if player.roles[role] then
			Panel.panels[220]:addImageTemp(Image(roles.images[role], "&1", 430 + count * 30, 82), target)
			count = count + 1
		end
	end

	local name, tag = extractName(player.name)
	if (not name) or (not tag) then return end -- guest players
	profileWindow:show(target)
	Panel.panels[220]:update("<b><font size='20'><V>" .. name .. "</V></font><font size='10'><G>" .. tag, target)
	Panel.panels[151]:update(translate("ROUNDS", player.community) .. "<br><b><BV><font size='14'>" .. player.rounds .. "</font></BV>", target)
	Panel.panels[152]:update(translate("DEATHS", player.community) .. "<br><b><BV><font size='14'>" .. player.rounds - player.survived .. "</font></BV>", target)
	Panel.panels[153]:update(translate("SURVIVED", player.community) .. "<br><b><BV><font size='14'>" .. player.survived .. "</font></BV>     <font size='10'>(" .. math.floor(player.survived / player.rounds * 100) .."%)</font>", target)
	Panel.panels[154]:update(translate("WON", player.community) .. "<br><b><BV><font size='14'>" .. player.won .. "</font></BV>     <font size='10'>(" .. math.floor(player.won / player.rounds * 100) .."%)</font>", target)
	Panel.panels[155]:update(translate("LBOARD_POS", player.community, nil, { pos = lboardPos or "N/A" }), target)
	targetPlayer.openedWindow = profileWindow
end

displayHelp = function(target, keyPressed)
	local targetPlayer = Player.players[target]

	if targetPlayer.openedWindow then
		targetPlayer.openedWindow:hide(target)
		if targetPlayer.openedWindow == helpWindow and keyPressed then
			targetPlayer.openedWindow = nil
			return
		end
	end

	local commu = targetPlayer.community
	helpWindow:show(target)
	Panel.panels[820]:update(translate("COMMANDS", commu), target)
	Panel.panels[705]:update(translate("CMD_TITLE",  commu), target)

	Panel.panels[920]:update(translate("CREDITS", commu), target)
	Panel.panels[706]:update(translate("CREDS_TITLE", commu), target)

	Panel.panels[701]:update(translate("OBJECTIVE", commu), target)
	Panel.panels[704]:update(translate("HELP_GOTIT", commu), target)

	targetPlayer.openedWindow = helpWindow
end

displayChangelog = function(target)
	local targetPlayer = Player.players[target]

	if targetPlayer.openedWindow then
		targetPlayer.openedWindow:hide(target)
		if targetPlayer.openedWindow == changelogWindow then
			targetPlayer.openedWindow = nil
			return
		end
	end

	changelogWindow:show(target)
	targetPlayer.openedWindow = changelogWindow
end


do

	rotation = shuffleMaps(maps.list)
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
				:addImage(Image(assets.iconTrophy, "&1", 390, 255))
				:addPanel(Panel(155, "", 420, 260, 210, 30, nil, nil, 0, true))
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
		:addPanel(
			Panel(450, CHANGELOG, 100, 50, 630, 330, nil, nil, 0, true)
				:setActionListener(function(id, name, event)
					tfm.exec.chatMessage("<BV>• <u><i>https://github.com/Seniru/pewpew/releases</i></u></BV>", name)
				end)
		)
		:addImage(Image(assets.widgets.scrollbarBg, "&1", 720, 80))
		:addImage(Image(assets.widgets.scrollbarFg, "&1", 720, 90))

	shopWindow = createPrettyUI(5, 360, 50, 380, 330, true, true) -- main shop window
		:addPanel(  -- preview window
			createPrettyUI(6, 70, 50, 260, 330, true, false)
				:addPanel(
					Panel(650, "", 80, 350, 240, 20, nil, 0x324650, 1, true)
						:setActionListener(function(id, name, event)
							local key, value = table.unpack(string.split(event, ":"))
							local player = Player.players[name]
							local pack = shop.packs[value]
							if not pack then return end
							if key == "buy" then
								-- Exit if the player already have the pack or if they dont have the required points
								if player.packs[value] or player.points < pack.price then return end
								player.packs[value] = true
								player.equipped = value
								player.points = player.points - pack.price
								player.packsArray[#player.packsArray + 1] = value
								shop.displayShop(name)
								player:savePlayerData()
							elseif key == "equip" then
								-- Exit if the player don't have the pack
								if not player.packs[value] then return end
								player.equipped =  value
								player:savePlayerData()
								shop.displayPackInfo(name, value)
							end
						end)
				)
			:addPanel(Panel(651, "", 160, 60, 150, 90, nil, nil, 0, true))
			:addPanel(Panel(652, "", 80, 160, 100, 100, nil, nil, 0, true))
		):addPanel(
		Panel(551, "〈", 620, 350, 40, 20, nil, 0x324650, 1, true)
			:setActionListener(function(id, name, event)
				shop.displayShop(name, tonumber(event))
			end)
		):addPanel(
		Panel(552, "〉", 680, 350, 40, 20, nil, 0x324650, 1, true)
			:setActionListener(function(id, name, event)
				shop.displayShop(name, tonumber(event))
			end)
		)

	helpWindow = Panel(700, ("<br><br>\t <J><b><a href='event:changelog'>%s</a></b></J>        <a href='event:github'>  </a>   <a href='event:discord'>  </a>    <a href='event:map'>  </a>"):format(VERSION), 0, 0, 800, 50, 0x324650, 0x324650, 0, true)
		:setActionListener(function(id, name, event)
			if event == "changelog" then displayChangelog(name) end end)
		:addImage(Image(assets.help.github, ":1", 120, 30))
		:addImage(Image(assets.help.discord, ":1", 144, 30))
		:addImage(Image(assets.help.map, ":1", 170, 30))
		:addPanel(
			Panel(701, "", 180, 150, 200, 20, 0x324650, 0x324650, 0.6, true)
				:addImage(Image(assets.help.survive, ":1", 10, 10))
				:addImage(Image(assets.help.killAll, ":1", 200, 10))
		)
		:addPanel(
			createPrettyUI(8, 10, 220, 230, 165, true)
				:addPanel(Panel(705, "", 90, 200, 300, 30, nil, nil, 0, true))
				:addImage(Image(assets.help.commands, "&1", -55, 150))
		)
		:addPanel(
			createPrettyUI(9, 270, 220, 230, 165, true)
				:addPanel(Panel(706, "", 345, 200, 300, 30, nil, nil, 0, true))
				:addImage(Image(assets.help.creditors, "&1", 260, 170))
		)
		:addImage(Image(assets.help.shoot, "&1", 521, 28))
		:addImage(Image(assets.help.weapon, ":1", 480, 220))
		:addPanel(
			Panel(704, "", 585, 370, 100, 30, nil, nil, 0, true)
				:addImage(Image("170970cdb9f.png", ":1", 550, 350))
		)
		:setCloseButton(704)
		:addPanel(
			Panel(710, "<a href='event:github'>\n\n\n\n</a>", 120, 25, 18, 20, nil, nil, 0, true)
				:setActionListener(function(id, name, event)
					tfm.exec.chatMessage(translate("HELP_GITHUB", Player.players[name].community), name)
				end)
		)
		:addPanel(
			Panel(711, "<a href='event:discord'>\n\n\n\n</a>", 144, 25, 18, 20, nil, nil, 0, true)
				:setActionListener(function(id, name, event)
					tfm.exec.chatMessage(translate("HELP_DISCORD", Player.players[name].community), name)
				end)
		)
		:addPanel(
			Panel(712, "<a href='event:map'>\n\n\n\n</a>", 170, 25, 18, 20, nil, nil, 0, true)
				:setActionListener(function(id, name, event)
					tfm.exec.chatMessage(translate("HELP_MAP", Player.players[name].community), name)
				end)
		)

end
