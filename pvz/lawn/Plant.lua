local Plant = Unit:extend('Plant')

Plant.kind = 'grass'
Plant.upgradeOf = nil
Plant.defaultBlinkAnim = 'blink'

Plant.carryTypes = {}
Plant.canCarry = false
Plant.isShield = false

function Plant:init(x, y, challenge)
	Unit.init(self, x, y, challenge)
	
	self:setHitbox(10, 0, 60, 80)
	
	self.carrying = {}
	self.shield = nil
	self.carrier = nil
	self.shielding = nil
	self.carryingOffset = {
		x = 0;
		y = 0;
	}
	
	self.damageGroup = Zombie
	
	if #self.defaultBlinkAnim > 0 then
		self.blinkReanim = Reanimation:new(self.reanimName)
		self.blinkReanim.animation:add('blink', self.defaultBlinkAnim, false)
		self.blinkReanim.animation.onFinish:add(function(_) self.blinkReanim.visible = false end)
		self.blinkReanim.visible = false
		
		self.blinkCountdown = random.int(400, 800)
	end
end

function Plant:canPlantOnTop(plant)
	return (plant.class ~= self.class and table.find(self.carryTypes, plant.kind))
end
function Plant:plantOnTop(plant)
	local otherPlant = self:proxy()
	
	plant.carrier = self
	plant.board = self.board
	plant.parent = self.board
	plant.boardX, plant.boardY = self.boardX, self.boardY
	
	self:onPlant(plant)
	self:insertPlantSort(plant)
	
	if otherPlant.isShield then
		otherPlant:protect(plant)
	end
end
function Plant:insertPlantSort(plant)
	for i = 1, #self.carrying do
		local otherPlant = self.carrying[i]
		if not plant.isShield and otherPlant.isShield then
			table.insert(self.carrying, i, plant)
			return plant
		end
	end
	table.insert(self.carrying, plant)
	return plant
end
function Plant:protect(plant)
	plant.shield = self
	self.shielding = plant
	self:onProtect(plant)
end
function Plant:onPlant(plant) end
function Plant:onUnplant(plant) end
function Plant:onProtect(shield) end
function Plant:onUnprotect(shield) end

function Plant:attachBlink(target, layer)
	local target, layer = (target or self), (layer or 'idle')
	if self.blinkReanim then target:attachReanim(layer, self.blinkReanim, layer) end
end

function Plant:update(dt)
	Unit.update(self, dt)
	
	if self.blinkReanim then
		self.blinkCountdown = (self.blinkCountdown - dt * self.speed * self.speedMultiplier * Constants.tickPerSecond)
		if self.blinkCountdown < 0 then self:blink() end
	end
	
	for i = 1, #self.carrying do
		self.carrying[i]:update(dt)
	end
end

function Plant:draw(x, y)
	Unit.draw(self, x, y)
	
	self:drawCarrying(x, y)
end
function Plant:drawCarrying(x, y)
	for i = 1, #self.carrying do
		local plant = self.carrying[i]
		plant:drawShadow(x + self.carryingOffset.x, y + self.carryingOffset.y)
		plant:drawBack(x + self.carryingOffset.x, y + self.carryingOffset.y)
	end
	for i = 1, #self.carrying do
		local plant = self.carrying[i]
		plant:draw(x + self.carryingOffset.x, y + self.carryingOffset.y)
	end
end

function Plant:destroy()
	Unit.destroy(self)
	
	if self.carrier then
		self.carrier:onUnplant(self)
		
		for i, plant in ipairs(self.carrier.carrying) do
			if plant == self then
				table.remove(self.carrier.carrying, i)
				break
			end
		end
	end
	
	if self.shielding then
		self.shielding.shield = nil
		self.shielding:onUnprotect(self)
	end
end

function Plant:blink()
	self.blinkReanim.visible = true
	self.blinkReanim.animation:play('blink', true)
	self.blinkCountdown = random.int(400, 800)
end

function Plant:proxy()
	if self.shield then
		return self.shield:proxy()
	end
	if self.carrying[1] then
		return self.carrying[#self.carrying]:proxy()
	end
	return self
end

return Plant