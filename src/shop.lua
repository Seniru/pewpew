shop = {}
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
			[ENUM_ITEMS.CANNON] = "1752b1c10bc.png",
			[ENUM_ITEMS.ANVIL] = "1752b1b9497.png",
			[ENUM_ITEMS.BALL] = "1752b1bdeee.png",
			[ENUM_ITEMS.BLUE_BALOON] = "1752b1aa57c.png",
			[ENUM_ITEMS.LARGE_BOX] = "1752b1adb5e.png",
			[ENUM_ITEMS.SMALL_BOX] = "1752b1b1cc6.png",
			[ENUM_ITEMS.LARGE_PLANK] = "1752b1b5ac3.png",
			[ENUM_ITEMS.SMALL_PLANK] = "1752b0918ed.png"
		}
	},

	["Retro"] = {
		coverImage = "17404561700.png",
		description = "Back in old days...",
		author = "Transformice",
		price = 100,

		description_locales = {
			en = "Back in old days..."
		},

		skins = {
			[ENUM_ITEMS.CANNON] = "174bb44115d.png",
			[ENUM_ITEMS.BALL] = "174bb405fd4.png",
			[ENUM_ITEMS.LARGE_BOX] = "174c530f384.png",
			[ENUM_ITEMS.SMALL_BOX] = "174c532630c.png",
			[ENUM_ITEMS.LARGE_PLANK] = "174c5311ea4.png",
			[ENUM_ITEMS.SMALL_PLANK] = "174c5324b9b.png"
		}

    },

    ["Catto"] = {
        coverImage = "17404561700.png",
		description = "Meow!",
		author = "King_seniru#5890",
		price = 20,
		
		skins = {
			[ENUM_ITEMS.SMALL_BOX] = "17404561700.png",
			[ENUM_ITEMS.LARGE_BOX] = "17404561700.png",
			[ENUM_ITEMS.SMALL_PLANK] = "17404561700.png"
		}
	},
	
	["Parkour Pigs"] = {
		coverImage = "17404561700.png",
		description = "Thanks to Tocu!",
		author = "Tocutoeltuco#0000",
		price = 10,

		skins = {
			[ENUM_ITEMS.SMALL_BOX] = "17404561700.png",
			[ENUM_ITEMS.LARGE_BOX] = "17404561700.png",
			[ENUM_ITEMS.SMALL_PLANK] = "17404561700.png",
			[ENUM_ITEMS.LARGE_PLANK] = "17404561700.png",
			[ENUM_ITEMS.BALL] = "17404561700.png",
			[ENUM_ITEMS.ANVIL] = "17404561700.png",
			[ENUM_ITEMS.CANNON] = "17404561700.png",
			[ENUM_ITEMS.BOMB] = "17404561700.png",
			[ENUM_ITEMS.BLUE_BALOON] = "17404561700.png"
		}
	}

}

shop.totalPacks = 0
for pack in next, shop.packs do shop.totalPacks = shop.totalPacks + 1 end

shop.packsBitList = BitList {
    "Default", "Retro", "Catto", "Parkour Pigs"
}

shop.displayShop = function(target, page)
    page = page or 1
    
    local targetPlayer = Player.players[target]
    if targetPlayer.openedWindow then targetPlayer.openedWindow:hide(target) end
	shopWindow:show(target)
	shop.displayPackInfo(target, "Default")

    Panel.panels[520]:update(([[
        Points: %s
    %s
    ]]):format(targetPlayer.points, ""), target)

    local col, row, count = 0, 0, 0

	for _, name in next, shop.packsBitList.featureArray do

        local pack = shop.packs[name]
        shopWindow:addPanelTemp(
			Panel(560 + count, "", 380 + col * 120, 100 + row * 120, 100, 100, 0x1A3846, 0x1A3846, 1, true)
				:addImageTemp(Image(pack.coverImage, "&1", 400 + col * 120, 100 + row * 120, target), target)
				:addPanel(
					Panel(560 + count + 1, ("<p align='center'><a href='event:%s'>%s</a></p>"):format(name, name),  385 + col * 120, 170 + row * 120, 90, 20, nil, 0x324650, 1, true)
						:setActionListener(function(id, name, event)
							shop.displayPackInfo(name, event)
						end)
				), target)

		col = col + 1
		count = count + 2
		if col >= 3 then
			row = row + 1
			col = 0
		end

    end

    targetPlayer.openedWindow = shopWindow
end

-- TODO: Add translations
shop.displayPackInfo = function(target, packName)

	local pack = shop.packs[packName]

	Panel.panels[620]:addImageTemp(Image(pack.coverImage, "&1", 80, 80, target), target)

	Panel.panels[620]:update(packName, target)
	Panel.panels[650]:update("Buy " .. pack.price, target)
	-- TODO: Replace description with description_locales[lang]
	Panel.panels[651]:update(pack.description .. "\n" .. pack.author, target)

	Panel.panels[652]:hide(target)
	Panel.panels[652]:show(target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.CANNON], "&1", 80, 160), target)	
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.ANVIL], "&1", 130, 150), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.BLUE_BALOON], "&1", 200, 160), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.BALL], "&1", 250, 160), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.LARGE_BOX], "&1", 80, 220), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.SMALL_BOX], "&1", 160, 220), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.LARGE_PLANK], "&1", 80, 300), target)
		:addImageTemp(Image(pack.skins[ENUM_ITEMS.SMALL_PLANK], "&1", 80, 320), target)

end
