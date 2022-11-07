local attributes = { "ALLOWED", "RESTRICT", "GREY" }

function eventNewGame()
	if not initialized then return end
	local fromQueue = mapProps.fromQueue
	mapProps = { allowed = nil, restricted = nil, grey = {}, items = items, fromQueue = fromQueue }
	local xml = tfm.get.room.xmlMapInfo.xml:upper()
	local hasSpecialAttrs = false

	for _, attr in next, attributes do
		if xml:find(attr) then
			hasSpecialAttrs = true
			break
		end
	end

	-- Handle special map attributes
	local dom = parseXml(xml, true)
	local P = path(dom, "P")[1]
	if hasSpecialAttrs then

		mapProps.allowed = P.attribute.ALLOWED
		mapProps.restricted = P.attribute.RESTRICT

		local mapFailback = function(err)
			tfm.exec.chatMessage(translate("MAP_ERROR", tfm.get.room.community, nil, { reason = err}))
			newRoundStarted = false
			Timer("newRound", newRound, 3 * 1000)
			tfm.exec.setGameTime(4, true)
		end

		if mapProps.allowed then
			mapProps.allowed = stringutils.split(mapProps.allowed, ",")
			mapProps.items = table.map(mapProps.allowed, tonumber)
		end
		if mapProps.restricted then
			mapProps.restricted = table.map(stringutils.split(mapProps.restricted, ","), tonumber)
			if table.find(mapProps.restricted, 17) then return mapFailback("Item 17 cannot be a restricted item") end
			for _, item in next, mapProps.restricted do
				table.remove(mapProps.items, table.find(mapProps.items, item))
			end
		end
		for z, ground in ipairs(path(dom, "Z", "S", "S")) do
			if ground.attribute.GREY ~= nil and ground.attribute.O == "323232" then
				local t, x, y, w, h = tonumber(ground.attribute.T), tonumber(ground.attribute.X), tonumber(ground.attribute.Y), tonumber(ground.attribute.L), tonumber(ground.attribute.H)
				local props = stringutils.split(ground.attribute.P, ",")
				mapProps.grey[#mapProps.grey + 1] = { t = t, x = x, y = y, w = w, h = h, a = props[5] }
			end
		end
		if #mapProps.grey > 0 then tfm.exec.chatMessage(translate("GREY_MAP", tfm.get.room.language)) end

		if fromQueue then
			tfm.exec.chatMessage(translate("LIST_MAP_PROPS", tfm.get.room.language, nil, {
				code = tfm.get.room.xmlMapInfo.mapCode,
				author = tfm.get.room.xmlMapInfo.author,
				items = table.concat(mapProps.items or {"-"}, ", "),
				allowed = table.concat(mapProps.allowed or {"-"}, ", "),
				restricted = table.concat(mapProps.restricted or {"-"}, ", "),
				grey = tostring(#mapProps.grey > 0)
			}))
		end

	end

	-- other visual tasks
	local changeItemTimer = Timer._timers["changeItem"]
	if changeItemTimer then
		changeItemTimer:setArgs(mapProps.items)
		changeItemTimer:call()
		changeItemTimer:reset()
	end

	ui.setMapName(translate(statsEnabled and "STATS_ENABLED" or "STATS_DISABLED", tfm.get.room.community, nil, {
		author = tfm.get.room.xmlMapInfo.author,
		code = tfm.get.room.xmlMapInfo.mapCode
	}))

	Timer("pre", function()
		Timer("count3", function(count3)
			tfm.exec.removeImage(count3)
			Timer("count2", function(count2)
				tfm.exec.removeImage(count2)
				Timer("count1", function(count1)
					tfm.exec.removeImage(count1)
					newRoundStarted = true
					Timer("roundStart", function(imageGo)
						tfm.exec.removeImage(imageGo)
					end, 1000, false, tfm.exec.addImage(assets.newRound, ":1", 145, -120))
				end, 1000, false, tfm.exec.addImage(assets.count1, ":1", 145, -120))
			end, 1000, false, tfm.exec.addImage(assets.count2, ":1", 145, -120))
		end, 1000, false, tfm.exec.addImage(assets.count3, ":1", 145, -120))
	end, Player.playerCount == 1 and 0 or 4000)

end
