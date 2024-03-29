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
	["Sannntos#0000"] = true,
	["Bofmfodo#1438"] = true,
	["Rimuru#7401"] = true
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
	LETTER_U	= 85
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
		int= "1651b327097.png",
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
		pl = "1651b31e0cf.png",
		pt = "1651b3019c0.png",
		ro = "1651b31f950.png",
		ru = "1651b321113.png",
		tg = "1651b31c891.png",
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
	},
	version = {
		index = 8,
		type = "string",
		default = "v0.0.0.0"
	}
})

local MIN_PLAYERS = 4

local profileWindow, leaderboardWindow, changelogWindow, shopWindow, helpWindow

local initialized, newRoundStarted, suddenDeath = false, false, false
local currentItem = ENUM_ITEMS.CANNON
local isTribeHouse = tfm.get.room.isTribeHouse
local statsEnabled = not isTribeHouse
local rotation, queuedMaps, currentMapIndex = {}, {}, 0
local mapProps = { allowed = nil, restricted = nil, grey = nil, items = items, fromQueue = false }
local leaderboardNotifyList, specWaitingList = {}, {}

local leaderboard, shop, roles
