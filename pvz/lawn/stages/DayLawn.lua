local Lawn = Cache.module('pvz.lawn.Lawn')
local DayLawn = Lawn:extend('DayLawn')

DayLawn.textureName = 'background1unsodded'
DayLawn.soddedTextureName = 'background1'

function DayLawn:init(challenge, x, y)
	self.soddedTexture = Cache.image(self.soddedTextureName, 'images')
	self.sodRollX = gameWidth
	
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

function DayLawn:drawBackground()
	Lawn.drawBackground(self)
	
	local xx, yy = self.sodRollX, gameHeight
	if self.challenge.challenge <= 3 then
		if self.challenge.challenge > 1 then
			if self.sodRollX < gameWidth then
				love.graphics.setScissor(rectToWindow(xx, 0, gameWidth - xx, yy))
				love.graphics.draw(Cache.image('images/sod1row'), 239, 265)
			end
			
			love.graphics.setScissor(rectToWindow(0, 0, xx, yy))
			love.graphics.draw(Cache.image('images/sod3row'), 235, 149)
		else
			love.graphics.setScissor(rectToWindow(0, 0, xx, yy))
			love.graphics.draw(Cache.image('images/sod1row'), 239, 265)
		end
	else
		if self.sodRollX < gameWidth then love.graphics.draw(Cache.image('images/sod3row'), 235, 149) end
		
		love.graphics.setScissor(rectToWindow(0, 0, xx, yy))
		love.graphics.draw(self.soddedTexture, (self.w - self.tW) * .5, (self.h - self.tH) * .5)
	end
	
	love.graphics.setScissor()
end

return DayLawn