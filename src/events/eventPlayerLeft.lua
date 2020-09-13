function eventPlayerLeft(name)
    local player = Player.players[name]
    if not player then return end
    player:die()
    Player.players[name] = nil
    Player.playerCount = Player.playerCount - 1
end