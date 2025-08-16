local ReadySetPlantCutscene = Cutscene:extend('ReadySetPlantCutscene')

function ReadySetPlantCutscene:init(challenge)
	Cutscene.init(self, challenge)
	
	Sound.play('readysetplant')
	
	self.introAnimation = self:addElement(Reanimation:new('StartReadySetPlant', self.w * .5, self.h * .5))
	self.introAnimation.animation:add('introA', 'Ready')
	self.introAnimation.animation:add('introB', 'Set')
	self.introAnimation.animation:add('introC', 'Plant')
	self.introAnimation.animation:play('introA', true)
	
	self.introAnimation.animation.onLoop:add(function(animation)
		if animation.name == 'introA' then
			self.introAnimation:toggleLayer('Ready', false)
			self.introAnimation.animation:play('introB', false)
		elseif animation.name == 'introB' then
			self.introAnimation:toggleLayer('Set', false)
			self.introAnimation.animation:play('introC', false)
		elseif animation.name == 'introC' then
			self:finish()
			self.introAnimation:destroy()
		end
	end)
end

return ReadySetPlantCutscene