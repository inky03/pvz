local ReadySetPlantCutscene = Cutscene:extend('ReadySetPlantCutscene')

function ReadySetPlantCutscene:init(challenge)
	Cutscene.init(self, challenge)
	
	Sound.play('readysetplant')
	
	self.drawToTop = true
	self.introAnimation = self:addElement(Reanimation:new('StartReadySetPlant', self.w * .5, self.h * .5))
	self.introAnimation.animation:add('introA', 'Ready', false)
	self.introAnimation.animation:add('introB', 'Set', false)
	self.introAnimation.animation:add('introC', 'Plant', false)
	self.introAnimation.animation:play('introA', true)
	self.introAnimation.animation.speed = .8
	
	self.introAnimation.animation.onFrame:add(function(animation)
		if animation.frame == animation.length and animation.name ~= 'introC' then
			self.introAnimation.visible = false
		end
	end)
	self.introAnimation.animation.onFinish:add(function(animation)
		self.introAnimation.visible = true
		if animation.name == 'introA' then
			self.introAnimation.animation:play('introB', true)
		elseif animation.name == 'introB' then
			self.introAnimation.animation:play('introC', true)
		elseif animation.name == 'introC' then
			self:finish()
			self.introAnimation:destroy()
		end
	end)
end

return ReadySetPlantCutscene