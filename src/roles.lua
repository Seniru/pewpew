roles = {}

roles.list = BitList {
	"admin",
	"staff",
	"developer",
	"artist",
	"translator",
	"mapper"
}

roles.colors = {
	["admin"] = 0xFF5555,
	["staff"] = 0xF3D165,
	["developer"] = 0x7BC7F7,
	["artist"] = 0xFF69B4,
	["translator"] = 0xB69EFD,
	["mapper"] = 0x87DF87
}

roles.images = {
	["admin"] = "178598716f4.png",
	["staff"] = "17859a9985c.png",
	["developer"] = "17859b0531e.png",
	["artist"] = "17859ab0277.png",
	["translator"] = "17859b2cb23.png",
	["mapper"] = "17859b68e86.png"
}

roles.addRole = function(player, role)
	player.roles[role] = true
	player.highestRole = roles.getHighestRole(player)
	setNameColor(player.name)
	tfm.exec.chatMessage(translate("NEW_ROLE", tfm.get.room.community, nil, { player = player.name, role = role }))
	player:savePlayerData()
end

roles.removeRole = function(player, role)
	player.roles[role] = nil
	player.highestRole = roles.getHighestRole(player)
	tfm.exec.setNameColor(player.name, 0) -- set it to default color in case of all the colors are removed
	setNameColor(player.name)
	tfm.exec.chatMessage(translate("KICK_ROLE", tfm.get.room.community, nil, { player = player.name, role = role }))
	player:savePlayerData()
end

roles.getHighestRole = function(player)
	for i, rank in next, roles.list.featureArray do
		if player.roles[rank] then return rank end
	end
	return "default"
end
