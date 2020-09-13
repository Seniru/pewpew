function eventPlayerLeft(name)
    local player = Player.players[name]
    if not player then return end
    player:die()
    Player.players[name] = nil
    Player.playerCount = Player.playerCount - 1
    statsEnabled = (not isTribeHouse) and tfm.get.room.uniquePlayers >= 4
end