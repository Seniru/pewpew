local Player = {}

Player.players = {}
Player.alive = {}
Player.playerCount = 0
Player.aliveCount = 0

Player.__index = Player
Player.__tostring = function(self)
	return table.tostring(self)
end

setmetatable(Player, {
	__call = function (cls, name)
		return cls.new(name)
	end,
})

function Player.new(name)
	local self = setmetatable({}, Player)

	self.name = name
	self.alive = false
	self.lives = 0
	self.inCooldown = true
	self.community = tfm.get.room.playerList[name].language
	self.hearts = {}

	self.rounds = 0
	self.survived = 0
	self.won = 0
	self.score = 0
	self.points = 0
	self.packs = 1
	self.packsArray = {}
	self.equipped = 1
	self.roles = {}
	self.isSpecMode = false
	self._dataSafeLoaded = false

	self.tempEquipped = nil
	self.openedWindow = nil
	self.version = "v0.0.0.0"

	for key, code in next, keys do system.bindKeyboard(name, code, true, true) end

	Player.players[name] = self
	Player.playerCount = Player.playerCount + 1

	return self
end

function Player:refresh()
	self.alive = true
	self.inCooldown = false
	self:setLives(3)
	if not Player.alive[self.name] then
		Player.alive[self.name] = self
		Player.aliveCount = Player.aliveCount + 1
	end
	setNameColor(self.name)
	self.tempEquipped = nil
end

function Player:setLives(lives)
	self.lives = lives
	tfm.exec.setPlayerScore(self.name, lives)
	for _, id in next, self.hearts do tfm.exec.removeImage(id) end
	self.hearts = {}
	local heartCount = 0
	while heartCount < lives do
		heartCount = heartCount + 1
		self.hearts[heartCount] = tfm.exec.addImage(assets.heart, "$" .. self.name, -45 + heartCount * 15, -45)
	end
end

function Player:shoot(x, y)
	if newRoundStarted and self.alive and (not(self.isSpecMode and not specWaitingList[self.name])) and (not self.inCooldown) then
		if self.equipped == "Random" and not self.tempEquipped then
			self.tempEquipped = #self.packsArray == 0 and "Default" or self.packsArray[math.random(#self.packsArray)]
		end

		self.inCooldown = true

		local stance = self.stance
		local pos = getPos(currentItem, stance)
		local rot = getRot(currentItem, stance)
		local xSpeed = currentItem == 34 and 60 or 40

		local object = tfm.exec.addShamanObject(
			currentItem,
			x + pos.x,
			y + pos.y,
			rot,
			stance == -1 and -xSpeed or xSpeed,
			0,
			currentItem == 32 or currentItem == 62
		)

		local equippedPackName = self.tempEquipped or self.equipped
		local equippedPack = shop.packs[equippedPackName]
		local skin = equippedPack.skins[currentItem]
		if (equippedPackName ~= "Default" and equippedPackName ~= "Random") and skin and skin.image then
			tfm.exec.addImage(
				skin.image,
				"#" .. object,
				skin.adj.x,
				skin.adj.y
			)
		end

		Timer("shootCooldown_" .. self.name, function(object)
			tfm.exec.removeObject(object)
			self.inCooldown = false
		end, 1500, false, object)

	end
end

function Player:die()

	self.lives = 0
	self.alive = false
	tfm.exec.chatMessage(translate("LOST_ALL", self.community), self.name)

	if statsEnabled then
		self.rounds = self.rounds + 1
		self:savePlayerData()
	end

	if Player.alive[self.name] then
		Player.alive[self.name] = nil
		Player.aliveCount = Player.aliveCount - 1
	end

	if Player.aliveCount == 1 then

		local winner = next(Player.alive)
		local winnerPlayer = Player.players[winner]
		local n, t = extractName(winner)
		tfm.exec.chatMessage(translate("SOLE", tfm.get.room.language, nil, {player = "<b><VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font></b>"}))
		tfm.exec.giveCheese(winner)
		tfm.exec.playerVictory(winner)

		if statsEnabled then
			winnerPlayer.rounds = winnerPlayer.rounds + 1
			winnerPlayer.survived = winnerPlayer.survived + 1
			winnerPlayer.won = winnerPlayer.won + 1
			winnerPlayer.points = winnerPlayer.points + 5
			winnerPlayer:savePlayerData()
		end

		Timer("newRound", newRound, 3 * 1000)
	elseif Player.aliveCount == 0  then
		Timer("newRound", newRound, 3 * 1000)
	end

end

function Player:toggleSpectator()
	self.isSpecMode = not self.isSpecMode
	tfm.exec.chatMessage(translate(self.isSpecMode and "SPEC_MODE_ON" or "SPEC_MODE_OFF", self.community), self.name)
	if Player.aliveCount == 0 and not self.isSpecMode then
		suddenDeath = true
		tfm.exec.setGameTime(3, true)
	end
end

function Player:hasRole(role)
	return not not self.roles[role]
end

function Player:savePlayerData()
	-- if tfm.get.room.uniquePlayers < MIN_PLAYERS then return end
	if not self._dataSafeLoaded then return end
	local name = self.name
	dHandler:set(name, "rounds", self.rounds)
	dHandler:set(name, "survived", self.survived)
	dHandler:set(name, "won", self.won)
	dHandler:set(name, "points", self.points)
	dHandler:set(name, "packs", shop.packsBitList:encode(self.packs))
	dHandler:set(name, "equipped", self.equipped == "Random" and -1 or shop.packsBitList:find(self.equipped))
	dHandler:set(name, "roles", roles.list:encode(self.roles))
	dHandler:set(name, "version", self.version)
	system.savePlayerData(name, "v2" .. dHandler:dumpPlayer(name))
end
