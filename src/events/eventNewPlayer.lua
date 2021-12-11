function eventNewPlayer(name)
	local player = Player.new(name)
	tfm.exec.chatMessage(translate("WELCOME", player.community), name)
	tfm.exec.chatMessage("<N>Discord server:</N> <VI><b><i>https://discord.gg/vaqgrgp</i></b></VI>", name)
	Timer("banner_" .. name, function(image)
		tfm.exec.removeImage(image)
	end, 5000, false, tfm.exec.addImage(assets.banner, ":1", 120, -85, name))
	player._dataSafeLoaded = system.loadPlayerData(name)
	if not player._dataSafeLoaded then
		tfm.exec.chatMessage(translate("DATA_LOAD_ERROR", player.community), name)
	end
	setNameColor(name)
end
