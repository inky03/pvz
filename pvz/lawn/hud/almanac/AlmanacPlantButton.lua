local AlmanacPlantButton = UIContainer:extend('AlmanacPlantButton')

function AlmanacPlantButton:init(entity, x, y)
	self.flashTexture = Cache.image('SeedPacketFlash', 'particles')
	self.texture = Cache.image('seeds', 'images')
	self.useHand = true
	
	UIContainer.init(self, x, y, 50, self.texture:getPixelHeight())
	
	self.frame = 3
	self.entity = (type(entity) == 'string' and Cache.module(entity) or entity)
	self.displayCanvas = love.graphics.newCanvas(self.w, self.h)
	
	self.costText = self:addElement(Font:new('Pico12', 9, 0, 54, 30, 9))
	self.costText:setLayerColor('Main', 0, 0, 0)
	self.costText:setAlignment('right')
	
	if self.entity then
		self.costText:setText(self.entity.packetCost)
		
		if self.entity.upgradeOf then
			self.frame = 2
		end
	else
		self.costText:setText('?')
	end
	
	self:renderToCanvas(self.entity)
end

function AlmanacPlantButton:renderToCanvas(entity)
	love.graphics.setCanvas(self.displayCanvas)
	
	love.graphics.clear()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.texture, (self.frame - 1) * -50, 0)
	
	if entity then
		entity:new():drawSeedPacket()
	end
	
	love.graphics.setCanvas()
end

function AlmanacPlantButton:draw(x, y)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setBlendMode('alpha', 'premultiplied')
	love.graphics.draw(self.displayCanvas, x, y)
	love.graphics.setBlendMode('alpha')
	
	if self.hovering then
		love.graphics.draw(self.flashTexture, x, y)
	end
	
	UIContainer.draw(self, x, y)
end

return AlmanacPlantButton