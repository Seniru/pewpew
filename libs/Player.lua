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
	self.community = tfm.get.room.playerList[name].community
	self.hearts = {}

	self.rounds = 0
	self.survived = 0
	self.won = 0
    self.score = 0
    
    self.openedWindow = nil
    
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
	if newRoundStarted and self.alive and not self.inCooldown then
		
		self.inCooldown = true

		local stance = self.stance
		local pos = getPos(currentItem, stance)
		local rot = getRot(currentItem, stance)
		local xSpeed = currentItem == 34 and 60 or 40

		Timer("shootCooldown_" .. self.name, function(object)
			tfm.exec.removeObject(object)
			self.inCooldown = false
		end, 1500, false, tfm.exec.addShamanObject(
			currentItem,
			x + pos.x,
			y + pos.y,
			rot,
			stance == -1 and -xSpeed or xSpeed,
			0,
			currentItem == 32 or currentItem == 62
		))

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
		tfm.exec.chatMessage(translate("SOLE", tfm.get.room.community, nil, {player = "<b><VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font></b>"}))
		tfm.exec.giveCheese(winner)
        tfm.exec.playerVictory(winner)
        
        if statsEnabled then
		    winnerPlayer.rounds = winnerPlayer.rounds + 1
		    winnerPlayer.survived = winnerPlayer.survived + 1
		    winnerPlayer.won = winnerPlayer.won + 1
            winnerPlayer:savePlayerData()	
        end

		Timer("newRound", newRound, 3 * 1000)
	elseif Player.aliveCount == 0  then
		Timer("newRound", newRound, 3 * 1000)
	end
        
end

function Player:savePlayerData()
	if tfm.get.room.uniquePlayers < 4 then return end
	local name = self.name
    dHandler:set(name, "rounds", self.rounds)
    dHandler:set(name, "survived", self.survived)
	dHandler:set(name, "won", self.won)
    system.savePlayerData(name, "v2" .. dHandler:dumpPlayer(name))
end
