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

local VERSION = "v2.0.2.0"
local CHANGELOG =
[[

<p align='center'><font size='20'><b><V>CHANGELOG</V></b></font></p><font size='12' face='Lucide Console'>

    <font size='15' face='Lucida Console'><b><BV>v2.0.2.0</BV></b></font> <i>(10/13/2020)</i>
        • Added new translations
            - Added PH Translations <i>(thanks to <b><V>Overforyou</V><N><font size='8'>#9290</font></N></b>)</i>
            - Added PL Translations <i>(thanks to <b><V>Lightymouse</V><N><font size='8'>#0421</font></N></b>)</i>

        • Added the changelog menu
        • Added the discord link to the greeting mesesage


    <font size='15' face='Lucida Console'><b><BV>v2.0.1.0</BV></b></font> <i>(09/13/2020)</i>
        • Fixed the bug of choosing a random winner


    <font size='15' face='Lucida Console'><b><BV>v2.0.0.0</BV></b></font> <i>(09/09/2020)</i>
        Released an entirely new, rewritten version of #pewpew. Other than the original gameplay created by <b><V>Baasbase</V><font size='8'>#0095</font></b>, this version features

        • A new stat system
            - Profiles
            - Leaderboards

        • Cool and helpful indicators
            - Life count
            - Current item


</font>
]]

tfm.exec.disableAutoNewGame()
tfm.exec.disableAutoScore()
tfm.exec.disableAutoShaman()
tfm.exec.disableAutoTimeLeft()

local admins = {
    ["King_seniru#5890"] = true,
    ["Lightymouse#0421"] = true,
    ["Overforyou#9290"] = true
}

local maps = { 521833, 401421, 541917, 541928, 541936, 541943, 527935, 559634, 559644, 888052, 878047, 885641, 770600, 770656, 772172, 891472, 589736, 589800, 589708, 900012, 901062, 754380, 901337, 901411, 892660, 907870, 910078, 1190467, 1252043, 1124380, 1016258, 1252299, 1255902, 1256808, 986790, 1285380, 1271249, 1255944, 1255983, 1085344, 1273114, 1276664, 1279258, 1286824, 1280135, 1280342, 1284861, 1287556, 1057753, 1196679, 1288489, 1292983, 1298164, 1298521, 1293189, 1296949, 1308378, 1311136, 1314419, 1314982, 1318248, 1312411, 1312589, 1312845, 1312933, 1313969, 1338762, 1339474, 1349878, 1297154, 644588, 1351237, 1354040, 1354375, 1362386, 1283234, 1370578, 1306592, 1360889, 1362753, 1408124, 1407949, 1407849, 1343986, 1408028, 1441370, 1443416, 1389255, 1427349, 1450527, 1424739, 869836, 1459902, 1392993, 1426457, 1542824, 1533474, 1561467, 1563534, 1566991, 1587241, 1416119, 1596270, 1601580, 1525751, 1582146, 1558167, 1420943, 1466487, 1642575, 1648013, 1646094, 1393097, 1643446, 1545219, 1583484, 1613092, 1627981, 1633374, 1633277, 1633251, 1585138, 1624034, 1616785, 1625916, 1667582, 1666996, 1675013, 1675316, 1531316, 1665413, 1681719, 1699880, 1688696, 623770, 1727243, 1531329, 1683915, 1689533, 1738601, 3756146, 7742371, 7781585, 7781591 }

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
    lock = "1660271f4c6.png",
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
    }
})

local MIN_PLAYERS = 4

local profileWindow, leaderboardWindow, changelogWindow, shopWindow

local initialized, newRoundStarted, suddenDeath = false
local currentItem = ENUM_ITEMS.CANNON
local isTribeHouse = tfm.get.room.isTribeHouse
local statsEnabled = not isTribeHouse

local leaderboard, shop


--==[[ translations ]]==--

local translations = {}

translations["en"] = {	
	LIVES_LEFT = "<ROSE>You have <N>${lives} <ROSE>lives left. <VI>Respawning in 3...",	
	LOST_ALL =	"<ROSE>You have lost all your lives!",	
	SD =		"<VP>Sudden death! Everyone has <N>1 <VP>life left",	
	WELCOME =	"<VP>Welcome to pewpew, <N>duck <VP>or <N>spacebar <VP>to shoot items!",	
    SOLE =		"<ROSE>${player} is the sole survivor!",
    SURVIVORS = "<ROSE>${winners} and ${winner} survived their lives this round!",
    SELF_RANK = "<p align='center'>Your rank: ${rank}</p>",
    ROUNDS  =   "<font face='Lucida console'><N2>Rounds played</N2></font>",
    DEATHS =    "<font face='Lucida console'><N2>Deaths</N2></font>",
    SURVIVED =  "<font face='Lucida console'><N2>Rounds survived</N2></font>",
    WON =       "<font face='Lucida console'><N2>Rounds won</N2></font>",
    EQUIPPED =  "Equipped",
    EQUIP =     "Equip",
    BUY =       "Buy",
    POINTS =    "<font face='Lucida console' size='12'>   <b>Points:</b> <V>${points}</V></font>",
    PACK_DESC = "\n\n<font face='Lucida console' size='12' color='#cccccc'><i>“ ${desc} ”</i></font>\n<p align='right'><font size='10'>- ${author}</font></p>",
    GIFT_RECV = "<N>You have been rewarded with <ROSE><b>${gift}</b></ROSE> by <ROSE><b>${admin}</b></ROSE>"
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

translations["ph"] = {
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
	self.community = tfm.get.room.playerList[name].community
	self.hearts = {}

	self.rounds = 0
	self.survived = 0
	self.won = 0
	self.score = 0
	self.points = 0
	self.packs = 1
	self.equipped = 1

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

		local object = tfm.exec.addShamanObject(
			currentItem,
			x + pos.x,
			y + pos.y,
			rot,
			stance == -1 and -xSpeed or xSpeed,
			0,
			currentItem == 32 or currentItem == 62
		)

		local equippedPack = shop.packs[self.equipped]
		local skin = equippedPack.skins[currentItem]
		if self.equipped ~= "Default" and skin and skin.image then
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
		tfm.exec.chatMessage(translate("SOLE", tfm.get.room.community, nil, {player = "<b><VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font></b>"}))
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

function Player:savePlayerData()
	-- if tfm.get.room.uniquePlayers < MIN_PLAYERS then return end
	local name = self.name
    dHandler:set(name, "rounds", self.rounds)
    dHandler:set(name, "survived", self.survived)
	dHandler:set(name, "won", self.won)
	dHandler:set(name, "points", self.points)
	dHandler:set(name, "packs", shop.packsBitList:encode(self.packs))
	dHandler:set(name, "equipped", shop.packsBitList:find(self.equipped))
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
    -- statsEnabled = (not isTribeHouse) and tfm.get.room.uniquePlayers >= 4
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
                tfm.exec.chatMessage(translate("SURVIVORS", tfm.get.room.community, nil, { winners = winners, winner = winner }))
			end
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
        displayHelp(name)
    elseif key == keys.LETTER_P then
        displayProfile(Player.players[name], name)
    elseif key == keys.LETTER_L then
        leaderboard.displayLeaderboard("global", 1, name)
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

	Player.players[name].rounds = dHandler:get(name, "rounds")
	Player.players[name].survived = dHandler:get(name, "survived")
    Player.players[name].won = dHandler:get(name, "won")
    Player.players[name].points = dHandler:get(name, "points")
    Player.players[name].packs = shop.packsBitList:decode(dHandler:get(name, "packs"))
    Player.players[name].equipped = shop.packsBitList:get(dHandler:get(name, "equipped"))

end

function eventFileLoaded(id, data)
	-- print(table.tostring(leaderboard.leaders))
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
		print("[STATS] Leaderboard data loaded!")
		if not (leaderboard.leaderboardData == data) then
			leaderboard.leaderboardData = data
			leaderboard.leaders = leaderboard.parseLeaderboard(data)
		end
		for name, player in next, Player.players do leaderboard.addPlayer(player) end
		leaderboard.save(leaderboard.leaders)
	end
end

function eventFileSaved(id)
	if id == leaderboard.FILE_ID or id == tostring(leaderboard.FILE_ID) then
        print("[STATS] Leaderboard saved!")
        print(os.time())
		leaderboard.needUpdate = false
	end
end

function eventChatCommand(name, cmd)
	local args = string.split(cmd, " ")
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

leaderboard.FILE_ID = 1
leaderboard.DUMMY_DATA = [[*souris1,0,0,0,xx|*souris2,0,0,0,xx|*souris3,0,0,0,xx|*souris4,0,0,0,xx|*souris5,0,0,0,xx|*souris6,0,0,0,xx|*souris7,0,0,0,xx|*souris8,0,0,0,xx|*souris9,0,0,0,xx|*souris10,0,0,0,xx|*souris11,0,0,0,xx|*souris12,0,0,0,xx|*souris13,0,0,0,xx|*souris14,0,0,0,xx|*souris15,0,0,0,xx|*souris16,0,0,0,xx|*souris17,0,0,0,xx|*souris18,0,0,0,xx|*souris19,0,0,0,xx|*souris20,0,0,0,xx|*souris21,0,0,0,xx|*souris22,0,0,0,xx|*souris23,0,0,0,xx|*souris24,0,0,0,xx|*souris25,0,0,0,xx|*souris26,0,0,0,xx|*souris27,0,0,0,xx|*souris28,0,0,0,xx|*souris29,0,0,0,xx|*souris30,0,0,0,xx|*souris31,0,0,0,xx|*souris32,0,0,0,xx|*souris33,0,0,0,xx|*souris34,0,0,0,xx|*souris35,0,0,0,xx|*souris36,0,0,0,xx|*souris37,0,0,0,xx|*souris38,0,0,0,xx|*souris39,0,0,0,xx|*souris40,0,0,0,xx|*souris41,0,0,0,xx|*souris42,0,0,0,xx|*souris43,0,0,0,xx|*souris44,0,0,0,xx|*souris45,0,0,0,xx|*souris46,0,0,0,xx|*souris47,0,0,0,xx|*souris48,0,0,0,xx|*souris49,0,0,0,xx|*souris50,0,0,0,xx]]

leaderboard.needUpdate = false
leaderboard.indexed = {}
leaderboard.leaderboardData = leaderboard.leaderboardData or leaderboard.DUMMY_DATA

leaderboard.parseLeaderboard = function(data)
	local res = {}
  	for i, entry in next, string.split(data, "|") do
		local fields = string.split(entry, ",")
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

leaderboard.save = function(leaders)
	local serialised, indexes = leaderboard.prepare(leaders)
	if serialised == leaderboard.leaderboardData then return end
	leaderboard.indexed = indexes
    if tfm.get.room.uniquePlayers < 4 then return end
	local started = system.saveFile(serialised, leaderboard.FILE_ID)
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
    
	for name, leader in next, leaders do temp[#temp + 1] = leader end
    
	table.sort(temp, function(p1, p2)
		return p1.score > p2.score
    end)
    
    for i = 1, 50 do res[i] = temp[i] end
    
	return leaderboard.dumpLeaderboard(res), res

end

leaderboard.displayLeaderboard = function(mode, page, target)
    local targetPlayer = Player.players[target]
    if targetPlayer.openedWindow then targetPlayer.openedWindow:hide(target) end
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
		survivedTxt = survivedTxt .. leader.survived .. " <V><i>(" .. math.floor(leader.survived / (leader.rounds == 0 and 1 or leader.rounds) * 100) .. " %)</i></V><br>"
		wonTxt = wonTxt .. leader.won .. " <V><i>(" .. math.floor(leader.won / (leader.rounds == 0 and 1 or leader.rounds) * 100) .. " %)</i></V><br>"
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

	["Default"] = {
		coverImage = "17404561700.png",
		description = "Default item pack",
		author = "Transformice",
		price = 0,

		description_locales = {
			en = "Default item pack"
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

	["Retro"] = {
		coverImage = "17404561700.png",
		description = "Back in old days...",
		author = "Transformice",
		price = 10,

		description_locales = {
			en = "Back in old days..."
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
		coverImage = "17404561700.png",
		description = "Meow!",
		author = "King_seniru#5890",
		price = 10,

		description_locales = {
			en = "Meow!"
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

	["Dummy 1"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 2"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 3"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 4"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 5"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 6"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 7"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 8"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 9"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 10"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 11"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	},

	["Dummy 12"] = {
		coverImage = assets.dummy,
		description = "Dummy",
		author = "-",
		price = 10000,

		description_locales = {
			en = "Dummy"
		},

		skins = {}

	}


}

shop.totalPacks = 0
for pack in next, shop.packs do shop.totalPacks = shop.totalPacks + 1 end

shop.totalPages = math.ceil(shop.totalPacks / 6)

shop.packsBitList = BitList {
    "Default", "Retro", "Catto", "Dummy 1", "Dummy 2", "Dummy 3", "Dummy 4", "Dummy 5", "Dummy 6", "Dummy 7", "Dummy 8", "Dummy 9", "Dummy 10", "Dummy 11", "Dummy 12"
}

shop.displayShop = function(target, page)
	page = page or 1
	if page < 1 or page > shop.totalPages then return end

	local targetPlayer = Player.players[target]
	local commu = targetPlayer.community
    if targetPlayer.openedWindow then targetPlayer.openedWindow:hide(target) end
	shopWindow:show(target)
	shop.displayPackInfo(target, "Default")

	Panel.panels[520]:update(translate("POINTS", commu, nil, { points = targetPlayer.points }), target)
	Panel.panels[653]:update(("<a href='event:%s'><p align='center'><b>%s〈%s</b></p></a>")
		:format(
			page - 1,
			page - 1 < 1 and "<N2>" or "",
			page - 1 < 1 and "</N2>" or ""
		)
	, target)
	Panel.panels[654]:update(("<a href='event:%s'><p align='center'><b>%s〉%s</b></p></a>")
		:format(
			page + 1,
			page + 1 > shop.totalPages and "<N2>" or "</N2>",
			page + 1 > shop.totalPages and "</N2>" or "</N2>"
		)
	, target)

	targetPlayer.openedWindow = shopWindow

    local col, row, count = 0, 0, 0
	-- for _, name in next, shop.packsBitList.featureArray do
	for i = (page - 1) * 6 + 1, page * 6 do

		local name = shop.packsBitList:get(i)
		if not name then return	end

		local pack = shop.packs[name]
		local packPanel = Panel(560 + count, "", 380 + col * 120, 100 + row * 120, 100, 100, 0x1A3846, 0x1A3846, 1, true)
			:addImageTemp(Image(pack.coverImage, "&1", 400 + col * 120, 100 + row * 120, target), target)
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

	Panel.panels[620]:addImageTemp(Image(pack.coverImage, "&1", 80, 80, target), target)

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

	Panel.panels[652]:hide(target)
	Panel.panels[652]:show(target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.CANNON].image or shop.defaultItemImages[ENUM_ITEMS.CANNON], "&1", 80, 160), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.ANVIL].image or shop.defaultItemImages[ENUM_ITEMS.ANVIL], "&1", 130, 150), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.BLUE_BALOON].image or shop.defaultItemImages[ENUM_ITEMS.BLUE_BALOON], "&1", 195, 160), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.BALL].image or shop.defaultItemImages[ENUM_ITEMS.BALL], "&1", 250, 160), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.LARGE_BOX].image or shop.defaultItemImages[ENUM_ITEMS.LARGE_BOX], "&1", 80, 220), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.SMALL_BOX].image or shop.defaultItemImages[ENUM_ITEMS.SMALL_BOX], "&1", 160, 220), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.LARGE_PLANK].image or shop.defaultItemImages[ENUM_ITEMS.LARGE_PLANK], "&1", 80, 300), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.SMALL_PLANK].image or shop.defaultItemImages[ENUM_ITEMS.SMALL_PLANK], "&1", 80, 320), target)


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
            tfm.exec.chatMessage(("<N>[</N><ROSE>•</ROSE><N>] Rewarded <ROSE>%s</ROSE> with <ROSE>%s</ROSE> points"):format(args[2], points))
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
            tfm.exec.chatMessage(("<N>[</N><ROSE>•</ROSE><N>] Rewarded <ROSE>%s</ROSE> with <ROSE>%s</ROSE>"):format(args[2], pack))
            tfm.exec.chatMessage(translate("GIFT_RECV", target.community, nil, {
                admin = "<VI>" .. n .. "</VI><font size='8'><N2>" .. t .. "</N2></font>",
                gift = pack
            }), args[2])
        else
            tfm.exec.chatMessage(FORMAT_ERR_MSG, author)
        end

    end

}

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

    newRoundStarted = false
    suddenDeath = false
    currentMapIndex = next(rotation, currentMapIndex)
    statsEnabled = (not isTribeHouse) and tfm.get.room.uniquePlayers >= MIN_PLAYERS


    tfm.exec.newGame(rotation[currentMapIndex])
    tfm.exec.setGameTime(93, true)

    Player.alive = {}
    Player.aliveCount = 0

    for name, player in next, Player.players do player:refresh() end

    if currentMapIndex >= #rotation then
        rotation = shuffleMaps(maps)
        currentMapIndex = 1
    end

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

displayProfile = function(player, target)
    local targetPlayer = Player.players[target]
    if targetPlayer.openedWindow then targetPlayer.openedWindow:hide(target) end
    local name, tag = extractName(player.name)
    if (not name) or (not tag) then return end -- guest players
    profileWindow:show(target)
    Panel.panels[220]:update("<b><font size='20'><V>" .. name .. "</V></font><font size='10'><G>" .. tag, target)
    Panel.panels[151]:update(translate("ROUNDS", player.community) .. "<br><b><BV><font size='14'>" .. player.rounds .. "</font></BV>", target)
    Panel.panels[152]:update(translate("DEATHS", player.community) .. "<br><b><BV><font size='14'>" .. player.rounds - player.survived .. "</font></BV>", target)
    Panel.panels[153]:update(translate("SURVIVED", player.community) .. "<br><b><BV><font size='14'>" .. player.survived .. "</font></BV>     <font size='10'>(" .. math.floor(player.survived / player.rounds * 100) .."%)</font>", target)
    Panel.panels[154]:update(translate("WON", player.community) .. "<br><b><BV><font size='14'>" .. player.won .. "</font></BV>     <font size='10'>(" .. math.floor(player.won / player.rounds * 100) .."%)</font>", target)
    targetPlayer.openedWindow = profileWindow
end

displayHelp = function(target)
    tfm.exec.chatMessage("<br>" .. translate("WELCOME", tfm.get.room.playerList[target].community), target)
    tfm.exec.chatMessage("<N>Report any bug to </N><VP>King_seniru</VP><G>#5890</G><br><br><b><VI>Commands</VI></b><br><br>[ <b>H</b> ] <N><ROSE>!help</ROSE> (displays this help menu)</N><br>[ <b>P</b> ] <N><ROSE>!profile <i>[player]</i></ROSE> (displays the profile of the player)</N><br>[ <b>L</b> ] <N>(displays the leaderboard)</N><br><br><N><ROSE>!changelog</ROSE> (displays the changelog)</N><br>", target)
end

displayChangelog = function(target)
    local targetPlayer = Player.players[target]
    if targetPlayer.openedWindow then targetPlayer.openedWindow:hide(target) end
    changelogWindow:show(target)
    targetPlayer.openedWindow = changelogWindow
end


do

    rotation = shuffleMaps(maps)
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
        :addPanel(Panel(450, CHANGELOG, 70, 50, 670, 330, nil, nil, 0, true))
        :addImage(Image(assets.widgets.scrollbarBg, "&1", 720, 80))
        :addImage(Image(assets.widgets.scrollbarFg, "&1", 720, 90))

    shopWindow = createPrettyUI(5, 360, 50, 380, 330, true, true) -- main shop window
        :addPanel(  -- preview window
            createPrettyUI(6, 70, 50, 260, 330, true, false)
                :addPanel(
                    Panel(650, "", 80, 350, 240, 20, nil, 0x324650, 1, true)
                        :setActionListener(function(id, name, event)
                            local key, value = table.unpack(string.split(event, ":"))
                            local player = Player.players[name]
                            local pack = shop.packs[value]
                            if not pack then return end
                            if key == "buy" then
                                -- Exit if the player already have the pack or if they dont have the required points
                                if player.packs[value] or player.points < pack.price then return end
                                player.packs[value] = true
                                player.equipped = value
                                player.points = player.points - pack.price
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
                :addPanel(
                    Panel(653, "〈", 620, 350, 40, 20, nil, 0x324650, 1, true)
                        :setActionListener(function(id, name, event)
                            shop.displayShop(name, tonumber(event))
                        end)
                )
                :addPanel(
                    Panel(654, "〉", 680, 350, 40, 20, nil, 0x324650, 1, true)
                        :setActionListener(function(id, name, event)
                            shop.displayShop(name, tonumber(event))
                        end)
                )
        )

end


