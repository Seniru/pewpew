cmds = {

		["profile"] = function(args, msg, author)
			local player = Player.players[args[1] or author] or Player.players[author]
			displayProfile(player, author)
		end,

		["help"] = function(args, msg, author)
			displayHelp(author)
		end,

		["shop"] = function(args, msg, author)
			shop.displayShop(author, 1)
		end,

		["changelog"] = function(args, msg, author)
			displayChangelog(author)
		end,

		-- [[ administration commands ]]

		["give"] = function(args, msg, author)

			if not admins[author] then return end

			local FORMAT_ERR_MSG = "<N>[</N><R>•</R><N>] <R><b>Error in command<br>\tUsage:</b><font face='Lucida console'> !give <i>[points|pack] [target] [value]</i></font></R>"
			local TARGET_UNREACHABLE_ERR = "<N>[</N><R>•</R><N>] <R><b>Error: Target unreachable!</b></R>"

			if (not args[1]) or (not args[2]) or (not args[3]) then return tfm.exec.chatMessage(FORMAT_ERR_MSG, author) end

			local target = Player.players[args[2]]
			local n, t = extractName(author)

			if args[1] == "points" then
				if not target then return tfm.exec.chatMessage(TARGET_UNREACHABLE_ERR, author) end
				local points = tonumber(args[3])
				if not points then return tfm.exec.chatMessage(FORMAT_ERR_MSG, author) end -- NaN
				target.points = target.points + points
				target:savePlayerData()
				print(("[GIFT] %s has been rewarded with %s by %s"):format(args[2], points .. " Pts.", author))
				tfm.exec.chatMessage(("<N>[</N><ROSE>•</ROSE><N>] Rewarded <ROSE>%s</ROSE> with <ROSE>%s</ROSE> points"):format(args[2], points), author)
				tfm.exec.chatMessage(translate("GIFT_RECV", target.community, nil, {
					admin = "<VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font>",
					gift = points .. " Pts."
				}), args[2])
			elseif args[1] == "pack" then
				if not target then return tfm.exec.chatMessage(TARGET_UNREACHABLE_ERR, author) end
				local pack = msg:match("give pack .+#%d+ (.+)")
				if not shop.packs[pack] then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error:</b> Could not find the pack</R>", author) end
				if target.packs[pack] then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error: </b>Target already own that pack</R>", author) end
				target.packs[pack] = true
				target:savePlayerData()
				print(("[GIFT] %s has been rewarded with %s by %s"):format(args[2], pack, author))
				tfm.exec.chatMessage(("<N>[</N><ROSE>•</ROSE><N>] Rewarded <ROSE>%s</ROSE> with <ROSE>%s</ROSE>"):format(args[2], pack), author)
				tfm.exec.chatMessage(translate("GIFT_RECV", target.community, nil, {
					admin = "<VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font>",
					gift = pack
				}), args[2])
			else
				tfm.exec.chatMessage(FORMAT_ERR_MSG, author)
			end

		end,

		["pw"] = function(args, msg, author)
			if not admins[author] then return end
			local pw = msg:match("^pw (.+)")
			tfm.exec.setRoomPassword(pw)
			if (not pw) or pw == "" then tfm.exec.chatMessage("<N>[</N><ROSE>•</ROSE><N>] Removed the password!", author)
			else tfm.exec.chatMessage(("<N>[</N><ROSE>•</ROSE><N>] Password: %s"):format(pw), author) end
		end,

		["setrole"] = function(args, msg, author)
			if not admins[author] then return end
			if not (args[1] or args[2]) then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error in command<br>\tUsage:</b><font face='Lucida console'> !setrole <i> [target] [role]</i></font>\n\tAvailable roles - <font face='Lucida Console'>admin, staff, developer, artist, translator, mapper</font></R>", author) end
			local target = Player.players[args[1]]
			if not target then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error: Target unreachable!</b></R>", author) end
			if not roles.list:find(args[2]) then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error:</b> Could not find the role</R>", author) end
			roles.addRole(target, args[2])
		end,

		["remrole"] = function(args, msg, author)
			if not admins[author] then return end
			if not (args[1] or args[2]) then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error in command<br>\tUsage:</b><font face='Lucida console'> !remrole <i> [target] [role]</i></font>\n\tAvailable roles - <font face='Lucida Console'>admin, staff, developer, artist, translator, mapper</font></R>", author) end
			local target = Player.players[args[1]]
			if not target then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error: Target unreachable!</b></R>", author) end
			if not roles.list:find(args[2]) then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error:</b> Could not find the role</R>", author) end
			roles.removeRole(target, args[2])
		end,

		["maps"] = function(args, msg, author)
			local player = Player.players[author]
			if not (admins[author] or (player:hasRole("staff") and player:hasRole("mapper"))) then return end
			local res = "<b><BV>Current rotation:</BV></b> "
			for index, map in next, rotation do
				if index == currentMapIndex then
					print("index is currentmaps")
					res = res .. "<b><VP> &lt; @" .. map .. " &gt; </VP></b>, "
				else
					print("not")
					res = res .. "@" .. map .. ", "
				end
				if #res > 980 then
					tfm.exec.chatMessage(res, author)
					res = ""
				end
			end
			if #res > 0 then tfm.exec.chatMessage(res:sub(1, -2), author) end
			tfm.exec.chatMessage("<b><BV>Queued maps:</BV></b> " .. (#queuedMaps > 0 and table.concat(queuedMaps, ", @") or "-"), author)
		end,

		["npp"] = function(args, msg, author)
			local target = Player.players[author]

			if not isTribeHouse then
				if not (admins[author] or (player:hasRole("staff") and player:hasRole("mapper"))) then
					return tfm.exec.chatMessage(translate("ERR_PERMS", target.community))
				end
			else
				if tfm.get.room.name:sub(2) ~= tfm.get.room.playerList[author].tribeName then
					return tfm.exec.chatMessage(translate("ERR_PERMS", target.community))
				end
			end

			local map = args[1]:match("@?(%d+)")
			if not map then return translate("ERR_CMD", target.community, nil, { syntax = "!npp [@code]"}) end
			queuedMaps[#queuedMaps+1] = map
			tfm.exec.chatMessage(translate("MAP_QUEUED", tfm.get.room.community, nil, { map = map, player = author }))
		end

}

-- [[ aliases ]]
cmds["p"] = cmds["profile"]
