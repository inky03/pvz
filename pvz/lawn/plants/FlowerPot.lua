local FlowerPot = Plant:extend('FlowerPot')

FlowerPot.carryingOffset.y = -30
FlowerPot.allowedSurfaces = {'ground'} -- todo roof
FlowerPot.carryTypes = {'grass', 'soil'}
FlowerPot.defaultBlinkAnim = nil
FlowerPot.reanimName = 'Pot'
FlowerPot.packetCost = 25
FlowerPot.kind = 'pot'

function FlowerPot:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
end

function FlowerPot:onPlant(plant)
	Sound.playRandom({ 'plant' ; 'plant2' })
	self.animation.paused = true
	self.animation:setFrame(1)
end
function FlowerPot:onUnplant(plant)
	self.animation.paused = false
end

return FlowerPot