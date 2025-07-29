local SeedBank = class('SeedBank')

function SeedBank:draw(x, y)
	x, y = (x or 0), (y or 0)
	
	love.graphics.draw(Cache.image('images/SeedBank'), x + 10, y)
end

return SeedBank