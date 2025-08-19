local BigButton = Cache.module('pvz.lawn.hud.BigButton')
local TallDialog = Cache.module('pvz.lawn.hud.TallDialog')

local PauseMenu = State:extend('PauseMenu')

PauseMenu.pauseState = true

function PauseMenu:init(superState)
	State.init(self, superState)
	
	Sound.play('pause')
	
	self.dialogBox = self:addElement(TallDialog:new(0, 0))
	self.dialogBox:center()
	
	for i, info in ipairs({
		{string = Strings:get('VIEW_ALMANAC_BUTTON')};
		{string = Strings:get('RESTART_LEVEL')};
		{string = Strings:get('MAIN_MENU_BUTTON')}
	}) do
		local button = self.dialogBox:addElement(Button:new(0, 241 + (i - 1) * 43, info.string, nil, 209))
		button:center(true, false)
	end
	
	local isFullscreen = love.window.getFullscreen()
	self.shaderOption = self.dialogBox:addElement(CheckBox:new(0, 174, 'Complex Visuals', nil, nil, shaders))
	self.shaderOption:center(true, false)
	self.fullscreenOption = self.dialogBox:addElement(CheckBox:new(0, 207, 'Full Screen', nil, nil, isFullscreen))
	self.fullscreenOption:center(true, false)
	
	self.backButton = self.dialogBox:addElement(BigButton:new(30, 381, Strings:get('BACK_TO_GAME'), function(button) self:close() end))
end

function PauseMenu:onClose()
	shaders = self.shaderOption.checked
	
	local mouseX, mouseY = windowToGame(love.mouse.getPosition())
	love.window.setFullscreen(self.fullscreenOption.checked, 'desktop')
	love.mouse.setPosition(gameToWindow(mouseX, mouseY))
end

return PauseMenu