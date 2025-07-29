local SeedBank = class('SeedBank')

SeedPacket = require 'pvz.hud.SeedPacket'

function SeedBank:init()
	self.seeds = {}
	
	table.insert(self.seeds, SeedPacket:new('PeaShooter'))
	table.insert(self.seeds, SeedPacket:new('SunFlower'))
end

function SeedBank:draw(x, y)
	x, y = (x or 0), (y or 0)
	
	love.graphics.draw(Cache.image('images/SeedBank'), x, y)
	
	for i, seed in ipairs(self.seeds) do
		seed:draw(x + 85 + (i - 1) * 59, 8)
	end
end

return SeedBank