local SeedPacket = UIContainer:extend('SeedPacket')

function SeedPacket:init(lawn, entity, x, y, bank)
	self.texture = Cache.image('images/seeds')
	self.bank = bank
	self.lawn = lawn
	
	UIContainer.init(self, x, y, 50, self.texture:getPixelHeight())
	
	self.frame = 3
	self.entity = Cache.module(entity)
	self.displayCanvas = love.graphics.newCanvas(self.w, self.h)
	
	self.maxRecharge, self.recharged, self.cost = 750, 0, 100
	self.ready = false
	
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
	
	if self.maxRecharge <= 750 then
		self.recharged = self.maxRecharge
	end
end

function SeedPacket:renderToCanvas(entity)
	love.graphics.setCanvas(self.displayCanvas)
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.texture, (self.frame - 1) * -50, 0)
	
	if entity then
		local displayEntity = entity:new()
		displayEntity.transform:setScale(.5, .5)
		displayEntity:draw(4.75, 8.75)
	end
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.printf(self.cost, 0, 54, 32, 'right')
	
	love.graphics.setCanvas()
end

function SeedPacket:mousePressed(mouseX, mouseY)
	if self:isReady() and self.lawn.hoveringEntity == nil and self.entity then
		self.lawn:pickPlant(self.entity:new(0, 0, self.lawn.challenge), self, mouseX, mouseY)
		
		self.parent.canClickChildren = false
		self.picking = true
	end
end

function SeedPacket:update(dt)
	if self.recharged < self.maxRecharge then
		self.recharged = math.min(self.recharged + dt * Constants.tickPerSecond, self.maxRecharge)
	end
	
	self.ready = self:isReady()
	self.useHand = self.ready
	
	UIContainer.update(self, dt)
end
function SeedPacket:isReady()
	return (self.recharged >= self.maxRecharge and (not self.bank or self.cost <= self.bank.money) and not self.picking)
end

function SeedPacket:onPlanted()
	self.recharged = 0
	self.picking = false
	self.bank:setMoney(self.bank.money - self.cost)
end

function SeedPacket:onReturned()
	self.picking = false
end

function SeedPacket:draw(x, y)
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.displayCanvas, x, y)
	
	if not self.ready then
		love.graphics.setColor(0, 0, 0, .5)
		love.graphics.rectangle('fill', x, y, self.w, self.h)
		love.graphics.rectangle('fill', x, y, self.w, self.h * (self.picking and 1 or 1 - self.recharged / self.maxRecharge))
	end
	
	UIContainer.draw(self, x, y)
end

return SeedPacket