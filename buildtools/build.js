const combine = require("./combine")
const luamin = require("luamin")
const vkbeauty = require("vkbeautify")

combine({

    libs: {
        files: [
            "libs/utils.lua",
            "libs/timers4tfm.lua"
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
    init: { files: [ "src/init.lua" ] },
    events: {
        files: [
            "src/events/eventNewPlayer.lua"
        ]
    },
    main: { files: [ "src/main.lua" ] },

}).then((res) => {
    console.log("\x1b[1m\x1b[32m%s\x1b[0m", "Build completed!")
})