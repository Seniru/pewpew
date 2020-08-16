--==[[ init ]]==--

tfm.exec.disableAutoNewGame()
tfm.exec.disableAutoScore()
tfm.exec.disableAutoShaman()
tfm.exec.disableAutoTimeLeft()

local maps = {521833, 401421, 541917, 541928, 541936, 541943, 527935, 559634, 559644, 888052, 878047, 885641, 770600, 770656, 772172, 891472, 589736, 589800, 589708, 900012, 901062, 754380, 901337, 901411, 892660, 907870, 910078, 1190467, 1252043, 1124380, 1016258, 1252299, 1255902, 1256808, 986790, 1285380, 1271249, 1255944, 1255983, 1085344, 1273114, 1276664, 1279258, 1286824, 1280135, 1280342, 1284861, 1287556, 1057753, 1196679, 1288489, 1292983, 1298164, 1298521, 1293189, 1296949, 1308378, 1311136, 1314419, 1314982, 1318248, 1312411, 1312589, 1312845, 1312933, 1313969, 1338762, 1339474, 1349878, 1297154, 644588, 1351237, 1354040, 1354375, 1362386, 1283234, 1370578, 1306592, 1360889, 1362753, 1408124, 1407949, 1407849, 1343986, 1408028, 1441370, 1443416, 1389255, 1427349, 1450527, 1424739, 869836, 1459902, 1392993, 1426457, 1542824, 1533474, 1561467, 1563534, 1566991, 1587241, 1416119, 1596270, 1601580, 1525751, 1582146, 1558167, 1420943, 1466487, 1642575, 1648013, 1646094, 1393097, 1643446, 1545219, 1583484, 1613092, 1627981, 1633374, 1633277, 1633251, 1585138, 1624034, 1616785, 1625916, 1667582, 1666996, 1675013, 1675316, 1531316, 1665413, 1681719, 1699880, 1688696, 623770, 1727243, 1531329, 1683915, 1689533, 1738601, 3756146}

local items = {
    1,  -- small box
    2,  -- large box
    3,  -- small plank
    4,  -- large plank
    6,  -- ball
    10, -- anvil
    23, -- bomb
    24, -- spirit
    28, -- blueBaloon
    32, -- rune
    34, -- snow ball
    35, -- cupid arrow
    39, -- apple
    40, -- sheep
    45, -- small ice plank
    46, -- small choco plank
    54, -- ice cube
    57, -- cloud
    59, -- bubble
    60, -- tiny plank
    62, -- stable rune
    65, -- puffer fish
    90  -- tombstone
}

local assets = {
    banner = "173f1aa1720.png",
    count1 = "173f211056a.png",
    count2 = "173f210937b.png",
    count3 = "173f210089f.png",
    newRound = "173f2113b5e.png"
}

local initialized, newRoundStarted, suddenDeath = false
local currentItem = 17 -- cannon


--==[[ libs ]]==--

string.format = function(s, tab) return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end)) end

string.split = function(s, delimiter)
    result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

table.tostring = function(tbl, depth)
    local res = "{"
    local prev = 0
    for k, v in next, tbl do
        if type(v) == "table" then
            if depth == nil or depth > 0 then
                res =
                    res ..
                    ((type(k) == "number" and prev and prev + 1 == k) and "" or k .. ": ") ..
                        table.tostring(v, depth and depth - 1 or nil) .. ", "
            else
                res = res .. k .. ":  {...}, "
            end
        else
            res = res .. ((type(k) == "number" and prev and prev + 1 == k) and "" or k .. ": ") .. tostring(v) .. ", "
        end
        prev = type(k) == "number" and k or nil
    end
    return res:sub(1, res:len() - 2) .. "}"
end

-- [[Timers4TFM]] --
local a={}a.__index=a;a._timers={}setmetatable(a,{__call=function(b,...)return b.new(...)end})function a.process()local c=os.time()local d={}for e,f in next,a._timers do if f.isAlive and f.mature<=c then f:call()if f.loop then f:reset()else f:kill()d[#d+1]=e end end end;for e,f in next,d do a._timers[f]=nil end end;function a.new(g,h,i,j,...)local self=setmetatable({},a)self.id=g;self.callback=h;self.timeout=i;self.isAlive=true;self.mature=os.time()+i;self.loop=j;self.args={...}a._timers[g]=self;return self end;function a:setCallback(k)self.callback=k end;function a:addTime(c)self.mature=self.mature+c end;function a:setLoop(j)self.loop=j end;function a:setArgs(...)self.args={...}end;function a:call()self.callback(table.unpack(self.args))end;function a:kill()self.isAlive=false end;function a:reset()self.mature=os.time()+self.timeout end;Timer=a

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

	system.bindKeyboard(name, 32, true, true) -- space
	system.bindKeyboard(name, 0, true, true) -- left / a
	system.bindKeyboard(name, 2, true, true) -- right / d
	system.bindKeyboard(name, 3, true, true) -- down / s

	Player.players[name] = self
	Player.playerCount = Player.playerCount + 1

    return self
end

function Player:refresh()
	self.alive = true
	self.inCooldown = false
	self:setLives(3)
	Player.alive[self.name] = self
	Player.aliveCount = Player.aliveCount + 1
end

function Player:setLives(lives)
	self.lives = lives
	tfm.exec.setPlayerScore(self.name, lives)
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


--==[[ translations ]]==--

local translations = {}

translations["en"] = {	
	LIVES_LEFT =	"<ROSE>You have <N>${lives} <ROSE>lives left. <VI>Respawning in 3...",	
	LOST_ALL =	"<ROSE>You have lost all your lives!",	
	SD =		"<VP>Sudden death! Everyone has <N>1 <VP>life left",	
	WELCOME =	"<VP>Welcome to pewpew, <N>duck <VP>or <N>spacebar <VP>to shoot items!",	
	SOLE =		"<ROSE>${player} is the sole survivor!"
}

translations["br"] = {        
	LIVES_LEFT =    "<ROSE>Você possuí<N>${lives} <ROSE>vidas restantes. <VI>Renascendo em 3...",        
	LOST_ALL =      "<ROSE>Você perdeu todas as suas vidas!",        
	SD =            "<VP>Morte Súbita! Todos agora possuem <N>1 <VP>vida restante",        
	WELCOME =       "<VP>Bem vindo ao pewpew, <N>use a seta para baixo <VP>ou <N> a barra de espaço <VP>para atirar itens!",        
	SOLE =          "<ROSE>${player} é o último sobrevivente!"
}

translations["es"] = {        
	LIVES_LEFT =    "<ROSE>Te quedan <N>${lives} <ROSE>vidas restantes. <VI>Renaciendo en 3...",        
	LOST_ALL =      "<ROSE>¡Has perdido todas tus vidas!",        
	SD =            "<VP>¡Muerte súbita! A todos le quedan <N>1 <VP>vida restante",        
	WELCOME =       "<VP>¡Bienvenido a pewpew, <N>agáchate <VP>o presiona <N>la barra de espacio <VP>para disparar ítems!",        
	SOLE =          "<ROSE>¡${player} es el único superviviente!"
}

translations["fr"] = {        
	LIVES_LEFT =    "<ROSE>Il te reste <N>${lives} <ROSE>vies. <VI>Réapparition dans 3...",        
	LOST_ALL =      "<ROSE>Tu as perdu toutes tes vies !",        
	SD =            "<VP>Mort subite ! Il ne reste plus qu'<N>1 <VP>vie à tout le monde",        
	WELCOME =       "<VP>Bienvenue sur pewpew, <N>baisse toi <VP>ou utilise <N>la barre d'espace <VP>pour tirer des objets !",        
	SOLE =          "<ROSE>${player} est le seul survivant !"
}

translations["tr"] = {        
	LIVES_LEFT =    "<N>${lives} <ROSE> can?n?z kald?. <VI>3 saniye içinde yeniden do?acaks?n?z...",        
	LOST_ALL =      "<ROSE>Bütün can?n?z? kaybettiniz!",        
	SD =            "<VP>Ani ölüm! Art?k herkesin <N>1<VP> can? kald?",        
	WELCOME =       "<VP>pewpew odas?na ho?geldiniz, e?yalar f?rlatmak için <N>e?ilin <VP>ya da <N>spacebar <VP>'a bas?n!",        
	SOLE =          "<ROSE>Ya?ayan ki?i ${player}!"
}

local translate = function(term, lang, page, kwargs)
    local translation
    if translations[lang] then 
        translation = translations[lang][term] or translations.en[term] 
    else
        translation = translations.en[term]
    end
    translation = page and translation[page] or translation
    if not translation then return end
    return string.format(translation, kwargs)
end


--==[[ events ]]==--

function eventNewPlayer(name)
    local player = Player.new(name)
    tfm.exec.chatMessage(translate("WELCOME", player.community), name)   
    Timer("banner_" .. name, function(image)
        tfm.exec.removeImage(image)
    end, 5000, false, tfm.exec.addImage(assets.banner, ":1", 120, -85, name))
end

function eventLoop(tc, tr)
	
	Timer.process()

	if tr < 0 and initialized then
		if not suddenDeath then			
			suddenDeath = true		
			tfm.exec.chatMessage(translate("SD", tfm.get.room.community))
			for name, player in next, Player.alive do
				player:setLives(1)
			end
			tfm.exec.setGameTime(30, true)
		else
			local aliveCount = Player.aliveCount
			if aliveCount > 1 then
				local winnerString = ""
				for name in next, Player.alive do
					if aliveCount == 1 then
						winnerString = winnerString:sub(1, -3) .. " and " .. name
						break
					end
					winnerString = winnerString .. name .. ", "
					aliveCount = aliveCount - 1			
				end
				tfm.exec.chatMessage("we have some loads of winners this time: " .. winnerString)
			end
			tfm.exec.chatMessage("starting a new round")
			Timer("newRound", newRound, 3 * 1000)
			tfm.exec.setGameTime(4, true)
		end
	end

end
function eventKeyboard(name, key, down, x, y)
	if key == 32 or key == 3 then -- space / duck
		Player.players[name]:shoot(x, y)
	elseif key == 0 then-- left
		Player.players[name].stance = -1
	elseif key == 2 then-- right
		Player.players[name].stance = 1
	end	
end

function eventNewGame()
	if initialized then
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
end
function eventPlayerDied(name)
	local player = Player.players[name]
	player:setLives(player.lives - 1)
	player.alive = false

	if player.lives == 0 then
		
		Player.alive[name] = nil
		tfm.exec.chatMessage(translate("LOST_ALL", player.community), name)
		Player.aliveCount = Player.aliveCount - 1
		
		if Player.aliveCount == 1 then
			local winner = next(Player.alive)
			tfm.exec.chatMessage(translate("SOLE", tfm.get.room.community, nil, {player = winner}))
			tfm.exec.giveCheese(winner)
			tfm.exec.playerVictory(winner)					
			Timer("newRound", newRound, 3 * 1000)
		end
		
		
	else

		tfm.exec.chatMessage(translate("LIVES_LEFT", player.community, nil, {lives = player.lives}), name)
		Timer("respawn_" .. name, function()
			tfm.exec.respawnPlayer(name)
			player.alive = true
		end, 3000, false)

	end
end


--==[[ main ]]==--

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
    print("got in here")
    if not initialized then
        initialized = true
        Timer("changeItem", function()
            if math.random(1, 3) == 3 then
                currentItem = 17 -- cannon
            else
                currentItem = items[math.random(1, #items)]
            end
        end, 10000, true)
    end    
        
    newRoundStarted = false
    suddenDeath = false
    currentMapIndex = next(rotation, currentMapIndex)
    
    Player.alive = {}
    Player.aliveCount = 0
    for name, player in next, Player.players do player:refresh() end
    
    tfm.exec.newGame(rotation[currentMapIndex])
    tfm.exec.setGameTime(93, true)

    if currentMapIndex >= #rotation then
        rotation = shuffleMaps(maps)
        currentMapIndex = 1
    end
end

getPos = function(item, stance)
	if item == 17 then		
		return { x = stance == -1 and 10 or -10, y = 18 }	
	elseif item == 24 then		
		return { x = 0, y = 10 }	
	else		
		return { x = stance == -1 and -10 or 10, y = 0 }	
	end
end

getRot = function(item, stance)	
	if item == 32 or item == 35 or item == 62 then
		return stance == -1 and 180 or 0	
	elseif item == 17 then
		return stance == -1 and -90 or 90
	else
		return 0	
	end
end

do
    rotation = shuffleMaps(maps)
    currentMapIndex = 1
    Timer("newRound", newRound, 6 * 1000)
    tfm.exec.newGame(rotation[currentMapIndex])
    tfm.exec.setGameTime(8)
    for name in next, tfm.get.room.playerList do
        eventNewPlayer(name)
    end
end



