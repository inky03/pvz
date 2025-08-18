local PauseMenu = State:extend('PauseMenu')

PauseMenu.pauseState = true

function PauseMenu:init(superState)
	State.init(self, superState)
	
	Sound.play('pause')
end

function PauseMenu:mousePressed()
	self:close()
end

return PauseMenu