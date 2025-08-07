local Lawn = Cache.module('pvz.lawn.Lawn')
local DayLawn = Lawn:extend('DayLawn')

function DayLawn:init(challenge, x, y)
	if challenge.challenge <= 3 then
		self.textureName = 'background1unsodded'
	end
	
	Lawn.init(self, challenge, x, y)
	
	if challenge.challenge <= 3 then
		for col = 1, self.size.x do
			self:setSurfaceAt(col, 1, 'unsodded')
			self:setSurfaceAt(col, 5, 'unsodded')
			
			if challenge.challenge == 1 then
				self:setSurfaceAt(col, 2, 'unsodded')
				self:setSurfaceAt(col, 4, 'unsodded')
			end
		end
	end
end

function DayLawn:drawBackground(x, y)
	Lawn.drawBackground(self, x, y)
	
	if self.challenge.challenge == 1 then
		love.graphics.draw(Cache.image('images/sod1row'), x + 239, y + 265)
	elseif self.challenge.challenge <= 3 then
		love.graphics.draw(Cache.image('images/sod3row'), x + 235, y + 149)
	end
end

return DayLawn