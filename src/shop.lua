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
