-- Thanks to Turkitutu
-- https://pastebin.com/raw/Nw3y1A42

bit = {}

bit.lshift = function(x, by) -- Left-shift of x by n bits
	return x * 2 ^ by
end

bit.rshift = function(x, by) -- Logical right-shift of x by n bits
	return math.floor(x / 2 ^ by)
end

bit.band = function(a, b) -- bitwise and of x1, x2
	local p, c = 1, 0
	while a > 0 and b > 0 do
		local ra, rb = a % 2, b % 2
		if ra + rb > 1 then
			c = c + p
		end
		a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
	end
	return c
end

bit.bxor = function(a,b) -- Bitwise xor of x1, x2
	local r = 0
	for i = 0, 31 do
		local x = a / 2 + b / 2
		if x ~= math.floor(x) then
			r = r + 2^i
		end
		a = math.floor(a / 2)
		b = math.floor(b / 2)
	end
	return r
end

bit.bor = function(a,b) -- Bitwise or of x1, x2
	local p, c= 1, 0
	while a+b > 0 do
		local ra, rb = a % 2, b % 2
		if ra + rb > 0 then
			c = c + p
		end
		a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
	end
	return c
end

bit.bnot = function(n) -- Bitwise not of x
	local p, c = 1, 0
	while n > 0 do
		local r = n % 2
		if r < 0 then
			c = c + p
		end
		n, p = (n - r) / 2, p * 2
	end
	return c
end
