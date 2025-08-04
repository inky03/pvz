local SeedPacket = UIContainer:extend('SeedPacket')

function SeedPacket:init(lawn, entity, x, y)
	self.texture = Cache.image('images/seeds')
	self.lawn = lawn
	
	UIContainer.init(self, x, y, 50, self.texture:getPixelHeight())
	
	self.frame = 3
	self.entity = Cache.module(entity)
	self.displayCanvas = love.graphics.newCanvas(self.w, self.h)
	
	self.maxRecharge, self.recharged, self.cost = 750, 0, 100
	
	if self.entity then
		self.maxRecharge = self.entity.packetRecharge
		self.cost = self.entity.packetCost
		
		if self.entity.upgradeOf then
			self.frame = 2
		end
	end
	
	self:renderToCanvas(self.entity)
	self.picking = false
	self.useHand = false
end

function SeedPacket:renderToCanvas(entity)
	love.graphics.setCanvas(self.displayCanvas)
	
	love.graphics.draw(self.texture, (self.frame - 1) * -50, 0)
	
	if entity then
		local displayEntity = entity:new()
		displayEntity.transform:setScale(.5, .5)
		displayEntity:draw(4.75, 8.75)
	end
	
	love.graphics.setCanvas()
end

function SeedPacket:mousePressed(mouseX, mouseY)
	if self.recharged >= self.maxRecharge and self.lawn.hoveringEntity == nil and self.entity then
		self.lawn:pickPlant(self.entity:new(), self, mouseX, mouseY)
		
		self.parent.canClickChildren = false
		self.picking = true
	end
end

function SeedPacket:update(dt)
	if self.recharged < self.maxRecharge then
		self.recharged = (self.recharged + dt * Constants.tickPerSecond)
		if self.recharged >= self.maxRecharge then
			self.recharged = self.maxRecharge
			
			self.useHand = true
			updateCursor()
		end
	end
	
	UIContainer.update(self, dt)
end

function SeedPacket:onPlanted()
	self.recharged = 0
	self.useHand = false
	self.picking = false
	updateCursor()
end

function SeedPacket:onReturned()
	self.picking = false
end

function SeedPacket:draw(x, y)
	local uncharged = (self.recharged < self.maxRecharge or self.picking)
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.displayCanvas, x, y)
	
	if uncharged then
		love.graphics.setColor(0, 0, 0, .5)
		love.graphics.rectangle('fill', x, y, self.w, self.h)
		love.graphics.rectangle('fill', x, y, self.w, self.h * (self.picking and 1 or 1 - self.recharged / self.maxRecharge))
	end
	
	UIContainer.draw(self, x, y)
end

return SeedPacket