--==[[ libs ]]==--

local stringutils = {}
stringutils.format = function(s, tab) return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end)) end

stringutils.split = function(s, delimiter)
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

local prettyify

do

	local typeLookup = {
		["string"] = function(obj) return ("<VP>\"%s\"</VP>"):format(obj) end,
		["number"] = function(obj) return ("<J>%s</J>"):format(obj) end,
		["boolean"] = function(obj) return ("<J>%s</J>"):format(obj) end,
		["function"] = function(obj) return ("<b><V>%s</V></b>"):format(obj) end,
		["nil"] = function() return ("<G>nil</G>") end
	}

	local string_repeat = function(str, times)
		local res = ""
		while times > 0 do
			res = res .. str
			times = times - 1
		end
		return res
	end

	prettify = function(obj, depth, opt)

		opt = opt or {}
		opt.maxDepth = opt.maxDepth or 30
		opt.truncateAt = opt.truncateAt or 30

		local prettifyFn = typeLookup[type(obj)]
		if (prettifyFn) then return { res = (prettifyFn(tostring(obj))), count = 1 } end -- not the type of object ({}, [])

		if depth >= opt.maxDepth then
			return {
				res = ("<b><V>%s</V></b>"):format(tostring(obj)),
				count = 1
			}
		end

		local kvPairs = {}
		local totalObjects = 0
		local length = 0
		local shouldTruncate = false

		local previousKey = 0

		for key, value in next, obj do

			if not shouldTruncate then

				local tn = tonumber(key)
				key = tn and (((previousKey and tn - previousKey == 1) and "" or "[" .. key .. "]:")) or (key .. ":")
				-- we only need to check if the previous key is a number, so a nil key doesn't matter
				previousKey = tn
				local prettified = prettify(value, depth + 1, opt)
				kvPairs[#kvPairs + 1] = key .. " " .. prettified.res

				totalObjects = totalObjects + prettified.count
				if length >= opt.truncateAt then shouldTruncate = true end
			end

			length = length + 1

		end

		if shouldTruncate then kvPairs[#kvPairs] = (" <G><i>... %s more values</i></G>"):format(length - opt.truncateAt) end

		if totalObjects < 6 then
			return { res = "<N>{ " .. table.concat(kvPairs, ", ") .. " }</N>", count = totalObjects }
		else
			return { res = "<N>{ " .. table.concat(kvPairs, ",\n  " .. string_repeat("  ", depth)) .. " }</N>", count = totalObjects }
		end

	end

end

local prettyprint = function(obj, opt) print(prettify(obj, 0, opt or {}).res) end
local p = prettyprint

-- Thanks to Turkitutu
-- https://pastebin.com/raw/Nw3y1A42

bit = {}

bit.lshift = function(x, by) -- Left-shift of x by n bits
	return x * 2 ^ by
end

bit.rshift = function(x, by) -- Logical right-shift of x by n bits
	return math.floor(x / 2 ^ by)
end

bit.band = function(a, b) -- bitwise and of x1, x2
	local p, c = 1, 0
	while a > 0 and b > 0 do
		local ra, rb = a % 2, b % 2
		if ra + rb > 1 then
			c = c + p
		end
		a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
	end
	return c
end

bit.bxor = function(a,b) -- Bitwise xor of x1, x2
	local r = 0
	for i = 0, 31 do
		local x = a / 2 + b / 2
		if x ~= math.floor(x) then
			r = r + 2^i
		end
		a = math.floor(a / 2)
		b = math.floor(b / 2)
	end
	return r
end

bit.bor = function(a,b) -- Bitwise or of x1, x2
	local p, c= 1, 0
	while a+b > 0 do
		local ra, rb = a % 2, b % 2
		if ra + rb > 0 then
			c = c + p
		end
		a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
	end
	return c
end

bit.bnot = function(n) -- Bitwise not of x
	local p, c = 1, 0
	while n > 0 do
		local r = n % 2
		if r < 0 then
			c = c + p
		end
		n, p = (n - r) / 2, p * 2
	end
	return c
end

local BitList = {}

BitList.__index = BitList
setmetatable(BitList, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

do

	function BitList.new(features)
		local self = setmetatable({}, BitList)
		self.featureArray = features

		self.featureKeys = {}

		for k, v in next, features do
			self.featureKeys[v] = k
		end

		self.features = #self.featureArray

		return self
	end

	function BitList:encode(featTbl)
		local res = 0
		for k, v in next, featTbl do
			if v and self.featureKeys[k] then
				res = bit.bor(res, bit.lshift(1, self.featureKeys[k] - 1))
			end
		end
		return res
	end

	function BitList:decode(featInt)
		local features, index = {}, 1
		while (featInt > 0) do
			feat = bit.band(featInt, 1) == 1
			corrFeat = self.featureArray[index]
			features[corrFeat] = feat
			featInt = bit.rshift(featInt, 1)
			index = index + 1
		end
		return features
	end

	function BitList:get(index)
		return self.featureArray[index]
	end

	function BitList:find(feature)
		return self.featureKeys[feature]
	end

end

local Panel = {}
local Image = {}

do


	local string_split = function(s, delimiter)
		result = {}
		for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
			table.insert(result, match)
		end
		return result
	end

	local table_tostring

	table_tostring = function(tbl, depth)
		local res = "{"
		local prev = 0
		for k, v in next, tbl do
			if type(v) == "table" then
				if depth == nil or depth > 0 then
					res =
						res ..
						((type(k) == "number" and prev and prev + 1 == k) and "" or k .. ": ") ..
						table_tostring(v, depth and depth - 1 or nil) .. ", "
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

	local table_copy = function(tbl)
		local res = {}
		for k, v in next, tbl do res[k] = v end
		return res
	end



	-- [[ class Image ]] --

	Image.__index = Image
	Image.__tostring = function(self) return table_tostring(self) end

	Image.images = {}

	setmetatable(Image, {
		__call = function(cls, ...)
			return cls.new(...)
		end
	})

	function Image.new(imageId, target, x, y, parent)

		local self = setmetatable({
			id = #Image.images + 1,
			imageId = imageId,
			target = target,
			x = x,
			y = y,
			instances = {},
		}, Image)

		Image.images[self.id] = self

		return self

	end

	function Image:show(target)
		if target == nil then error("Target cannot be nil") end
		if self.instances[target] then return self end
		self.instances[target] = tfm.exec.addImage(self.imageId, self.target, self.x, self.y, target)
		return self
	end

	function Image:hide(target)
		if target == nil then error("Target cannot be nil") end
		if not self.instances[target] then return end
		tfm.exec.removeImage(self.instances[target])
		self.instances[target] = nil
		return self
	end

	-- [[ class Panel ]] --

	Panel.__index = Panel
	Panel.__tostring = function(self) return table_tostring(self) end

	Panel.panels = {}

	setmetatable(Panel, {
		__call = function (cls, ...)
			return cls.new(...)
		end,
	})

	function Panel.new(id, text, x, y, w, h, background, border, opacity, fixed, hidden)

		local self = setmetatable({
			id = id,
			text = text,
			x = x,
			y = y,
			w = w,
			h = h,
			background = background,
			border = border,
			opacity = opacity,
			fixed = fixed,
			hidden = hidden,
			isCloseButton = false,
			closeTarget = nil,
			parent = nil,
			onhide = nil,
			onclick = nil,
			children = {},
			temporary = {}
		}, Panel)

		Panel.panels[id] = self

		return self

	end

	function Panel.handleActions(id, name, event)
		local panelId = id - 10000
		local panel = Panel.panels[panelId]
		if not panel then return end
		if panel.isCloseButton then
			if not panel.closeTarget then return end
			panel.closeTarget:hide(name)
			if panel.onhide then panel.onhide(panelId, name, event) end
		else
			if panel.onclick then panel.onclick(panelId, name, event) end
		end
	end

	function Panel:show(target)
		ui.addTextArea(10000 + self.id, self.text, target, self.x, self.y, self.w, self.h, self.background, self.border, self.opacity, self.opacity)
		self.visible = true

		for name in next, (target and { [target] = true } or tfm.get.room.playerList) do
			for id, child in next, self.children do
				child:show(name)
			end
		end

		return self

	end

	function Panel:update(text, target)
		ui.updateTextArea(10000 + self.id, text, target)
		return self
	end

	function Panel:hide(target)

		ui.removeTextArea(10000 + self.id, target)

		for name in next, (target and { [target] = true } or tfm.get.room.playerList) do

			for id, child in next, self.children do
				child:hide(name)
			end

			if self.temporary[name] then
				for id, child in next, self.temporary[name] do
					child:hide(name)
				end
				self.temporary[name] = {}
			end

		end


		if self.onclose then self.onclose(target) end
		return self

	end

	function Panel:addPanel(panel)
		self.children[panel.id] = panel
		panel.parent = self.id
		return self
	end

	function Panel:addImage(image)
		self.children["i_" .. image.id] = image
		return self
	end

	function Panel:addPanelTemp(panel, target)
		if not self.temporary[target] then self.temporary[target] = {} end
		panel:show(target)
		self.temporary[target][panel.id] = panel
		return self
	end

	function Panel:addImageTemp(image, target)
		if not self.temporary[target] then self.temporary[target] = {} end
		image:show(target)
		self.temporary[target]["i_" .. image.id] = image
		return self
	end

	function Panel:setActionListener(fn)
		self.onclick = fn
		return self
	end

	function Panel:setCloseButton(id, callback)
		local button = Panel.panels[id]
		if not button then return self end
		self.closeTarget = button
		self.onclose = callback
		button.isCloseButton = true
		button.closeTarget = self
		return self
	end

end

-- [[Timers4TFM]] --
local a={}a.__index=a;a._timers={}setmetatable(a,{__call=function(b,...)return b.new(...)end})function a.process()local c=os.time()local d={}for e,f in next,a._timers do if f.isAlive and f.mature<=c then f:call()if f.loop then f:reset()else f:kill()d[#d+1]=e end end end;for e,f in next,d do a._timers[f]=nil end end;function a.new(g,h,i,j,...)local self=setmetatable({},a)self.id=g;self.callback=h;self.timeout=i;self.isAlive=true;self.mature=os.time()+i;self.loop=j;self.args={...}a._timers[g]=self;return self end;function a:setCallback(k)self.callback=k end;function a:addTime(c)self.mature=self.mature+c end;function a:setLoop(j)self.loop=j end;function a:setArgs(...)self.args={...}end;function a:call()self.callback(table.unpack(self.args))end;function a:kill()self.isAlive=false end;function a:reset()self.mature=os.time()+self.timeout end;Timer=a

--[[DataHandler v22]]
local a={}a.VERSION='1.5'a.__index=a;function a.new(b,c,d)local self=setmetatable({},a)assert(b,'Invalid module ID (nil)')assert(b~='','Invalid module ID (empty text)')assert(c,'Invalid skeleton (nil)')for e,f in next,c do f.type=f.type or type(f.default)end;self.players={}self.moduleID=b;self.moduleSkeleton=c;self.moduleIndexes={}self.otherOptions=d;self.otherData={}self.originalStuff={}for e,f in pairs(c)do self.moduleIndexes[f.index]=e end;if self.otherOptions then self.otherModuleIndexes={}for e,f in pairs(self.otherOptions)do self.otherModuleIndexes[e]={}for g,h in pairs(f)do h.type=h.type or type(h.default)self.otherModuleIndexes[e][h.index]=g end end end;return self end;function a.newPlayer(self,i,j)assert(i,'Invalid player name (nil)')assert(i~='','Invalid player name (empty text)')self.players[i]={}self.otherData[i]={}j=j or''local function k(l)local m={}for n in string.gsub(l,'%b{}',function(o)return o:gsub(',','\0')end):gmatch('[^,]+')do n=n:gsub('%z',',')if string.match(n,'^{.-}$')then table.insert(m,k(string.match(n,'^{(.-)}$')))else table.insert(m,tonumber(n)or n)end end;return m end;local function p(c,q)for e,f in pairs(c)do if f.index==q then return e end end;return 0 end;local function r(c)local s=0;for e,f in pairs(c)do if f.index>s then s=f.index end end;return s end;local function t(b,c,u,v)local w=1;local x=r(c)b="__"..b;if v then self.players[i][b]={}end;local function y(n,z,A,B)local C;if z=="number"then C=tonumber(n)or B elseif z=="string"then C=string.match(n and n:gsub('\\"','"')or'',"^\"(.-)\"$")or B elseif z=="table"then C=string.match(n or'',"^{(.-)}$")C=C and k(C)or B elseif z=="boolean"then if n then C=n=='1'else C=B end end;if v then self.players[i][b][A]=C else self.players[i][A]=C end end;if#u>0 then for n in string.gsub(u,'%b{}',function(o)return o:gsub(',','\0')end):gmatch('[^,]+')do n=n:gsub('%z',','):gsub('\9',',')local A=p(c,w)local z=c[A].type;local B=c[A].default;y(n,z,A,B)w=w+1 end end;if w<=x then for D=w,x do local A=p(c,D)local z=c[A].type;local B=c[A].default;y(nil,z,A,B)end end end;local E,F=self:getModuleData(j)self.originalStuff[i]=F;if not E[self.moduleID]then E[self.moduleID]='{}'end;t(self.moduleID,self.moduleSkeleton,E[self.moduleID]:sub(2,-2),false)if self.otherOptions then for b,c in pairs(self.otherOptions)do if not E[b]then local G={}for e,f in pairs(c)do local z=f.type or type(f.default)if z=='string'then G[f.index]='"'..tostring(f.default:gsub('"','\\"'))..'"'elseif z=='table'then G[f.index]='{}'elseif z=='number'then G[f.index]=f.default elseif z=='boolean'then G[f.index]=f.default and'1'or'0'end end;E[b]='{'..table.concat(G,',')..'}'end end end;for b,u in pairs(E)do if b~=self.moduleID then if self.otherOptions and self.otherOptions[b]then t(b,self.otherOptions[b],u:sub(2,-2),true)else self.otherData[i][b]=u end end end end;function a.dumpPlayer(self,i)local m={}local function H(I)local m={}for e,f in pairs(I)do local J=type(f)if J=='table'then m[#m+1]='{'m[#m+1]=H(f)if m[#m]:sub(-1)==','then m[#m]=m[#m]:sub(1,-2)end;m[#m+1]='}'m[#m+1]=','else if J=='string'then m[#m+1]='"'m[#m+1]=f:gsub('"','\\"')m[#m+1]='"'elseif J=='boolean'then m[#m+1]=f and'1'or'0'else m[#m+1]=f end;m[#m+1]=','end end;if m[#m]==','then m[#m]=''end;return table.concat(m)end;local function K(i,b)local m={b,'=','{'}local L=self.players[i]local M=self.moduleIndexes;local N=self.moduleSkeleton;if self.moduleID~=b then M=self.otherModuleIndexes[b]N=self.otherOptions[b]b='__'..b;L=self.players[i][b]end;if not L then return''end;for D=1,#M do local A=M[D]local z=N[A].type;if z=='string'then m[#m+1]='"'m[#m+1]=L[A]:gsub('"','\\"')m[#m+1]='"'elseif z=='number'then m[#m+1]=L[A]elseif z=='boolean'then m[#m+1]=L[A]and'1'or'0'elseif z=='table'then m[#m+1]='{'m[#m+1]=H(L[A])m[#m+1]='}'end;m[#m+1]=','end;if m[#m]==','then m[#m]='}'else m[#m+1]='}'end;return table.concat(m)end;m[#m+1]=K(i,self.moduleID)if self.otherOptions then for e,f in pairs(self.otherOptions)do local u=K(i,e)if u~=''then m[#m+1]=','m[#m+1]=u end end end;for e,f in pairs(self.otherData[i])do m[#m+1]=','m[#m+1]=e;m[#m+1]='='m[#m+1]=f end;return table.concat(m)..self.originalStuff[i]end;function a.get(self,i,A,O)if not O then return self.players[i][A]else assert(self.players[i]['__'..O],'Module data not available ('..O..')')return self.players[i]['__'..O][A]end end;function a.set(self,i,A,C,O)if O then self.players[i]['__'..O][A]=C else self.players[i][A]=C end;return self end;function a.save(self,i)system.savePlayerData(i,self:dumpPlayer(i))end;function a.removeModuleData(self,i,O)assert(O,"Invalid module name (nil)")assert(O~='',"Invalid module name (empty text)")assert(O~=self.moduleID,"Invalid module name (current module data structure)")if self.otherData[i][O]then self.otherData[i][O]=nil;return true else if self.otherOptions and self.otherOptions[O]then self.players[i]['__'..O]=nil;return true end end;return false end;function a.getModuleData(self,l)local m={}for b,u in string.gmatch(l,'([0-9A-Za-z_]+)=(%b{})')do local P=self:getTextBetweenQuotes(u:sub(2,-2))for D=1,#P do P[D]=P[D]:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]","%%%0")u=u:gsub(P[D],P[D]:gsub(',','\9'))end;m[b]=u end;for e,f in pairs(m)do l=l:gsub(e..'='..f:gsub('\9',','):gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]","%%%0")..',?','')end;return m,l end;function a.convertFromOld(self,Q,R)assert(Q,'Old data is nil')assert(R,'Old skeleton is nil')local function S(l,T)local m={}for U in string.gmatch(l,'[^'..T..']+')do m[#m+1]=U end;return m end;local E=S(Q,'?')local m={}for D=1,#E do local O=E[D]:match('([0-9a-zA-Z]+)=')local u=S(E[D]:gsub(O..'=',''):gsub(',,',',\8,'),',')local G={}for V=1,#u do if R[O][V]then if R[O][V]=='table'then G[#G+1]='{'if u[V]~='\8'then local I=S(u[V],'#')for W=1,#I do G[#G+1]=I[W]G[#G+1]=','end;if G[#G]==','then table.remove(G)end end;G[#G+1]='},'elseif R[O][V]=='string'then G[#G+1]='"'if u[V]~='\8'then G[#G+1]=u[V]end;G[#G+1]='"'G[#G+1]=','else if u[V]~='\8'then G[#G+1]=u[V]else G[#G+1]=0 end;G[#G+1]=','end end end;if G[#G]==','then table.remove(G)end;m[#m+1]=O;m[#m+1]='='m[#m+1]='{'m[#m+1]=table.concat(G)m[#m+1]='}'m[#m+1]=','end;if m[#m]==','then table.remove(m)end;return table.concat(m)end;function a.convertFromDataManager(self,Q,R)assert(Q,'Old data is nil')assert(R,'Old skeleton is nil')local function S(l,T)local m={}for U in string.gmatch(l,'[^'..T..']+')do m[#m+1]=U end;return m end;local E=S(Q,'§')local m={}for D=1,#E do local O=E[D]:match('%[(.-)%]')local u=S(E[D]:gsub('%['..O..'%]%((.-)%)','%1'),'#')local G={}for V=1,#u do if R[V]=='table'then local I=S(u[V],'&')G[#G+1]='{'for W=1,#I do if tonumber(I[W])then G[#G+1]=I[W]G[#G+1]=','else G[#G+1]='"'G[#G+1]=I[W]G[#G+1]='"'G[#G+1]=','end end;if G[#G]==','then table.remove(G)end;G[#G+1]='}'G[#G+1]=','else if R[V]=='string'then G[#G+1]='"'G[#G+1]=u[V]G[#G+1]='"'else G[#G+1]=u[V]end;G[#G+1]=','end end;if G[#G]==','then table.remove(G)end;m[#m+1]=O;m[#m+1]='='m[#m+1]='{'m[#m+1]=table.concat(G)m[#m+1]='}'end;return table.concat(m)end;function a.getTextBetweenQuotes(self,l)local m={}local X=1;local Y=0;local Z=false;for D=1,#l do local _=l:sub(D,D)if _=='"'then if l:sub(D-1,D-1)~='\\'then if Y==0 then X=D;Y=Y+1 else Y=Y-1;if Y==0 then m[#m+1]=l:sub(X,D)end end end end end;return m end;DataHandler=a


--==[[ init ]]==--

local VERSION = "v2.3.4.0"
local CHANGELOG =
	[[

<p align='center'><font size='20'><b><V>CHANGELOG</V></b></font> <BV><a href='event:log'>[View all]</a></BV></p><font size='12' face='Lucida Console'>

<font size='15' face='Lucida Console'><b><BV>v2.3.4.0</BV></b></font> <i>(7/26/2021)</i>
    • Added UR (urdu) translations (Thanks to Maha010#0000)
    • Changed the map rotation algorithm to play latest maps more frequent
    • Added an indicator for stats enabled/disabled
    • Fixed not showing all the credits for some languages


<font size='15' face='Lucida Console'><b><BV>v2.3.3.0</BV></b></font> <i>(6/12/2021)</i>
    • Fixed the bug that displays your badges instead of showing the target's badges
    • Added BR translations (Thanks to Santoex#0000)
    • Changed the font size of ratios in leaderboard to '9' as a temporary fix for text wrapping issuess


<font size='15' face='Lucida Console'><b><BV>v2.3.2.0</BV></b></font> <i>(3/27/2021)</i>
    • Added badges for the roles you have obtained!!!
    • Fixed bugs that caused the leaderboards from not loading properly due to the last update
    • Fixed some internal commands


<font size='15' face='Lucida Console'><b><BV>v2.3.1.0</BV></b></font> <i>(3/22/2021)</i>
    • Added !npp [@code] to queue maps - works only inside your tribe house
    • Major internal changes regarding map rotation


<font size='15' face='Lucida Console'><b><BV>v2.3.0.6</BV></b></font> <i>(2/19/2021)</i>
    • Fixed and updated FR translations (Thanks to Jaker#9310)
    • Added HU translations

    
<font size='15' face='Lucida Console'><b><BV>v2.3.0.5</BV></b></font> <i>(1/20/2021)</i>
    • Fixed and updated TR translations (Thanks to Star#6725)
    • Fixed the fonts in the changelog menu


<font size='15' face='Lucida Console'><b><BV>v2.3.0.4</BV></b></font> <i>(1/20/2021)</i>
    • Temporary fix for room crashing when changing name color (role system)


<font size='15' face='Lucida Console'><b><BV>v2.3.0.3</BV></b></font> <i>(1/19/2021)</i>
    • Added new maps


</font>
]]

tfm.exec.disableAutoNewGame()
tfm.exec.disableAutoScore()
tfm.exec.disableAutoShaman()
tfm.exec.disableAutoTimeLeft()
tfm.exec.disablePhysicalConsumables()

local admins = {
	["King_seniru#5890"] = true,
	["Lightymouse#0421"] = true,
	["Overforyou#9290"] = true
}

-- TEMP: Temporary fix to get rid of farmers and hackers
local banned = {
	["Sannntos#0000"] = true
}

maps = {
	list = { 521833, 401421, 541917, 541928, 541936, 541943, 527935, 559634, 559644 },
	dumpCache = "",
	overwriteFile = false
}

local ENUM_ITEMS = {
	SMALL_BOX = 		1,
	LARGE_BOX = 		2,
	SMALL_PLANK = 		3,
	LARGE_PLANK = 		4,
	BALL = 				6,
	ANVIL = 			10,
	CANNON =			17,
	BOMB = 				23,
	SPIRIT = 			24,
	BLUE_BALOON = 		28,
	RUNE = 				32,
	SNOWBALL = 			34,
	CUPID_ARROW = 		35,
	APPLE = 			39,
	SHEEP = 			40,
	SMALL_ICE_PLANK = 	45,
	SMALL_CHOCO_PLANK = 46,
	ICE_CUBE = 			54,
	CLOUD = 			57,
	BUBBLE = 			59,
	TINY_PLANK = 		60,
	STABLE_RUNE = 		62,
	PUFFER_FISH = 		65,
	TOMBSTONE = 		90
}

local items = {
	ENUM_ITEMS.SMALL_BOX,
	ENUM_ITEMS.LARGE_BOX,
	ENUM_ITEMS.SMALL_PLANK,
	ENUM_ITEMS.LARGE_PLANK,
	ENUM_ITEMS.BALL,
	ENUM_ITEMS.ANVIL,
	ENUM_ITEMS.BOMB,
	ENUM_ITEMS.SPIRIT,
	ENUM_ITEMS.BLUE_BALOON,
	ENUM_ITEMS.RUNE,
	ENUM_ITEMS.SNOWBALL,
	ENUM_ITEMS.CUPID_ARROW,
	ENUM_ITEMS.APPLE,
	ENUM_ITEMS.SHEEP,
	ENUM_ITEMS.SMALL_ICE_PLANK,
	ENUM_ITEMS.SMALL_CHOCO_PLANK,
	ENUM_ITEMS.ICE_CUBE,
	ENUM_ITEMS.CLOUD,
	ENUM_ITEMS.BUBBLE,
	ENUM_ITEMS.TINY_PLANK,
	ENUM_ITEMS.STABLE_RUNE,
	ENUM_ITEMS.PUFFER_FISH,
	ENUM_ITEMS.TOMBSTONE
}

local keys = {
	LEFT        = 0,
	RIGHT       = 2,
	DOWN        = 3,
	SPACE       = 32,
	LETTER_H    = 72,
	LETTER_L    = 76,
	LETTER_O    = 79,
	LETTER_P    = 80,
}

local assets = {
	banner = "173f1aa1720.png",
	count1 = "173f211056a.png",
	count2 = "173f210937b.png",
	count3 = "173f210089f.png",
	newRound = "173f2113b5e.png",
	heart = "173f2212052.png",
	iconRounds = "17434cc5748.png",
	iconDeaths = "17434d1c965.png",
	iconSurvived = "17434d0a87e.png",
	iconWon = "17434cff8bd.png",
	iconTrophy = "176463dbc3e.png",
	lock = "1660271f4c6.png",
	help = {
		survive = "17587d5abed.png",
		killAll = "17587d5ca0e.png",
		shoot = "17587d6acaf.png",
		creditors = "17587d609f1.png",
		commands = "17587d64557.png",
		weapon = "17587d67562.png",
		github = "1764b681c20.png",
		discord = "1764b73dad6.png",
		map = "1764b7a7692.png"
	},
	items = {
		[ENUM_ITEMS.SMALL_BOX] = "17406985997.png",
		[ENUM_ITEMS.LARGE_BOX] = "174068e3bca.png",
		[ENUM_ITEMS.SMALL_PLANK] = "174069a972e.png",
		[ENUM_ITEMS.LARGE_PLANK] = "174069c5a7a.png",
		[ENUM_ITEMS.BALL] = "174069d7a29.png",
		[ENUM_ITEMS.ANVIL] = "174069e766a.png",
		[ENUM_ITEMS.CANNON] = "17406bf2f70.png",
		[ENUM_ITEMS.BOMB] = "17406bf6ffc.png",
		[ENUM_ITEMS.SPIRIT] = "17406a23cd0.png",
		[ENUM_ITEMS.BLUE_BALOON] = "17406a41815.png",
		[ENUM_ITEMS.RUNE] = "17406a58032.png",
		[ENUM_ITEMS.SNOWBALL] = "17406a795f4.png",
		[ENUM_ITEMS.CUPID_ARROW] = "17406a914a3.png",
		[ENUM_ITEMS.APPLE] = "17406aa2daf.png",
		[ENUM_ITEMS.SHEEP] = "17406ac8ab7.png",
		[ENUM_ITEMS.SMALL_ICE_PLANK] = "17406aefb88.png",
		[ENUM_ITEMS.SMALL_CHOCO_PLANK] = "17406b00239.png",
		[ENUM_ITEMS.ICE_CUBE] = "17406b15725.png",
		[ENUM_ITEMS.CLOUD] = "17406b22bd6.png",
		[ENUM_ITEMS.BUBBLE] = "17406b32d1f.png",
		[ENUM_ITEMS.TINY_PLANK] = "17406b59bd6.png",
		[ENUM_ITEMS.STABLE_RUNE] = "17406b772b7.png",
		[ENUM_ITEMS.PUFFER_FISH] = "17406b8c9f2.png",
		[ENUM_ITEMS.TOMBSTONE] = "17406b9eda9.png"
	},
	widgets = {
		borders = {
			topLeft = "155cbe99c72.png",
			topRight = "155cbea943a.png",
			bottomLeft = "155cbe97a3f.png",
			bottomRight = "155cbe9bc9b.png"
		},
		closeButton = "171e178660d.png",
		scrollbarBg = "1719e0e550a.png",
		scrollbarFg = "1719e173ac6.png"
	},
	community = {
		xx = "1651b327097.png",
		ar = "1651b32290a.png",
		bg = "1651b300203.png",
		br = "1651b3019c0.png",
		cn = "1651b3031bf.png",
		cz = "1651b304972.png",
		de = "1651b306152.png",
		ee = "1651b307973.png",
		en = "1723dc10ec2.png",
		e2 = "1723dc10ec2.png",
		es = "1651b309222.png",
		fi = "1651b30aa94.png",
		fr = "1651b30c284.png",
		gb = "1651b30da90.png",
		hr = "1651b30f25d.png",
		hu = "1651b310a3b.png",
		id = "1651b3121ec.png",
		il = "1651b3139ed.png",
		it = "1651b3151ac.png",
		jp = "1651b31696a.png",
		lt = "1651b31811c.png",
		lv = "1651b319906.png",
		nl = "1651b31b0dc.png",
		ph = "1651b31c891.png",
		pl = "1651b31e0cf.png",
		pt = "1651b3019c0.png",
		ro = "1651b31f950.png",
		ru = "1651b321113.png",
		tr = "1651b3240e8.png",
		vk = "1651b3258b3.png"
	},
	dummy = "17404561700.png"
}

local closeSequence = {
	[1] = {}
}

local dHandler = DataHandler.new("pew", {
	rounds = {
		index = 1,
		type = "number",
		default = 0
	},
	survived = {
		index = 2,
		type = "number",
		default = 0
	},
	won = {
		index = 3,
		type = "number",
		default = 0
	},
	points = {
		index = 4,
		type = "number",
		default = 0
	},
	packs = {
		index = 5,
		type = "number",
		default = 1
	},
	equipped = {
		index = 6,
		type = "number",
		default = 1
	},
	roles = {
		index = 7,
		type = "number",
		default = 0
	}
})

local MIN_PLAYERS = 4

local profileWindow, leaderboardWindow, changelogWindow, shopWindow, helpWindow

local initialized, newRoundStarted, suddenDeath = false, false, false
local currentItem = ENUM_ITEMS.CANNON
local isTribeHouse = tfm.get.room.isTribeHouse
local statsEnabled = not isTribeHouse
local rotation, queuedMaps, currentMapIndex = {}, {}, 0
local leaderboardNotifyList = {}

local leaderboard, shop, roles


--==[[ translations ]]==--

local translations = {}

translations["en"] = {
	LIVES_LEFT = "<ROSE>You have <N>${lives} <ROSE>lives left. <VI>Respawning in 3...",
	LOST_ALL =	"<ROSE>You have lost all your lives!",
	SD =		"<VP>Sudden death! Everyone has <N>1 <VP>life left",
	WELCOME =	"<VP>Welcome to pewpew, <N>duck <VP>or <N>spacebar <VP>to shoot items!",
	SOLE =		"<ROSE>${player} is the sole survivor!",
	SURVIVORS = "<ROSE>${winners} and ${winner} have survived this round!",
	SELF_RANK = "<p align='center'>Your rank: ${rank}</p>",
	ROUNDS  =   "<font face='Lucida console'><N2>Rounds played</N2></font>",
	DEATHS =    "<font face='Lucida console'><N2>Deaths</N2></font>",
	SURVIVED =  "<font face='Lucida console'><N2>Rounds survived</N2></font>",
	WON =       "<font face='Lucida console'><N2>Rounds won</N2></font>",
	LBOARD_POS = "<b><font face='Lucida console' color='#e3b134'>Global leaderboard: ${pos}</font></b>",
	EQUIPPED =  "Equipped",
	EQUIP =     "Equip",
	BUY =       "Buy",
	POINTS =    "<font face='Lucida console' size='12'>   <b>Points:</b> <V>${points}</V></font>",
	PACK_DESC = "\n\n<font face='Lucida console' size='12' color='#cccccc'><i>“ ${desc} ”</i></font>\n<p align='right'><font size='10'>- ${author}</font></p>",
	GIFT_RECV = "<N>You have been rewarded with <ROSE><b>${gift}</b></ROSE> by <ROSE><b>${admin}</b></ROSE>",
	COMMANDS =  "\n\n<N2>[ <b>H</b> ]</N2> <N><ROSE>!help</ROSE> (displays this help menu)</N><br><N2>[ <b>P</b> ]</N2> <N><ROSE>!profile <i>[player]</i></ROSE> (displays the profile of the player)</N><br></N><N2>[ <b>O</b> ]</N2> <N><ROSE>!shop</ROSE> (displays the shop)</N><br><N2>[ <b>L</b> ]</N2> <N>(displays the leaderboard)</N><br><br><N><ROSE>!changelog</ROSE> (displays the changelog)</N><br><br>",
	CMD_TITLE = "<font size='25' face='Comic Sans'><b><J>Commands</J></b></font>",
	CREDITS =   "\n\nArtist - <b>${artists}</b>\nTranslators - <b>${translators}</b>\n\n\nAnd thank you for playing pewpew!",
	CREDS_TITLE = "<font size='25' face='Comic Sans'><b><R>Credits</R></b></font>",
	OBJECTIVE = "<b>Survive and kill others to win</b>",
	HELP_GOTIT = "<font size='15'><J><b><a href='event:close'>Got it!</a></b></J></font>",
	HELP_GITHUB = "<N>Want to contribute this module? Cool! Check out</N> <VI><b><i>https://github.com/Seniru/pewpew</i></b></VI>",
	HELP_DISCORD = "<N>Discord:</N> <VI><b><i>https://discord.gg/vaqgrgp</i></b></VI>",
	HELP_MAP = "<N>Want to add your maps to pewpew? Check out</N> <VI><b><i>https://atelier801.com/topic?f=6&t=892550</i></b></VI>",
	NEW_ROLE = "<N><ROSE><b>${player}</b></ROSE> is now a <ROSE><b>${role}</b></ROSE>",
	KICK_ROLE = "<N><ROSE><b>${player}</b></ROSE> is not a <ROSE><b>${role}</b></ROSE> anymore! ;c",
	ERR_PERMS = "<N>[</N><R>•</R><N>] <R><b>Error: You are not permitted to use this command!</b></R>",
	ERR_CMD =   "<N>[</N><R>•</R><N>] <R><b>Error in command<br>\tUsage:</b><font face='Lucida console'>${syntax}</i></font></R>",
	MAP_QUEUED ="<N><ROSE><b>@${map}</b></ROSE> has been queued by <ROSE><b>${player}</b></ROSE>",
	STATS_ENABLED = "${author}<G> - @${code}   |   </G><V>STATS ENABLED",
	STATS_DISABLED = "${author}<G> - @${code}   |   </G><R>STATS DISABLED"
}

translations["br"] = {
	LIVES_LEFT = "<ROSE>Você possuí <N>${lives} <ROSE>vidas restantes. <VI>Respawning in 3...",
	LOST_ALL =	"<ROSE>Você perdeu todas as suas vidas!",
	SD =		"<VP>Morte súbita! Todos agora possuem <N>1 <VP>vida restante",
	WELCOME =	"<VP>Bem-vindo(a) ao pewpew, <N>duck <VP>or <N>pressione espaço <VP>para poder atirar itens!",
	SOLE =		"<ROSE>${player} é o único sobrevivente!",
	SURVIVORS = "<ROSE>${winners} e ${winner} sobreviveram nesta rodada!",
	SELF_RANK = "<p align='center'>Seu rank: ${rank}</p>",
	ROUNDS  =   "<font face='Lucida console'><N2>Rodadas jogadas</N2></font>",
	DEATHS =    "<font face='Lucida console'><N2>Mortes</N2></font>",
	SURVIVED =  "<font face='Lucida console'><N2>Rodadas sobreviventes</N2></font>",
	WON =       "<font face='Lucida console'><N2>Rodadas ganhas</N2></font>",
	LBOARD_POS = "<b><font face='Lucida console' color='#e3b134'>Tabela de classificação geral: ${pos}</font></b>",
	EQUIPPED =  "Usando",
	EQUIP =     "Usar",
	BUY =       "Comprar",
	POINTS =    "<font face='Lucida console' size='12'>   <b>Pontos:</b> <V>${points}</V></font>",
	PACK_DESC = "\n\n<font face='Lucida console' size='12' color='#cccccc'><i>“ ${desc} ”</i></font>\n<p align='right'><font size='10'>- ${author}</font></p>",
	GIFT_RECV = "<N>Você foi recompensado com <ROSE><b>${gift}</b></ROSE> por <ROSE><b>${admin}</b></ROSE>",
	COMMANDS =  "\n\n<N2>[ <b>H</b> ]</N2> <N><ROSE>!help</ROSE> (exibe este menu de ajuda)</N><br><N2>[ <b>P</b> ]</N2> <N><ROSE>!profile <i>[player]</i></ROSE> (exibe o perfil do jogador)</N><br></N><N2>[ <b>O</b> ]</N2> <N><ROSE>!shop</ROSE> (exibe o shop)</N><br><N2>[ <b>L</b> ]</N2> <N>(exibe a classificação)</N><br><br><N><ROSE>!changelog</ROSE> (exibe o changelog)</N><br><br>",
	CMD_TITLE = "<font size='25' face='Comic Sans'><b><J>Comandos</J></b></font>",
	CREDITS =   "\n\nArtist - <b>${artists}</b>\nTranslators - <b>${translators}</b>\n\n\nE muito obrigado por jogar pewpew!",
	CREDS_TITLE = "<font size='25' face='Comic Sans'><b><R>Credits</R></b></font>",
	OBJECTIVE = "<b>Sobreviva e mate os demais para poder vencer</b>",
	HELP_GOTIT = "<font size='15'><J><b><a href='event:close'>Entendi!</a></b></J></font>",
	HELP_GITHUB = "<N>Quer ser um contribuidor desse module? Bacana! Saiba mais neste link</N> <VI><b><i>https://github.com/Seniru/pewpew</i></b></VI>",
	HELP_DISCORD = "<N>Discord:</N> <VI><b><i>https://discord.gg/vaqgrgp</i></b></VI>",
	HELP_MAP = "<N>Quer adicionar seus mapas ao pewpew? Saiba mais neste link</N> <VI><b><i>https://atelier801.com/topic?f=6&t=892550</i></b></VI>",
	NEW_ROLE = "<N><ROSE><b>${player}</b></ROSE> é agora um <ROSE><b>${role}</b></ROSE>",
	KICK_ROLE = "<N><ROSE><b>${player}</b></ROSE> não é um <ROSE><b>${role}</b></ROSE> mais! ;c",
	ERR_PERMS = "<N>[</N><R>•</R><N>] <R><b>Erro: Você não tem permissão para usar esse comando!</b></R>",
	ERR_CMD =   "<N>[</N><R>•</R><N>] <R><b>Erro no comando<br>\tUsage:</b><font face='Lucida console'>${syntax}</i></font></R>",
	MAP_QUEUED ="<N><ROSE><b>@${map}</b></ROSE> foi colocado na fila por <ROSE><b>${player}</b></ROSE>"
}

translations["es"] = {
	LIVES_LEFT =    "<ROSE>Te quedan <N>${lives} <ROSE>vidas restantes. <VI>Renaciendo en 3...",
	LOST_ALL =      "<ROSE>¡Has perdido todas tus vidas!",
	SD =            "<VP>¡Muerte súbita! A todos le quedan <N>1 <VP>vida restante",
	WELCOME =       "<VP>¡Bienvenido a pewpew, <N>agáchate <VP>o presiona <N>la barra de espacio <VP>para disparar ítems!",
	SOLE =          "<ROSE>¡${player} es el único superviviente!"
}

translations["fr"] = {
	LIVES_LEFT = "<ROSE>Tu as encore <N>${lives} <ROSE>vies restantes. <VI>Réapparition dans 3...",
	LOST_ALL =	"<ROSE>Tu as perdu toutes tes vies !",
	SD =		"<VP>Mort soudaine ! Tout le monde a <N>1 <VP>seule vie restante",
	WELCOME =	"<VP>Bienvenue dans pewpew, <N>baisse-toi <VP>ou utilise la <N>barre d'espace <VP>pour tirer des objets !",
	SOLE =		"<ROSE>${player} est le dernier survivant !",
	SURVIVORS = "<ROSE>${winners} et ${winner} ont survécu à cette manche !",
	SELF_RANK = "<p align='center'>Ton rang : ${rank}</p>",
	ROUNDS  =   "<font face='Lucida console'><N2>Manches jouées</N2></font>",
	DEATHS =    "<font face='Lucida console'><N2>Morts</N2></font>",
	SURVIVED =  "<font face='Lucida console'><N2>Manches survécues</N2></font>",
	WON =       "<font face='Lucida console'><N2>Manches gagnées</N2></font>",
	LBOARD_POS = "<b><font face='Lucida console' color='#e3b134'>Classement global : ${pos}</font></b>",
	EQUIPPED =  "Equipé",
	EQUIP =     "Utiliser",
	BUY =       "Acheter",
	POINTS =    "<font face='Lucida console' size='12'>   <b>Points :</b> <V>${points}</V></font>",
	PACK_DESC = "\n\n<font face='Lucida console' size='12' color='#cccccc'><i>“ ${desc} ”</i></font>\n<p align='right'><font size='10'>- ${author}</font></p>",
	GIFT_RECV = "<N>Tu as été récompensé avec un(e) <ROSE><b>${gift}</b></ROSE> de la part de <ROSE><b>${admin}</b></ROSE>",
	COMMANDS =  "\n\n<N2>[ <b>H</b> ]</N2> <N><ROSE>!help</ROSE> (Affiche le menu d'aide)</N><br><N2>[ <b>P</b> ]</N2> <N><ROSE>!profile <i>[joueur]</i></ROSE> (Affiche le profile d'un joueur)</N><br></N><N2>[ <b>O</b> ]</N2> <N><ROSE>!shop</ROSE> (Ouvre le magasin)</N><br><N2>[ <b>L</b> ]</N2> <N>(Affiche le classement)</N><br><br><N><ROSE>!changelog</ROSE> (Affiche l'historique des changements)</N><br><br>",
	CMD_TITLE = "<font size='25' face='Comic Sans'><b><J>Commandes</J></b></font>",
	CREDITS =   "\n\nArtiste - <b>${artists}</b>\nTraducteurs - <b>${translators}</b>\n\n\nEt merci de jouer à Pewpew!",
	CREDS_TITLE = "<font size='25' face='Comic Sans'><b><R>Credits</R></b></font>",
	OBJECTIVE = "<b>Survie et tue les autres pour gagner.</b>",
	HELP_GOTIT = "<font size='15'><J><b><a href='event:close'>Compris !</a></b></J></font>",
	HELP_GITHUB = "<N>Envie de contribuer à ce module ? Cool ! Va sur </N> <VI><b><i>https://github.com/Seniru/pewpew</i></b></VI>",
	HELP_DISCORD = "<N>Discord : </N> <VI><b><i>https://discord.gg/vaqgrgp</i></b></VI>",
	HELP_MAP = "<N>Tu voudrais voir tes maps dans pewpew ? Va sur </N> <VI><b><i>https://atelier801.com/topic?f=6&t=892550</i></b></VI>",
	NEW_ROLE = "<N><ROSE><b>${player}</b></ROSE> est maintenant un(e) <ROSE><b>${role}</b></ROSE>",
	KICK_ROLE = "<N><ROSE><b>${player}</b></ROSE> n'est plus un(e) <ROSE><b>${role}</b></ROSE> ! ;c",
}

translations["tr"] = {
	LIVES_LEFT =    "<N>${lives} <ROSE> canınız kaldı. <VI>3 saniye içinde yeniden doğacaksınız...",
	LOST_ALL =      "<ROSE>Bütün canınızı kaybettiniz!",
	SD =            "<VP>Ani ölüm! Artık herkesin <N>1<VP> canı kald?",
	WELCOME =       "<VP>pewpew odasına hoşgeldiniz, eşyaları fırlatmak için <N>eğilin <VP>ya da <N>spacebar <VP>'a basın!",
	SOLE =          "<ROSE>Yaşayan kişi ${player}!",
	SURVIVORS =     "<ROSE>${winners} ve ${winner} bu turda hayatta kaldı!",
	SELF_RANK =     "<p align='center'>Your rank: ${rank}</p>",
	ROUNDS  =       "<font face='Lucida console'><N2>Oynanılan turlar</N2></font>",
	DEATHS =        "<font face='Lucida console'><N2>Ölümler</N2></font>",
	SURVIVED =      "<font face='Lucida console'><N2>Rounds survived</N2></f  ont>",
	WON =           "<font face='Lucida console'><N2>Kazanılan turlar</N2></font>",
	LBOARD_POS =     "<b><font face='Lucida console' color='#e3b134'>Genel Skor Tablosu: ${pos}</font></b>",
	EQUIPPED =      "Donanımlı",
	EQUIP =         "Ekipman",
	BUY =           "Satın Al",
	POINTS =        "<font face='Lucida console' size='12'>   <b>Puanlar:</b> <V>${points}</V></font>",
	PACK_DESC =     "\n\n<font face='Lucida console' size='12' color='#cccccc'><i>“ ${desc} ”</i></font>\n<p align='right'><font size='10'>- ${author}</font></p>",
	GIFT_RECV =     "<N>Ödülendirildin seni ödülendiren kişi <ROSE><b>${gift}</b></ROSE> by <ROSE><b>${admin}</b></ROSE>",
	COMMANDS =      "\n\n<N2>[ <b>H</b> ]</N2> <N><ROSE>!help</ROSE> (yardım menüsünü açar)</N><br><N2>[ <b>P</b> ]</N2> <N><ROSE>!profile <i>[oyuncu]</i></ROSE> (istediğiniz kişinin profiline bakarsınız)</N><br></N><N2>[ <b>O</b> ]</N2> <N><ROSE>!shop</ROSE> (Marketi açar)</N><br><N2>[ <b>L</b> ]</N2> <N>(Skor Tablosunu açar)</N><br><br><N><ROSE>!changelog</ROSE> (displays the changelog)</N><br><br>",
	CMD_TITLE =     "<font size='25' face='Comic Sans'><b><J>Komutlar</J></b></font>",
	CREDITS =       "\n\nÇizimler - <b>${artists}</b>\nÇevirmenler - <b>${translators}</b>\n\n\nVe pewpew oynadığınız için teşekkür ederiz!",
	CREDS_TITLE =   "<font size='25' face='Comic Sans'><b><R>Krediler</R></b></font>",
	OBJECTIVE =     "<b>Hayatta kal ve kazanmak için başkalarını öldür</b>",
	HELP_GOTIT =    "<font size='15'><J><b><a href='event:close'>Anladım!</a></b></J></font>",
	HELP_GITHUB =   "<N>Bu modüle katkıda bulunmak ister misiniz? Güzel! Link:</N> <VI><b><i>https://github.com/Seniru/pewpew</i></b></VI>",
	HELP_DISCORD =  "<N>Discord:</N> <VI><b><i>https://discord.gg/vaqgrgp</i></b></VI>",
	HELP_MAP =      "<N>Haritalarınızı pewpew'e eklemek ister misiniz? Link:</N> <VI><b><i>https://atelier801.com/topic?f=6&t=892550</i></b></VI>",
	NEW_ROLE =      "<N><ROSE><b>${player}</b></ROSE> artık bir <ROSE><b>${role}</b></ROSE>",
	KICK_ROLE =     "<N><ROSE><b>${player}</b></ROSE> artık bir <ROSE><b>${role}</b></ROSE> değil! ;c"
}

translations["tg"] = {
	LIVES_LEFT = "<ROSE>Mayroon kang <N>${lives} <ROSE>buhay na natitira. <VI>Respawning sa 3...",
	LOST_ALL =	"<ROSE>Nawala lahat nang buhay mo!",
	SD =		"<VP>Biglaang kamatayan! Lahat ay mayroong <N>1 <VP>buhay na natitira",
	WELCOME =	"<VP>Maligayang pagdating sa pewpew, <N>bumaba <VP>o <N>spacebar <VP>para bumaril nang gamit!",
	SOLE =		"<ROSE>${player} ang nag isang nakaligtas!",
	SURVIVORS = "<ROSE>${winners} at ${winner} ay nakaligtas ngayong round!",
	SELF_RANK = "<p align='center'>Ranggo mo: ${rank}</p>",
	ROUNDS  =   "<font face='Lucida console'><N2>Rounds na nalaro</N2></font>",
	DEATHS =    "<font face='Lucida console'><N2>Pagkamatay</N2></font>",
	SURVIVED =  "<font face='Lucida console'><N2>Rounds na nakaligtas</N2></font>",
	WON =       "<font face='Lucida console'><N2>Rounds na nanalo</N2></font>"
}

translations["pl"] = {
	LIVES_LEFT = "<ROSE>Pozostało ci <N>${lives} <ROSE>żyć! . <VI>Odrodzenie za 3...",
	LOST_ALL =	"<ROSE>Straciłeś wszystkie życia!",
	SD =		"<VP>Nagła śmierć! Każdy został z <N>1 <VP>życiem",
	WELCOME =	"<VP>Witamy w Pewpew, kucnij, kliknij strzałkę w dół lub <N>spacje <VP>aby strzelać przedmiotami!",
	SOLE =		"<ROSE>${player} jest jedynym ocalałym!",
	SURVIVORS = "<ROSE>${winners} i ${winner} przeżyli tę runde!",
	SELF_RANK = "<p align='center'>Twoja range: ${rank}</p>",
	ROUNDS  =   "<font face='Lucida console'><N2>Rozegrane rundy</N2></font>",
	DEATHS =    "<font face='Lucida console'><N2>Śmierci</N2></font>",
	SURVIVED =  "<font face='Lucida console'><N2>Przeżyte rundy</N2></font>",
	WON =       "<font face='Lucida console'><N2>Wygrane rundy</N2></font>"
}

translations["ru"] = {
	LIVES_LEFT = "<ROSE>Оставшиеся жизни: <N>${lives}. <VI>Вернёшься в игру через 3...",
	LOST_ALL =	"<ROSE>Вы потеряли все cвои жизни!",
	SD =		"<VP>Внезапная смерть! У всех осталась <N>1 <VP>жизнь.",
	WELCOME =	"<VP>Добро пожаловать в pewpew, нажмите на пробел или на s чтобы стрелять предметами.",
	SOLE =		"<ROSE>${player} был единственным выжившим!",
	SURVIVORS = "<ROSE>${winners} и ${winner} выжили эту игру!",
	SELF_RANK = "<p align='center'>Ваше место на лидерборде: ${rank}</p>",
	ROUNDS  =   "<font face='Lucida console'><N2>Номер игр</N2></font>",
	DEATHS =    "<font face='Lucida console'><N2>Умер</N2></font>",
	SURVIVED =  "<font face='Lucida console'><N2>Выжил</N2></font>",
	WON =       "<font face='Lucida console'><N2>Выиграл</N2></font>"
}

translations["hu"] = {
	LIVES_LEFT = "<ROSE><N>${lives} <ROSE>életed maradt. <VI>Újraéledés 3...",
	LOST_ALL =    "<ROSE>Elvesztetted az összes életed!",
	SD =        "<VP>Hirtelen halál! Mindenkinek <N>1 <VP>élete maradt.",
	WELCOME =    "<VP>Üdvözöl a pewpew! Használd a <N>lefele <VP>vagy a <N>space <VP>gombot, hogy tárgyakat lőj!",
	SOLE =        "<ROSE>${player} az egyetlen túlélő!",
	SURVIVORS = "<ROSE>${winners} és ${winner} túlélte ezt a kört!",
	SELF_RANK = "<p align='center'>Rangod: ${rank}</p>",
	ROUNDS  =   "<font face='Lucida console'><N2>Játszott körök</N2></font>",
	DEATHS =    "<font face='Lucida console'><N2>Halálok</N2></font>",
	SURVIVED =  "<font face='Lucida console'><N2>Túlélt körök</N2></font>",
	WON =       "<font face='Lucida console'><N2>Megnyert körök</N2></font>",
	LBOARD_POS = "<b><font face='Lucida console' color='#e3b134'>Globális ranglista: ${pos}</font></b>",
	EQUIPPED =  "Használva",
	EQUIP =     "Használ",
	BUY =       "Vásárlás",
	POINTS =    "<font face='Lucida console' size='12'>   <b>Pont:</b> <V>${points}</V></font>",
	PACK_DESC = "\n\n<font face='Lucida console' size='12' color='#cccccc'><i>“ ${desc} ”</i></font>\n<p align='right'><font size='10'>- ${author}</font></p>",
	GIFT_RECV = "<N><ROSE><b>${admin}</b></ROSE> megjutalmazott téged ezzel: <ROSE><b>${gift}</b></ROSE>",
	COMMANDS =  "\n\n<N2>[ <b>H</b> ]</N2> <N><ROSE>!help</ROSE> (megnyitja a segítség menüt)</N><br><N2>[ <b>P</b> ]</N2> <N><ROSE>!profile <i>[játékosNév]</i></ROSE> (megnyitja a játékosNév profilját)</N><br></N><N2>[ <b>O</b> ]</N2> <N><ROSE>!shop</ROSE> (megnyitja a boltot)</N><br><N2>[ <b>L</b> ]</N2> <N>(megnyitja a ranglistát)</N><br><br><N><ROSE>!changelog</ROSE> (megnyitja a változásokat)</N><br><br>",
	CMD_TITLE = "<font size='25' face='Comic Sans'><b><J>Parancsok</J></b></font>",
	CREDITS =   "\n\nMűvész - <b>${artists}</b>\nFordítók - <b>${translators}</b>\n\n\nÉs köszönöm, hogy játszol a pewpew -el!",
	CREDS_TITLE = "<font size='25' face='Comic Sans'><b><R>Kreditek</R></b></font>",
	OBJECTIVE = "<b>Éld túl és ölj meg másokat a győzelemért</b>",
	HELP_GOTIT = "<font size='15'><J><b><a href='event:close'>Értem!</a></b></J></font>",
	HELP_GITHUB = "<N>Szeretnél hozzájárulni a modulhoz? Nagyszerű! Csekkold:</N> <VI><b><i>https://github.com/Seniru/pewpew</i></b></VI>",
	HELP_DISCORD = "<N>Discord:</N> <VI><b><i>https://discord.gg/vaqgrgp</i></b></VI>",
	HELP_MAP = "<N>Szeretnél benyújtani pályákat? Csekkold:</N> <VI><b><i>https://atelier801.com/topic?f=6&t=892550</i></b></VI>",
	NEW_ROLE = "<N><ROSE><b>${player}</b></ROSE> most már egy <ROSE><b>${role}</b></ROSE>",
	KICK_ROLE = "<N><ROSE><b>${player}</b></ROSE> nem <ROSE><b>${role}</b></ROSE> többé! ;c",
}

translations["ur"] = {
	LIVES_LEFT = "<ROSE>Ap ke pas <N>${lives} <ROSE>lives hain. <VI>Apke zinda honay me time hai 3...",
	LOST_ALL =    "<ROSE>Ap apni saari lives kho chukay hain!",
	SD =        "<VP>Sudden Death! Sab ke paas <N>1 <VP>life hai",
	WELCOME =    "<VP>Pewpew me khushamadeed!, <N>duck <VP>ya <N>spacebar <VP>se items shoot karain!",
	SOLE =        "<ROSE>${player} sole survivor hain!",
	SURVIVORS = "<ROSE>${winners} aur ${winner} is round round ke survivors hai!",
	SELF_RANK = "<p align='center'>Apka rank: ${rank}</p>",
	ROUNDS  =   "<font face='Lucida console'><N2>Rounds khelay</N2></font>",
	DEATHS =    "<font face='Lucida console'><N2>Deaths</N2></font>",
	SURVIVED =  "<font face='Lucida console'><N2>Rounds survived</N2></font>",
	WON =       "<font face='Lucida console'><N2>Rounds jeetay</N2></font>",
	LBOARD_POS = "<b><font face='Lucida console' color='#e3b134'>Aalmi leaderboard: ${pos}</font></b>",
	EQUIPPED =  "Equipped",
	EQUIP =     "Equip",
	BUY =       "Khareedien",
	POINTS =    "<font face='Lucida console' size='12'>   <b>Points:</b> <V>${points}</V></font>",
	PACK_DESC = "\n\n<font face='Lucida console' size='12' color='#cccccc'><i>“ ${desc} ”</i></font>\n<p align='right'><font size='10'>- ${author}</font></p>",
	GIFT_RECV = "<N>Ap ko <ROSE><b>${admin}</b></ROSE> ne <ROSE><b>${gift}</b></ROSE> inaam diya hai",
	COMMANDS =  "\n\n<N2>[ <b>H</b> ]</N2> <N><ROSE>!help</ROSE> (help menu dekhnay ke liye)</N><br><N2>[ <b>P</b> ]</N2> <N><ROSE>!profile <i>[player]</i></ROSE> (Player ki profile dekhnay ke liye)</N><br></N><N2>[ <b>O</b> ]</N2> <N><ROSE>!shop</ROSE> (dukaan kholnay ke liye)</N><br><N2>[ <b>L</b> ]</N2> <N>(leaderboard kholnay ke liye)</N><br><br><N><ROSE>!changelog</ROSE> (changelog dekhnay ke liye)</N><br><br>",
	CMD_TITLE = "<font size='25' face='Comic Sans'><b><J>Commands</J></b></font>",
	CREDITS =   "\n\nArtist - <b>${artists}</b>\nTranslators - <b>${translators}</b>\n\n\nPewpew khelnay ke liye shukariya!",
	CREDS_TITLE = "<font size='25' face='Comic Sans'><b><R>Credits</R></b></font>",
	OBJECTIVE = "<b>Dusron ko maarein aur jeetein.</b>",
	HELP_GOTIT = "<font size='15'><J><b><a href='event:close'>Got it!</a></b></J></font>",
	HELP_GITHUB = "<N>Kiya aap bhi is module ki madad krna chahtay hain? Is link pr jayein</N> <VI><b><i>https://github.com/Seniru/pewpew</i></b></VI>",
	HELP_DISCORD = "<N>Discord:</N> <VI><b><i>https://discord.gg/vaqgrgp</i></b></VI>",
	HELP_MAP = "<N>Kiya aap apnay maps pewpew mein daalna chahtay hai? Is link pr jayein</N> <VI><b><i>https://atelier801.com/topic?f=6&t=892550</i></b></VI>",
	NEW_ROLE = "<N><ROSE><b>${player}</b></ROSE> ab <ROSE><b>${role}</b></ROSE> hain!",
	KICK_ROLE = "<N><ROSE><b>${player}</b></ROSE> ab <ROSE><b>${role}</b></ROSE> nahi hain! ;c",
	ERR_PERMS = "<N>[</N><R>•</R><N>] <R><b>Error: Ap ye command istemaal nahi kr saktay!</b></R>",
	ERR_CMD =   "<N>[</N><R>•</R><N>] <R><b>Command mein ghalti hai.<br>\tUsage:</b><font face='Lucida console'>${syntax}</i></font></R>",
	MAP_QUEUED ="<ROSE><b>${player}</b></ROSE> ne <N><ROSE><b>@${map}</b></ROSE> queue mein daala hai."
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
	return stringutils.format(translation, kwargs)
end


--==[[ classes ]]==--

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

	self.tempEquipped = nil
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
	if newRoundStarted and self.alive and not self.inCooldown then
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

function Player:hasRole(role)
	return not not self.roles[role]
end

function Player:savePlayerData()
	-- if tfm.get.room.uniquePlayers < MIN_PLAYERS then return end
	local name = self.name
	dHandler:set(name, "rounds", self.rounds)
	dHandler:set(name, "survived", self.survived)
	dHandler:set(name, "won", self.won)
	dHandler:set(name, "points", self.points)
	dHandler:set(name, "packs", shop.packsBitList:encode(self.packs))
	dHandler:set(name, "equipped", self.equipped == "Random" and -1 or shop.packsBitList:find(self.equipped))
	dHandler:set(name, "roles", roles.list:encode(self.roles))
	system.savePlayerData(name, "v2" .. dHandler:dumpPlayer(name))
end


--==[[ events ]]==--

function eventNewPlayer(name)
	local player = Player.new(name)
	tfm.exec.chatMessage(translate("WELCOME", player.community), name)
	tfm.exec.chatMessage("<N>Discord server:</N> <VI><b><i>https://discord.gg/vaqgrgp</i></b></VI>", name)
	Timer("banner_" .. name, function(image)
		tfm.exec.removeImage(image)
	end, 5000, false, tfm.exec.addImage(assets.banner, ":1", 120, -85, name))
	system.loadPlayerData(name)
	setNameColor(name)
end

function eventLoop(tc, tr)

	Timer.process()

	if tr < 0 and initialized then
		if not suddenDeath then
			suddenDeath = true
			tfm.exec.chatMessage(translate("SD", tfm.get.room.language))
			for name, player in next, Player.alive do
				player:setLives(1)
			end
			tfm.exec.setGameTime(30, true)
		else
			local aliveCount = Player.aliveCount
			if aliveCount > 1 then
				local winners = ""
				local winner = ""
				for name, player in next, Player.alive do
					if statsEnabled then
						player.rounds = player.rounds + 1
						player.survived = player.survived + 1
						player.points = player.points + 2
						player:savePlayerData()
					end
					if aliveCount == 1 then
						winners = winners:sub(1, -3)
						local n, t = extractName(name)
						winner = "<b><VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font></b>"
						break
					end
					local n, t = extractName(name)
					winners = winners .. "<b><VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font></b>" .. ", "
					aliveCount = aliveCount - 1
				end
				tfm.exec.chatMessage(translate("SURVIVORS", tfm.get.room.language, nil, { winners = winners, winner = winner }))
			end
			newRoundStarted = false
			Timer("newRound", newRound, 3 * 1000)
			tfm.exec.setGameTime(4, true)
		end
	end

end

function eventKeyboard(name, key, down, x, y)
	if key == keys.SPACE or key == keys.DOWN then
		Player.players[name]:shoot(x, y)
	elseif key == keys.LEFT then
		Player.players[name].stance = -1
	elseif key == keys.RIGHT then
		Player.players[name].stance = 1
	elseif key == keys.LETTER_H then
		displayHelp(name, true)
	elseif key == keys.LETTER_P then
		displayProfile(Player.players[name], name, true)
	elseif key == keys.LETTER_L then
		leaderboard.displayLeaderboard("global", 1, name, true)
	elseif key == keys.LETTER_O then
		shop.displayShop(name, 1, true)
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
	ui.setMapName(translate(statsEnabled and "STATS_ENABLED" or "STATS_DISABLED", tfm.get.room.community, nil, {
		author = tfm.get.room.xmlMapInfo.author,
		code = tfm.get.room.xmlMapInfo.mapCode
	}))
end

function eventPlayerDied(name)
	local player = Player.players[name]
	if not player then return end
	if not newRoundStarted then
		tfm.exec.respawnPlayer(name)
		return player:refresh()
	end

	player.lives = player.lives - 1
	tfm.exec.setPlayerScore(name, player.lives)
	player.alive = false

	if player.lives == 0 then
		player:die()
	else
		tfm.exec.chatMessage(translate("LIVES_LEFT", player.community, nil, {lives = player.lives}), name)
		Timer("respawn_" .. name, function()
			tfm.exec.respawnPlayer(name)
			setNameColor(name)
			player:setLives(player.lives)
			player.alive = true
		end, 3000, false)
	end
end

function eventPlayerLeft(name)
	local player = Player.players[name]
	if not player then return end
	player:die()
	Player.players[name] = nil
	Player.playerCount = Player.playerCount - 1
	-- statsEnabled = (not isTribeHouse) and tfm.get.room.uniquePlayers >= 4
end

function eventPlayerDataLoaded(name, data)
	-- reset player data if they are stored according to the old version
	if data:find("^v2") then
		dHandler:newPlayer(name, data:sub(3))
	else
		system.savePlayerData(name, "")
		dHandler:newPlayer(name, "")
	end

	local player = Player.players[name]

	player.rounds = dHandler:get(name, "rounds")
	player.survived = dHandler:get(name, "survived")
	player.won = dHandler:get(name, "won")
	player.points = dHandler:get(name, "points")

	player.packs = shop.packsBitList:decode(dHandler:get(name, "packs"))
	local counter = 1
	for pack, hasPack in next, player.packs do
		if pack ~= "Default" and hasPack then
			player.packsArray[counter] = pack
			counter = counter + 1
		end
	end

	player.packs["Random"] = true

	local equipped = dHandler:get(name, "equipped")
	player.equipped = equipped == -1 and "Random" or shop.packsBitList:get(equipped)

	player.roles = roles.list:decode(dHandler:get(name, "roles"))
	player.highestRole = roles.getHighestRole(player)
	setNameColor(name)

end

function eventFileLoaded(id, data)
	-- print(table.tostring(leaderboard.leaders))
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
		print("[STATS] Leaderboard and map data loaded!")

		local sections = stringutils.split(data, "\n\n")
		local lBoardData = sections[1]

		if maps.dumpCache ~= sections[2] and not maps.overwriteFile then
			maps.dumpCache = sections[2]
			maps.list = stringutils.split(maps.dumpCache, ",")
		end

		if #rotation < 50 then
			rotation = shuffleMaps(maps.list)
		end

		if not (leaderboard.leaderboardData == lBoardData) then
			leaderboard.leaderboardData = lBoardData
			leaderboard.leaders = leaderboard.parseLeaderboard(lBoardData)
		end
		for name, player in next, Player.players do leaderboard.addPlayer(player) end
		leaderboard.save(leaderboard.leaders, #leaderboardNotifyList > 0) -- force save when required
	end
end

function eventFileSaved(id)
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
		print("[STATS] Leaderboard saved!")
		print(os.time())
		for _, player in next, leaderboardNotifyList do
			tfm.exec.chatMessage("<N>[</N><R>•</R><N>] Files have been updated!", player)
		end
		leaderboardNotifyList = {}
		leaderboard.needUpdate = false
		maps.overwriteFile = false
	end
end

function eventChatCommand(name, cmd)
	local args = stringutils.split(cmd, " ")
	if cmds[args[1]] then
		local cmdArgs = {}
		for i = 2, #args do cmdArgs[#cmdArgs + 1] = args[i] end
		cmds[args[1]](cmdArgs, cmd, name)
	end
end

function eventTextAreaCallback(id, name, event)
	Panel.handleActions(id, name, event)
end


--==[[ main ]]==--

leaderboard = {}

leaderboard.FILE_ID = 2
leaderboard.DUMMY_DATA = [[*souris1,0,0,0,xx|*souris2,0,0,0,xx|*souris3,0,0,0,xx|*souris4,0,0,0,xx|*souris5,0,0,0,xx|*souris6,0,0,0,xx|*souris7,0,0,0,xx|*souris8,0,0,0,xx|*souris9,0,0,0,xx|*souris10,0,0,0,xx|*souris11,0,0,0,xx|*souris12,0,0,0,xx|*souris13,0,0,0,xx|*souris14,0,0,0,xx|*souris15,0,0,0,xx|*souris16,0,0,0,xx|*souris17,0,0,0,xx|*souris18,0,0,0,xx|*souris19,0,0,0,xx|*souris20,0,0,0,xx|*souris21,0,0,0,xx|*souris22,0,0,0,xx|*souris23,0,0,0,xx|*souris24,0,0,0,xx|*souris25,0,0,0,xx|*souris26,0,0,0,xx|*souris27,0,0,0,xx|*souris28,0,0,0,xx|*souris29,0,0,0,xx|*souris30,0,0,0,xx|*souris31,0,0,0,xx|*souris32,0,0,0,xx|*souris33,0,0,0,xx|*souris34,0,0,0,xx|*souris35,0,0,0,xx|*souris36,0,0,0,xx|*souris37,0,0,0,xx|*souris38,0,0,0,xx|*souris39,0,0,0,xx|*souris40,0,0,0,xx|*souris41,0,0,0,xx|*souris42,0,0,0,xx|*souris43,0,0,0,xx|*souris44,0,0,0,xx|*souris45,0,0,0,xx|*souris46,0,0,0,xx|*souris47,0,0,0,xx|*souris48,0,0,0,xx|*souris49,0,0,0,xx|*souris50,0,0,0,xx]]

leaderboard.needUpdate = false
leaderboard.indexed = {}
leaderboard.leaderboardData = leaderboard.leaderboardData or leaderboard.DUMMY_DATA

leaderboard.parseLeaderboard = function(data)
	local res = {}
	for i, entry in next, stringutils.split(data, "|") do
		local fields = stringutils.split(entry, ",")
		local name = fields[1]
		res[name] = { name = name, rounds = tonumber(fields[2]), survived = tonumber(fields[3]), won = tonumber(fields[4]), community = fields[5] }
		res[name].score = leaderboard.scorePlayer(res[name])
	end
	return res
end

leaderboard.dumpLeaderboard = function(lboard)
	local res = ""
	for i, entry in next, lboard do
		res = res .. entry.name .. "," .. entry.rounds .. "," .. entry.survived .. "," .. entry.won .. "," .. entry.community .. "|"
	end
	return res:sub(1, -2)
end

leaderboard.load = function()
	local started = system.loadFile(leaderboard.FILE_ID)
	if started then print("[STATS] Loading leaderboard...") end
end

leaderboard.save = function(leaders, force)
	local serialised, indexes = leaderboard.prepare(leaders)
	--if (not force)  then return end
	leaderboard.indexed = indexes
	if (not force) and serialised == leaderboard.leaderboardData and tfm.get.room.uniquePlayers < 4 then return end
	local started = system.saveFile(serialised .. "\n\n" .. maps.dumpCache, leaderboard.FILE_ID)
	if started then print("[STATS] Saving leaderboard...") end
end

leaderboard.scorePlayer = function(player)
	return player.rounds * 0.5 * ((player.won + player.survived) / (player.rounds == 0 and 1 or player.rounds))
end

leaderboard.addPlayer = function(player)
	local score = leaderboard.scorePlayer(player)
	leaderboard.leaders[player.name] = { name = player.name, rounds = player.rounds, survived = player.survived, won = player.won, community = player.community, score = score }
end

leaderboard.prepare = function(leaders)

	local temp, res = {}, {}

	for name, leader in next, leaders do
		if not banned[name] then
			temp[#temp + 1] = leader
		end
	end

	table.sort(temp, function(p1, p2)
		return p1.score > p2.score
	end)

	for i = 1, 50 do res[i] = temp[i] end

	return leaderboard.dumpLeaderboard(res), res

end

leaderboard.displayLeaderboard = function(mode, page, target, keyPressed)
	local targetPlayer = Player.players[target]

	if targetPlayer.openedWindow then
		targetPlayer.openedWindow:hide(target)
		if targetPlayer.openedWindow == leaderboardWindow and keyPressed then
			targetPlayer.openedWindow = nil
			return
		end
	end

	leaderboardWindow:show(target)
	local leaders = {}
	local rankTxt, nameTxt, roundsTxt, deathsTxt, survivedTxt, wonTxt
		= "<br><br>", "<br><br>", "<br><br>", "<br><br>", "<br><br>", "<br><br>"

	if mode == "global" then
		for leader = (page - 1) * 10 + 1, page * 10 do leaders[#leaders + 1] = leaderboard.indexed[leader] end
		Panel.panels[356]:update("<font size='20'><BV><p align='center'><a href='event:1'>•</a>  <a href='event:2'>•</a>  <a href='event:3'>•</a>  <a href='event:4'>•</a>  <a href='event:5'>•</a></p>")
		Panel.panels[357]:update("<a href='event:switch'>Global \t ▼</a>", target)
	else
		local selfRank

		for name, player in next, Player.players do
			leaders[#leaders + 1] = player
		end

		table.sort(leaders, function(p1, p2)
			return leaderboard.scorePlayer(p1) > leaderboard.scorePlayer(p2)
		end)
		for i, leader in ipairs(leaders) do if leader.name == target then selfRank = i break end end
		-- TODO: Add translations v
		Panel.panels[356]:update(translate("SELF_RANK", targetPlayer.community, nil, { rank = selfRank }), target)
		Panel.panels[357]:update("<a href='event:switch'>Room \t ▼</a>", target)

	end


	local counter = 0
	local rankPage = (page - 1) * 10
	for i, leader in next, leaders do
		local name, tag = extractName(leader.name)
		if not (name and tag) then name, tag = leader.name, "" end
		counter = counter + 1
		rankTxt = rankTxt .. "# " .. rankPage + counter .. "<br>"
		nameTxt = nameTxt .. "            <b><V>" .. name .. "</V><N><font size='8'>" .. tag .. "</font></N></b><br>"
		roundsTxt = roundsTxt .. leader.rounds .. "<br>"
		deathsTxt = deathsTxt .. (leader.rounds - leader.survived) .. "<br>"
		survivedTxt = survivedTxt .. leader.survived .. " <V><i><font size='9'>(" .. math.floor(leader.survived / (leader.rounds == 0 and 1 or leader.rounds) * 100) .. " %)</font></i></V><br>"
		wonTxt = wonTxt .. leader.won .. " <V><i><font size='9'>(" .. math.floor(leader.won / (leader.rounds == 0 and 1 or leader.rounds) * 100) .. " %)</font></i></V><br>"
		Panel.panels[351]:addImageTemp(Image(assets.community[leader.community], "&1", 170, 115 + 13 * counter), target)
		if counter >= 10 then break end
	end

	Panel.panels[350]:update(rankTxt, target)
	Panel.panels[351]:update(nameTxt, target)
	Panel.panels[352]:update(roundsTxt, target)
	Panel.panels[353]:update(deathsTxt, target)
	Panel.panels[354]:update(survivedTxt, target)
	Panel.panels[355]:update(wonTxt, target)
	targetPlayer.openedWindow = leaderboardWindow

end

leaderboard.leaders = leaderboard.parseLeaderboard(leaderboard.leaderboardData)

shop = {}

-- Images to display in shop if some items are missing in the pack
shop.defaultItemImages = {
	[ENUM_ITEMS.CANNON] = "175301924fd.png",
	[ENUM_ITEMS.ANVIL] = "17530198302.png",
	[ENUM_ITEMS.BALL] = "175301924fd.png",
	[ENUM_ITEMS.BLUE_BALOON] = "175301b5151.png",
	[ENUM_ITEMS.LARGE_BOX] = "175301a8692.png",
	[ENUM_ITEMS.SMALL_BOX] = "175301adef2.png",
	[ENUM_ITEMS.LARGE_PLANK] = "1753019e778.png",
	[ENUM_ITEMS.SMALL_PLANK] = "175301a35c2.png"
}

-- Item packs that are used to display in the shop interface
shop.packs = {

		["Random"] = {
			coverImage = "1756e10f5e0.png",
			coverAdj = { x = 3, y = 0 },
			description = "It's all random 0m0",
			author = "rand()",
			price = 0,

			description_locales = {
				en = "It's all random 0m0",
				fr = "C'est que du hasard 0m0",
				br = "É tudo aleatório 0m0",
				ur = "Sab random hai 0m0"
			},

			skins = {
				[ENUM_ITEMS.CANNON] = { image = "1756df9f351.png" },
				[ENUM_ITEMS.ANVIL] = { image = "1756dfa81b1.png" },
				[ENUM_ITEMS.BALL] = { image = "1756df9f351.png" },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "1756dfa3e9a.png" },
				[ENUM_ITEMS.LARGE_BOX] = { image = "1756dfad0ff.png" },
				[ENUM_ITEMS.SMALL_BOX] = { image = "1756dfafe31.png" },
				[ENUM_ITEMS.LARGE_PLANK] = { image = "1756dfb428f.png" },
				[ENUM_ITEMS.SMALL_PLANK] = { image = "1756e01b60d.png" }
			}
		},

		["Default"] = {
			coverImage = "175405f30a3.png",
			coverAdj = { x = 15, y = 5 },
			description = "Default item pack",
			author = "Transformice",
			price = 0,

			description_locales = {
				en = "Default item pack",
				fr = "Pack de texture par défaut.",
				br = "Pacote de itens padrão",
				ur = "Default cheezon ka pack"
			},

			skins = {
				[ENUM_ITEMS.CANNON] = { image = "1752b1c10bc.png" },
				[ENUM_ITEMS.ANVIL] = { image = "1752b1b9497.png" },
				[ENUM_ITEMS.BALL] = { image = "1752b1bdeee.png" },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "1752b1aa57c.png" },
				[ENUM_ITEMS.LARGE_BOX] = { image = "1752b1adb5e.png" },
				[ENUM_ITEMS.SMALL_BOX] = { image = "1752b1b1cc6.png" },
				[ENUM_ITEMS.LARGE_PLANK] = { image = "1752b1b5ac3.png" },
				[ENUM_ITEMS.SMALL_PLANK] = { image = "1752b0918ed.png" }
			}
		},

		["Poisson"] = {
			coverImage = "17540405f67.png",
			coverAdj = { x = 8, y = 8 },
			description = "Back in old days...",
			author = "Transformice",
			price = 100,

			description_locales = {
				en = "Back in old days...",
				fr = "Comme au bon vieux temps...",
				br = "De volta aos velhos tempos...",
				ur = "Puranay dino mein..."
			},

			skins = {
				[ENUM_ITEMS.CANNON] =  { image = "174bb44115d.png", adj = { x = -16, y = -16 } },
				[ENUM_ITEMS.ANVIL] = { },
				[ENUM_ITEMS.BALL] =  { image = "174bb405fd4.png", adj = { x = -16, y = -16 } },
				[ENUM_ITEMS.BLUE_BALOON] = { },
				[ENUM_ITEMS.LARGE_BOX] =  { image = "174c530f384.png", adj = { x = -30, y = -30 } },
				[ENUM_ITEMS.SMALL_BOX] =  { image = "174c532630c.png", adj = { x = -16, y = -16 } },
				[ENUM_ITEMS.LARGE_PLANK] =  { image = "174c5311ea4.png", adj = { x = -104, y = -6 } },
				[ENUM_ITEMS.SMALL_PLANK] =  { image = "174c5324b9b.png", adj = { x = -50, y = -6 } }
			}
		},

		["Catto"] = {
			coverImage = "1754528ac5c.png",
			coverAdj = { x = 8, y = 0 },
			description = "Meow!",
			author = "King_seniru#5890",
			price = 300,

			description_locales = {
				en = "Meow!",
				fr = "Miaou !",
				br = "Miau!",
			},

			skins = {
				[ENUM_ITEMS.CANNON] =  { image = "17530cc2bfb.png", adj = { x = -16, y = -16 } },
				[ENUM_ITEMS.ANVIL] = { image = "17530cb9535.png", adj = { x = -24, y = -24 } },
				[ENUM_ITEMS.BALL] =  { image = "17530cb1c03.png", adj = { x = -16, y = -16 } },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "17530cc8b06.png", adj = { x = -18, y = -18 } },
				[ENUM_ITEMS.LARGE_BOX] =  { image = "17530ccf337.png", adj = { x = -30, y = -30 } },
				[ENUM_ITEMS.SMALL_BOX] =  { image = "17530cd4a81.png", adj = { x = -16, y = -16 } },
				[ENUM_ITEMS.LARGE_PLANK] =  { image = "17530cf135f.png", adj = { x = -100, y = -14 } },
				[ENUM_ITEMS.SMALL_PLANK] =  { image = "17530cf9d23.png", adj = { x = -50, y = -14 } }
			}
		},

		["Royal"] = {
			coverImage = "1754f97c21c.png",
			coverAdj = { x = 8, y = 0 },
			description = "Only for the strongest kings!",
			author = "Lightymouse#0421",
			price = 300,

			description_locales = {
				en = "Only for the strongest kings!",
				fr = "Seulement pour les rois les plus fort !",
				br = "Apenas para os reis mais fortes!",
				ur = "Sab se bahadur badshah ke liye!"
			},

			skins = {
				[ENUM_ITEMS.CANNON] =  { image = "1754f9851c8.png", adj = { x = -17, y = -17 } },
				[ENUM_ITEMS.ANVIL] = { image = "1754f98d0b8.png", adj = { x = -24, y = -34 } },
				[ENUM_ITEMS.BALL] =  { image = "1754f9a7601.png", adj = { x = -16, y = -16 } },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "1754fca819f.png", adj = { x = -22, y = -22 } },
				[ENUM_ITEMS.LARGE_BOX] =  { image = "1754f9b87a6.png", adj = { x = -35, y = -35 } },
				[ENUM_ITEMS.SMALL_BOX] =  { image = "1754f9d18f6.png", adj = { x = -19, y = -19 } },
				[ENUM_ITEMS.LARGE_PLANK] =  { image = "1754f9d7544.png", adj = { x = -100, y = -10 } },
				[ENUM_ITEMS.SMALL_PLANK] =  { image = "1754f9dc2a0.png", adj = { x = -50, y = -10 } }
			}

		},

		["Halloween 2020"] = {
			coverImage = "175832f4631.png",
			coverAdj = { x = 8, y = 0 },
			description = "Trick or Treat!?",
			author = "Thetiger56#6961",
			price = 400,

			description_locales = {
				en = "Trick or Treat!?",
				fr = "Un bonbon ou un sort !?",
				br = "Gostosuras ou Travessuras?",
				ur = "Trick ya treat!?"
			},

			skins = {
				[ENUM_ITEMS.CANNON] =  { image = "175829957ec.png", adj = { x = -17, y = -17 } },
				[ENUM_ITEMS.ANVIL] = { image = "17582960dfd.png", adj = { x = -22, y = -24 } },
				[ENUM_ITEMS.BALL] =  { image = "17582965a03.png", adj = { x = -17, y = -19 } },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "1758295cf4b.png", adj = { x = -22, y = -22 } },
				[ENUM_ITEMS.LARGE_BOX] =  { image = "175829687b2.png", adj = { x = -32, y = -32 } },
				[ENUM_ITEMS.SMALL_BOX] =  { image = "1758296be0c.png", adj = { x = -19, y = -19 } },
				[ENUM_ITEMS.LARGE_PLANK] =  { image = "175829715e2.png", adj = { x = -100, y = -6 } },
				[ENUM_ITEMS.SMALL_PLANK] =  { image = "17582976871.png", adj = { x = -50, y = -13 } }
			}

		},

		["Christmas 2020"] = {
			coverImage = "1765abc248e.png",
			coverAdj = { x = 0, y = 0 },
			description = "Ho ho ho, Merry Christmas!!",
			author = "Thetiger56#6961",
			price = 400,

			description_locales = {
				en = "Ho ho ho, Merry Christmas!!",
				fr = "Ho ho Ho, Joyeux Noël !!",
				br = "Ho ho ho, Feliz Natal!!",
				ur = "Ho ho ho, Christmas mubarak!!"
			},

			skins = {
				[ENUM_ITEMS.CANNON] =  { image = "1765abff096.png", adj = { x = -17, y = -17 } },
				[ENUM_ITEMS.ANVIL] = { image = "1765ac2ed92.png", adj = { x = -24, y = -28 } },
				[ENUM_ITEMS.BALL] =  { image = "1765ac10519.png", adj = { x = -17, y = -18 } },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "17660481ac5.png", adj = { x = -25, y = -24 } },
				[ENUM_ITEMS.LARGE_BOX] =  { image = "1765aca14d3.png", adj = { x = -32, y = -32 } },
				[ENUM_ITEMS.SMALL_BOX] =  { image = "1765ad54bea.png", adj = { x = -17, y = -17 } },
				[ENUM_ITEMS.LARGE_PLANK] =  { image = "1765ad8d77d.png", adj = { x = -100, y = -17 } },
				[ENUM_ITEMS.SMALL_PLANK] =  { image = "1765ad9f608.png", adj = { x = -50, y = -18 } }
			}

		},


}

shop.totalPacks = 0
for pack in next, shop.packs do shop.totalPacks = shop.totalPacks + 1 end

shop.totalPages = math.ceil((shop.totalPacks) / 6)

shop.packsBitList = BitList {
	"Default", "Poisson", "Catto", "Royal", "Halloween 2020", "Christmas 2020"
}

shop.displayShop = function(target, page, keyPressed)
	page = page or 1
	if page < 1 or page > shop.totalPages then return end

	local targetPlayer = Player.players[target]

	local commu = targetPlayer.community

	if targetPlayer.openedWindow then
		targetPlayer.openedWindow:hide(target)
		if targetPlayer.openedWindow == shopWindow and keyPressed then
			targetPlayer.openedWindow = nil
			return
		end
	end

	shopWindow:show(target)
	shop.displayPackInfo(target, targetPlayer.equipped)

	Panel.panels[520]:update(translate("POINTS", commu, nil, { points = targetPlayer.points }), target)
	Panel.panels[551]:update(("<a href='event:%s'><p align='center'><b>%s〈%s</b></p></a>")
		:format(
			page - 1,
			page - 1 < 1 and "<N2>" or "",
			page - 1 < 1 and "</N2>" or ""
		)
	, target)
	Panel.panels[552]:update(("<a href='event:%s'><p align='center'><b>%s〉%s</b></p></a>")
		:format(
			page + 1,
			page + 1 > shop.totalPages and "<N2>" or "</N2>",
			page + 1 > shop.totalPages and "</N2>" or "</N2>"
		)
	, target)

	targetPlayer.openedWindow = shopWindow

	local col, row, count = 0, 0, 0

	for i = (page - 1) * 6 + 1, page * 6 do
		local name = i == 1 and "Random" or shop.packsBitList:get(i - 1)
		if not name then return	end

		local pack = shop.packs[name]
		local packPanel = Panel(560 + count, "", 380 + col * 120, 100 + row * 120, 100, 100, 0x1A3846, 0x1A3846, 1, true)
			:addImageTemp(Image(pack.coverImage, "&1", 400 + (pack.coverAdj and pack.coverAdj.x or 0) + col * 120, 100 + (pack.coverAdj and pack.coverAdj.y or 0) + row * 120, target), target)
			:addPanel(
				Panel(560 + count + 1, ("<p align='center'><a href='event:%s'>%s</a></p>"):format(name, name),  385 + col * 120, 170 + row * 120, 90, 20, nil, 0x324650, 1, true)
					:setActionListener(function(id, name, event)
						shop.displayPackInfo(name, event)
					end)
			)
		if not targetPlayer.packs[name] then packPanel:addImageTemp(Image(assets.lock, "&1", 380 + col * 120, 80 + row * 120, target), target) end

		shopWindow:addPanelTemp(packPanel, target)

		col = col + 1
		count = count + 2
		if col >= 3 then
			row = row + 1
			col = 0
		end
	end
end

shop.displayPackInfo = function(target, packName)

	local pack = shop.packs[packName]
	local player = Player.players[target]
	local commu = player.community

	Panel.panels[610]:hide(target):show(target)
	Panel.panels[620]:addImageTemp(Image(pack.coverImage, "&1", 80 + (pack.coverAdj and pack.coverAdj.x or 0), 80 + (pack.coverAdj and pack.coverAdj.y or 0), target), target)

	Panel.panels[620]:update(" <font size='15' face='Lucida console'><b><BV>" .. packName .. "</BV></b></font>", target)

	local hasEquipped = player.equipped == packName
	local hasBought = not not player.packs[packName]
	local hasRequiredPoints = player.points >= pack.price
	Panel.panels[650]:update(("<p align='center'><b><a href='event:%s:%s'>%s</a></b></p>")
		:format(
			hasEquipped and "none" or (hasBought and "equip" or (hasRequiredPoints and "buy" or "none")),
			packName,
			hasEquipped	and translate("EQUIPPED", commu)
			or (hasBought and translate("EQUIP", commu)
			or (hasRequiredPoints and (translate("BUY", commu) .. ": " .. pack.price)
			or ("<N2>" .. translate("BUY", commu) .. ": " .. pack.price .. "</N2>")
			)
			)
		)
	, target)

	local n, t = extractName(pack.author)
	Panel.panels[651]:update(translate("PACK_DESC", commu, nil,
		{
			desc = (pack.description_locales[commu] or pack.description),
			author = "<V>" .. n .. "</V><N2>" .. t .. "</N2>"
		}
	), target)

	Panel.panels[652]
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.CANNON].image or shop.defaultItemImages[ENUM_ITEMS.CANNON], "&1", 80, 160), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.ANVIL].image or shop.defaultItemImages[ENUM_ITEMS.ANVIL], "&1", 130, 150), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.BLUE_BALOON].image or shop.defaultItemImages[ENUM_ITEMS.BLUE_BALOON], "&1", 195, 160), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.BALL].image or shop.defaultItemImages[ENUM_ITEMS.BALL], "&1", 250, 160), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.LARGE_BOX].image or shop.defaultItemImages[ENUM_ITEMS.LARGE_BOX], "&1", 80, 220), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.SMALL_BOX].image or shop.defaultItemImages[ENUM_ITEMS.SMALL_BOX], "&1", 160, 220), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.LARGE_PLANK].image or shop.defaultItemImages[ENUM_ITEMS.LARGE_PLANK], "&1", 80, 300), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.SMALL_PLANK].image or shop.defaultItemImages[ENUM_ITEMS.SMALL_PLANK], "&1", 80, 320), target)


end

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
	tfm.exec.chatMessage(translate("NEW_ROLE", tfm.get.room.language, nil, { player = player.name, role = role }))
	player:savePlayerData()
end

roles.removeRole = function(player, role)
	player.roles[role] = nil
	player.highestRole = roles.getHighestRole(player)
	tfm.exec.setNameColor(player.name, 0) -- set it to default color in case of all the colors are removed
	setNameColor(player.name)
	tfm.exec.chatMessage(translate("KICK_ROLE", tfm.get.room.language, nil, { player = player.name, role = role }))
	player:savePlayerData()
end

roles.getHighestRole = function(player)
	for i, rank in next, roles.list.featureArray do
		if player.roles[rank] then return rank end
	end
	return "default"
end

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
			p(maps)
			local player = Player.players[author]
			if not (admins[author] or (player:hasRole("staff") and player:hasRole("mapper"))) then return end
			local res = "<b><BV>Current rotation:</BV></b> "
			for index, map in next, rotation do
				if index == currentMapIndex then
					res = res .. "<b><VP> &lt; @" .. map .. " &gt; </VP></b>, "
				else
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
			local player = Player.players[author]

			if not isTribeHouse then
				if not (admins[author] or (player:hasRole("staff") and player:hasRole("mapper"))) then
					return tfm.exec.chatMessage(translate("ERR_PERMS", player.community), author)
				end
			else
				if tfm.get.room.name:sub(2) ~= tfm.get.room.playerList[author].tribeName then
					return tfm.exec.chatMessage(translate("ERR_PERMS", player.community), author)
				end
			end

			local map = args[1]:match("@?(%d+)")
			if not map then return tfm.exec.chatMessage(translate("ERR_CMD", player.community, nil, { syntax = "!npp [@code]"}), author) end
			queuedMaps[#queuedMaps+1] = map
			tfm.exec.chatMessage(translate("MAP_QUEUED", tfm.get.room.language, nil, { map = map, player = author }), author)
		end,

		["addmap"] = function(args, msg, author)
			local player = Player.players[author]
			if not (admins[author] or (player:hasRole("staff") and player:hasRole("mapper"))) then return end
			if tfm.get.room.xmlMapInfo.permCode ~= 41 then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error:</b> Map should be P41</R>", author) end
			local map = tfm.get.room.xmlMapInfo.mapCode
			if isInRotation(map) then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error:</b> The  map is already in the rotation</R>", author) end
			maps.list[#maps.list + 1] = map
			maps.dumpCache = table.concat(maps.list, ",")
			maps.overwriteFile = true
			tfm.exec.chatMessage(
				("<N>[</N><R>•</R><N>] <N><ROSE><b>@%s</b></ROSE> [<ROSE><b>%s</b></ROSE>] has been added to the rotation. Please stay in the room for few minutes to save them properly.")
					:format(map, tfm.get.room.xmlMapInfo.author),
				author
			)
			leaderboardNotifyList[#leaderboardNotifyList + 1] = author
		end,

		["remmap"] = function(args, msg, author)
			local player = Player.players[author]
			if not (admins[author] or (player:hasRole("staff") and player:hasRole("mapper"))) then return end
			local map = args[1]:match("@?(%d+)")
			if not map then return tfm.exec.chatMessage(translate("ERR_CMD", target.community, nil, { syntax = "!remmap [@code]"}), author) end
			local isExisting, index = isInRotation(map)
			if not isExisting then return tfm.exec.chatMessage("<N>[</N><R>•</R><N>] <R><b>Error:</b> The map is not in the rotation</R>", author) end
			table.remove(maps.list, index)
			maps.dumpCache = table.concat(maps.list, ",")
			maps.overwriteFile = true
			tfm.exec.chatMessage(
				("<N>[</N><R>•</R><N>] <N><ROSE><b>@%s</b></ROSE> has been removed from the rotation. Please stay in the room for few minutes to save them properly.")
					:format(map),
				author
			)
			leaderboardNotifyList[#leaderboardNotifyList + 1] = author
		end

}

-- [[ aliases ]]
cmds["p"] = cmds["profile"]

shuffleMaps = function(maps)
	local res = {}
	local latest = {}
	for i = #maps, #maps - 20, -1 do
		local map = maps[i]
		latest[#latest + 1] = map
		res[#res + 1] = map
	end
	for _, map in next, maps do
		res[#res + 1] = map
		res[#res + 1] = map
	end
	table.sort(res, function(e1, e2)
		return math.random() <= 0.5
	end)
	for _, map in next, latest do
		table.insert(res, math.random(25), map)
	end
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

	Panel.panels[920]:update(translate("CREDITS", commu, nil, {
		artists = "<BV>Lightymouse</BV><G>#0421</G>",
		translators = "<BV>Overjoy06#0000</BV><G>#0000</G>, <BV>Nuttysquirrel</BV><G>#0626</G>, <BV>Star</BV><G>#6725</G>, <BV>Jaker</BV><G>#9310</G>, <BV>Santoex</BV><G>#0000</G>, <BV>Maha010</BV><G>#0000</G>"
	}), target)
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
							local key, value = table.unpack(stringutils.split(event, ":"))
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


