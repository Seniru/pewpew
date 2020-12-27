roles = {}

roles.list = BitList {
    "admin",
    "mod",
    "developer",
    "artist",
    "translator",
    "mapper"
}

roles.colors = {
    ["admin"] = 0xff5555,
    ["mod"] = 0xe49a5e,
    ["developer"] = 0x6fa9de,
    ["artist"] = 0xad7ec2,
    ["translator"] = 0xe47871,
    ["mapper"] = 0x1c9043
}

roles.addRole = function(player, role)
    player.roles[role] = true
    player.highestRole = roles.getHighestRole(player)
    setNameColor(player.name)
    player:savePlayerData()
end

roles.removeRole = function(player, role)
    player.roles[role] = nil
    player.highestRole = roles.getHighestRole(player)
    tfm.exec.setNameColor(player.name, 0) -- set it to default color in case of all the colors are removed
    setNameColor(player.name)
    player:savePlayerData()
end

roles.getHighestRole = function(player)
    for i, rank in next, roles.list.featureArray do
        if player.roles[rank] then return rank end
    end
    return "default"
end
