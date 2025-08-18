local Cutscene = UIContainer:extend('Cutscene')

function Cutscene:init(state)
	UIContainer.init(self, 0, 0, state.w, state.h)
	
	self.pauseState = false
	self.state = state
	self.counter = 0
end

function Cutscene:update(dt)
	UIContainer.update(self, dt)
	
	self.counter = (self.counter + dt * Constants.tickPerSecond * 10)
end

function Cutscene:finish()
	self.state:startNextCutscene()
	self:destroy()
end

return Cutscene