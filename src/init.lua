local VERSION = "v2.2.2.1"
local CHANGELOG =
[[

<p align='center'><font size='20'><b><V>CHANGELOG</V></b></font> <BV><a href='event:log'>[View all]</a></BV></p><font size='12' face='Lucide Console'>

    <font size='15' face='Lucida Console'><b><BV>v2.2.2.1</BV></b></font> <i>(11/11/2020)</i>
        • Bug fixes
            - Leaderboard will get closed if attempted to change modes or pages

        • Toggle visibility of windows (shop, leaderboard, profile and help only) only if the hotkey is pressed


    <font size='15' face='Lucida Console'><b><BV>v2.2.2.0</BV></b></font> <i>(11/10/2020)</i>
        • Toggle visiblity of windows when a request to open/close received (for example click O to open shop, and press O back to hide it)


    <font size='15' face='Lucida Console'><b><BV>v2.2.1.1</BV></b></font> <i>(11/10/2020)</i>
        • Added new maps


    <font size='15' face='Lucida Console'><b><BV>v2.2.1.0</BV></b></font> <i>(11/8/2020)</i>
        • Bind key O for the shop (press O to open the shop now ;P)


    <font size='15' face='Lucida Console'><b><BV>v2.2.0.0</BV></b></font> <i>(11/2/2020)</i>
        • Improve the help's user interface
        • Support translations for the help menu
        • Minor typo fixes

        
    <font size='15' face='Lucida Console'><b><BV>v2.1.1.2</BV></b></font> <i>(11/1/2020)</i>
        • Added Halloween 2020 kit <i>(by <b><V>Thetiger56</V><N><font size='8'>#6961</font></N></b>)</i>
            - Get it before the sale ends :P
    

    <font size='15' face='Lucida Console'><b><BV>v2.1.1.1</BV></b></font> <i>(10/31/2020)</i>
        • Bug fixes
            - Any player can use any pack using the "Random" pack even if they haven't bought it

            
    <font size='15' face='Lucida Console'><b><BV>v2.1.1.0</BV></b></font> <i>(10/28/2020)</i>
        • Add the "random" pack (chooses a random pack from owned pack each round)
        • Display the current equipped pack in the pack preview menu (when opening the shop)
        • New maps!
        
        
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

local maps = { 521833, 401421, 541917, 541928, 541936, 541943, 527935, 559634, 559644, 888052, 878047, 885641, 770600, 770656, 772172, 891472, 589736, 589800, 589708, 900012, 901062, 754380, 901337, 901411, 892660, 907870, 910078, 1190467, 1252043, 1124380, 1016258, 1252299, 1255902, 1256808, 986790, 1285380, 1271249, 1255944, 1255983, 1085344, 1273114, 1276664, 1279258, 1286824, 1280135, 1280342, 1284861, 1287556, 1057753, 1196679, 1288489, 1292983, 1298164, 1298521, 1293189, 1296949, 1308378, 1311136, 1314419, 1314982, 1318248, 1312411, 1312589, 1312845, 1312933, 1313969, 1338762, 1339474, 1349878, 1297154, 644588, 1351237, 1354040, 1354375, 1362386, 1283234, 1370578, 1306592, 1360889, 1362753, 1408124, 1407949, 1407849, 1343986, 1408028, 1441370, 1443416, 1389255, 1427349, 1450527, 1424739, 869836, 1459902, 1392993, 1426457, 1542824, 1533474, 1561467, 1563534, 1566991, 1587241, 1416119, 1596270, 1601580, 1525751, 1582146, 1558167, 1420943, 1466487, 1642575, 1648013, 1646094, 1393097, 1643446, 1545219, 1583484, 1613092, 1627981, 1633374, 1633277, 1633251, 1585138, 1624034, 1616785, 1625916, 1667582, 1666996, 1675013, 1675316, 1531316, 1665413, 1681719, 1699880, 1688696, 623770, 1727243, 1531329, 1683915, 1689533, 1738601, 3756146, 7742371, 7781585, 7781591, 7791374, 7703556, 7795263, 7712465, 7712471, 7716829 }

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
    lock = "1660271f4c6.png",
    help = {
        survive = "17587d5abed.png",
        killAll = "17587d5ca0e.png",
        shoot = "17587d6acaf.png",
        creditors = "17587d609f1.png",
        commands = "17587d64557.png",
        weapon = "17587d67562.png"
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
    }
})

local MIN_PLAYERS = 4

local profileWindow, leaderboardWindow, changelogWindow, shopWindow, helpWindow

local initialized, newRoundStarted, suddenDeath = false
local currentItem = ENUM_ITEMS.CANNON
local isTribeHouse = tfm.get.room.isTribeHouse
local statsEnabled = not isTribeHouse

local leaderboard, shop
