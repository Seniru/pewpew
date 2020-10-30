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
            print(pack)
            if not shop.packs[pack] then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error:</b> Could not find the pack</R>") end
            if target.packs[pack] then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error: </b>Target already own that pack</R>") end
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
        print(pw)
        if (not pw) or pw == "" then tfm.exec.chatMessage("<N>[</N><ROSE>•</ROSE><N>] Removed the password!", author)
        else tfm.exec.chatMessage(("<N>[</N><ROSE>•</ROSE><N>] Password: %s"):format(pw), author) end
    end

}
