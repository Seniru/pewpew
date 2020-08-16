function eventKeyboard(name, key, down, x, y)
	if key == 32 or key == 3 then -- space / duck
		Player.players[name]:shoot(x, y)
	elseif key == 0 then-- left
		Player.players[name].stance = -1
	elseif key == 2 then-- right
		Player.players[name].stance = 1
	end	
end
