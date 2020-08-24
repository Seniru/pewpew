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
        }, Panel)

        Panel.panels[id] = self

        return self

    end

    function Panel.handleActions(id, name, event)
        local panelId = id - 10000
        local panel = Panel.panels[panelId]
        if not panel then return print("no panel") end
        if panel.isCloseButton then
            print("is close button")
            if not panel.closeTarget then return print("no close target") end
            panel.closeTarget:hide(name)
        else
            if panel.onhide then panel.onhide(id, name, event) end
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
            for id, panel in next, self.children do
				panel:hide(name)
				print(name)
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
