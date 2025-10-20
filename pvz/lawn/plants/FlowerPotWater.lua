local FlowerPot = Cache.module('pvz.lawn.plants.FlowerPot')
local FlowerPotWater = FlowerPot:extend('FlowerPotWater')

FlowerPotWater.carryTypes = {'water'}

FlowerPotWater.previewAnimation = 'waterplants'
FlowerPotWater.packetCost = 25
FlowerPotWater.kind = 'pot'
FlowerPotWater.id = 999

function FlowerPotWater:init(x, y, challenge)
	FlowerPot.init(self, x, y, challenge)
	
	self.animation:get('idle'):setTrack(self.reanim:getTrack('waterplants'))
	self.animation:play('idle', true)
	
	self.carryingOffset.y = -45
end

function FlowerPotWater:onPlant(plant)
	if plant then
		Sound.play('plant_water')
	end
end

return FlowerPotWater