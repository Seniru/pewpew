const combine = require("./combine");
const luamin = require("luamin");
const vkbeauty = require("vkbeautify");

combine({
  libs : {
    files : [
      "libs/utils.lua",
      "libs/bit.lua",
      "libs/BitList.lua",
      "libs/Windows.lua",
      "libs/timers4tfm.lua",
      "libs/DataHandler.lua",
    ],
  },
  init : {files : [ "src/init.lua" ]},
  translations : {
    header : "local translations = {}\n\n",
    files : [
      "src/translations/en.lua",
      "src/translations/br.lua",
      "src/translations/es.lua",
      "src/translations/fr.lua",
      "src/translations/tr.lua",
      "src/translations/ph.lua",
      "src/translations/pl.lua",
      "src/translations/translator.lua",
    ],
  },
  classes : {files : [ "libs/Player.lua" ]},
  events : {
    files : [
      "src/events/eventNewPlayer.lua",
      "src/events/eventLoop.lua",
      "src/events/eventKeyboard.lua",
      "src/events/eventNewGame.lua",
      "src/events/eventPlayerDied.lua",
      "src/events/eventPlayerLeft.lua",
      "src/events/eventPlayerDataLoaded.lua",
      "src/events/eventFileLoaded.lua",
      "src/events/eventFileSaved.lua",
      "src/events/eventChatCommand.lua",
      "src/events/eventTextAreaCallback.lua",
    ],
  },
  main : {files : [ "src/leaderboard.lua", "src/shop.lua", "src/main.lua" ]},
}).then((res) => {
  console.log("\x1b[1m\x1b[32m%s\x1b[0m", "Build completed!");
});
