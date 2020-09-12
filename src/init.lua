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
    items = {
        [1] = "17406985997.png", -- small box
        [2] = "174068e3bca.png", -- large box
        [3] = "174069a972e.png", -- small plank
        [4] = "174069c5a7a.png", -- large plank
        [6] = "174069d7a29.png", -- ball
        [10] = "174069e766a.png", -- anvil
        [17] = "17406bf2f70.png", -- cannon
        [23] = "17406bf6ffc.png", -- bomb
        [24] = "17406a23cd0.png", -- spirit
        [28] = "17406a41815.png", -- blue balloon
        [32] = "17406a58032.png", -- rune
        [34] = "17406a795f4.png", -- snowball
        [35] = "17406a914a3.png", -- cupid arrow
        [39] = "17406aa2daf.png", -- apple
        [40] = "17406ac8ab7.png", -- sheep
        [45] = "17406aefb88.png", -- small ice plank
        [46] = "17406b00239.png", -- small choco plank
        [54] = "17406b15725.png", -- ice cube
        [57] = "17406b22bd6.png", -- cloud
        [59] = "17406b32d1f.png", -- bubble
        [60] = "17406b59bd6.png", -- tiny plank
        [62] = "17406b772b7.png", -- stable rune
        [65] = "17406b8c9f2.png", -- puffer fish
        [90] = "17406b9eda9.png" -- tombstone
    },
    widgets = {
        borders = {
            topLeft = "155cbe99c72.png",
            topRight = "155cbea943a.png",
            bottomLeft = "155cbe97a3f.png",
            bottomRight = "155cbe9bc9b.png"
        },
        closeButton = "171e178660d.png"
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
    }
})

local profileWindow, leaderboardWindow

local initialized, newRoundStarted, suddenDeath = false
local currentItem = 17 -- cannon

local leaderboard
