local SodRollCutscene = Cutscene:extend('SodRollCutscene')

function SodRollCutscene:init(challenge, sodRows)
	Cutscene.init(self, challenge)
	
	Sound.play('digger_zombie')
	
	local rolls = 0
	for _, row in ipairs(sodRows) do
		local sodRoll = challenge.lawn:addElement(Reanimation:new('SodRoll'))
		local rollX, rollY = challenge.lawn:getWorldPosition(1, row)
		self.sodRoll = sodRoll
		
		sodRoll.animation.onLoop:add(function()
			rolls = (rolls - 1)
			sodRoll:destroy()
			if rolls <= 0 then
				self:finish()
			end
		end)
		
		sodRoll:setPosition(rollX - 40, rollY - 280)
		rolls = (rolls + 1)
		
	end
end

function SodRollCutscene:update(dt)
	Cutscene.update(self, dt)
	
	if self.sodRoll then
		local cap = self.sodRoll:getAnimationLayer('SodRoll')
		self.state.lawn.sodRollX = math.max(self.state.lawn.sodRollX, cap.x + cap.xScale * 25)
	end
end

function SodRollCutscene:finish()
	self.state.lawn.sodRollX = gameWidth
	Cutscene.finish(self)
end

return SodRollCutscene