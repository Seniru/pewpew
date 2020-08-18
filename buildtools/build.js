const combine = require("./combine")
const luamin = require("luamin")
const vkbeauty = require("vkbeautify")

combine({

    init: { files: [ "src/init.lua" ] },
    libs: {
        files: [
            "libs/utils.lua",
            "libs/timers4tfm.lua",
            "libs/Player.lua"
        ]
    },
    translations: {
        header: "local translations = {}\n\n",
        files: [
            "src/translations/en.lua",
            "src/translations/br.lua",
            "src/translations/es.lua",
            "src/translations/fr.lua",
            "src/translations/tr.lua",
            "src/translations/translator.lua"
        ],
    },
    events: {
        files: [
            "src/events/eventNewPlayer.lua",
            "src/events/eventLoop.lua",
            "src/events/eventKeyboard.lua",
            "src/events/eventNewGame.lua",
            "src/events/eventPlayerDied.lua",
            "src/events/eventPlayerLeft.lua"
        ]
    },
    main: { files: [ "src/main.lua" ] },

}).then((res) => {
    console.log("\x1b[1m\x1b[32m%s\x1b[0m", "Build completed!")
})