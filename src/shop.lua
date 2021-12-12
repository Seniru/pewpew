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

		["Fast Food"] = {
			coverImage = "1765abc248e.png",
			coverAdj = { x = 0, y = 0 },
			description = "Fast food",
			author = "Transformice",
			price = 300,

			description_locales = {
				en = "Fast food",
			},

			skins = {
				[ENUM_ITEMS.CANNON] =  { image = "17d3c95486b.png", id = 1723 },
				[ENUM_ITEMS.ANVIL] = { image = "17d3c952d71.png", id = 1011 },
				[ENUM_ITEMS.BALL] =  { image = "17d3c95133a.png", id = 623 },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "17d3c957551.png", id = 2830 },
				[ENUM_ITEMS.LARGE_BOX] =  { image = "17d3c94b6b3.png", id = 229 },
				[ENUM_ITEMS.SMALL_BOX] =  { image = "17d3c947c84.png", id = 125 },
				[ENUM_ITEMS.LARGE_PLANK] =  { image = "17d3c94f5cd.png", id = 428 },
				[ENUM_ITEMS.SMALL_PLANK] =  { image = "17d3c94d6fb.png", id = 325 }
			}

		},

		["Pirate"] = {
			coverImage = "1765abc248e.png",
			coverAdj = { x = 0, y = 0 },
			description = "Ahoy!",
			author = "Transformice",
			price = 300,

			description_locales = {
				en = "Ahoy!",
			},

			skins = {
				[ENUM_ITEMS.CANNON] =  { image = "17d3cb1161a.png", id = 1733 },
				[ENUM_ITEMS.ANVIL] = { image = "17d3cb0f1c1.png", id = 1018 },
				[ENUM_ITEMS.BALL] =  { image = "17d3cb0c5c7.png", id = 632 },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "17d3cb13b9f.png", id = 2839 },
				[ENUM_ITEMS.LARGE_BOX] =  { image = "17d3cb040a4.png", id = 240 },
				[ENUM_ITEMS.SMALL_BOX] =  { image = "17d3cb08651.png", id = 137 },
				[ENUM_ITEMS.LARGE_PLANK] =  { image = "17d3cb0a590.png", id = 438 },
				[ENUM_ITEMS.SMALL_PLANK] =  { image = "17d3cb05f0f.png", id = 335 }
			}

		},


		["Derpy"] = {
			coverImage = "17dae029cb3.png",
			coverAdj = { x = 10, y = 2 },
			description = "*_*",
			author = "Transformice",
			price = 300,

			description_locales = {
				en = "*_*",
			},

			skins = {
				[ENUM_ITEMS.CANNON] =  { },
				[ENUM_ITEMS.ANVIL] = { },
				[ENUM_ITEMS.BALL] =  { image = "17dae02380f.png", id = 633 },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "17dae029cb3.png", id = 2840 },
				[ENUM_ITEMS.LARGE_BOX] =  { },
				[ENUM_ITEMS.SMALL_BOX] =  { },
				[ENUM_ITEMS.LARGE_PLANK] =  { image = "17dae01648d.png", id = 439 },
				[ENUM_ITEMS.SMALL_PLANK] =  { image = "17dae01dc22.png", id = 336 }
			}

		},

		["The Spook"] = {
			coverImage = "1765abc248e.png",
			coverAdj = { x = 0, y = 0 },
			description = "It's really spooky...",
			author = "Transformice",
			price = 300,

			description_locales = {
				en = "It's really spooky...",
			},

			skins = {
				[ENUM_ITEMS.CANNON] =  { image = "17dae1324a0.png", id = 1734 },
				[ENUM_ITEMS.ANVIL] = { image = "17dae14380b.png", id = 1005 },
				[ENUM_ITEMS.BALL] =  { image = "17dae15686c.png", id = 602 },
				[ENUM_ITEMS.BLUE_BALOON] = { image = "17dae16cbcc.png", id = 2824 },
				[ENUM_ITEMS.LARGE_BOX] =  { image = "17dae17c63a.png", id = 204 },
				[ENUM_ITEMS.SMALL_BOX] =  { image = "17dae121e30.png", id = 107 },
				[ENUM_ITEMS.LARGE_PLANK] =  { image = "17dae1a5ef3.png", id = 404 },
				[ENUM_ITEMS.SMALL_PLANK] =  { image = "17dae1ad746.png", id = 303 }
			}

		},

}

shop.totalPacks = 0
for pack in next, shop.packs do shop.totalPacks = shop.totalPacks + 1 end

shop.totalPages = math.ceil((shop.totalPacks) / 6)

shop.packsBitList = BitList {
	"Default", "Poisson", "Catto", "Royal", "Halloween 2020", "Christmas 2020", "Fast Food", "Pirate", "Derpy", "The Spook"
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
