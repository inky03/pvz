local LilyPad = Plant:extend('LilyPad')

LilyPad.allowedSurfaces = {'water'}
LilyPad.carryTypes = {'grass'}
LilyPad.reanimName = 'LilyPad'
LilyPad.packetCost = 25
LilyPad.kind = 'water'

function LilyPad:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.yOffset = -25
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	
	self:attachBlink(self)
end

function LilyPad:onPlant(plant)
	Sound.play('plant_water')
end

return LilyPad