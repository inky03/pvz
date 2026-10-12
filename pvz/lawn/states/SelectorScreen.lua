local BigButton = Cache.module('pvz.lawn.hud.BigButton')
local SelectorButton = BigButton:extend('SelectorButton')

function SelectorButton:init(x, y, name, fun)
	self.textureNames = {
		hovering = ('SelectorScreen_' .. name .. '_highlight');
		normal = ('SelectorScreen_' .. name .. '_button');
		down = ('SelectorScreen_' .. name .. '_highlight');
	}
	self.buttonOffsets = {
		down = {x = 1; y = 1};
	}
	self.folder = 'reanim'
	self.hoverSound = 'bleep'
	self.clickSound = 'tap' -- 'gravebutton'
	
	BigButton.init(self, x, y, '', fun)
end

local SelectorScreen = State:extend('SelectorScreen')

function SelectorScreen:init()
	State.init(self)
	
	self.selector = self:addElement(Reanimation:new('SelectorScreen'))
	self.sign = self:addElement(Reanimation:new('SelectorScreen'))
	
	self.sign.animation:add('idle', 'idle')
	self.sign.animation:add('sign', 'sign', false)
	self.selector.animation:add('open', 'open', false)
	
	for i = 1, 7 do
		if i ~= 3 then
			local t = random.number(-6000, 2000)
			
			local cloud = Reanimation:new('SelectorScreen')
			cloud.animation:add('cloud', 'cloud' .. i)
			cloud.animation:play('cloud', true)
			
			self.selector:attach('SelectorScreen_BG', cloud, 'SelectorScreen_BG')
			
			if t < 0 then -- this code is funny but whatever
				cloud.animation:setTime(-t / 6000)
				cloud.animation:setFrameRate(.5)
			else
				cloud.animation:setFrameRate(0)
			end
		end
	end
	
	for _, layer in ipairs(self.sign.animation.current.layers) do
		if not layer.layerName:find('woodsign') then
			self.sign:toggleLayer(layer.layerName, false)
		end
	end
	
	self.selector.animation:play('open', true)
	self.selector.animation.onFinish:addOnce(function(_)
		self.sign.animation:play('sign', true)
		self.sign.animation:setFrameRate(30)
	end)
	
	self.buttons = self:addElement(UIContainer:new())
	
	self.buttons:addElement(SelectorButton:new(0, 0, 'Adventure')):setPolygonShape(7, 1, 328, 30, 314, 125, 1, 78)
	self.buttons:addElement(SelectorButton:new(0, 0, 'Survival')):setPolygonShape(4, 2, 312, 51, 296, 130, 7, 77)
	self.buttons:addElement(SelectorButton:new(0, 0, 'Challenges')):setPolygonShape(2, 0, 281, 55, 268, 121, 3, 60)
	self.buttons:addElement(SelectorButton:new(0, 0, 'vasebreaker')):setPolygonShape(7, 1, 267, 62, 257, 124, 7, 57)
	
	self.selector:toggleLayer('flower1', false)
	self.selector:toggleLayer('flower2', false)
	self.selector:toggleLayer('flower3', false)
	
	for _, button in ipairs(self.buttons.children) do button.renderPixelPerfect = true end
	for _, button in ipairs({ 'Adventure' ; 'StartAdventure' --[[ok]] ; 'Survival'; 'Challenges' ; 'ZenGarden' }) do
		self.selector:toggleLayer('SelectorScreen_' .. button .. '_button', false)
		self.selector:toggleLayer('SelectorScreen_' .. button .. '_shadow', false)
	end
end

function SelectorScreen:update(dt)
	if not State.update(self, dt) then return false end
	
	for i, button in ipairs({ 'Adventure' ; 'Survival'; 'Challenges' ; 'ZenGarden' }) do
		local button = self.selector:getAnimationLayer('SelectorScreen_' .. button .. '_button')
		self.buttons.children[i].x = button.x
		self.buttons.children[i].y = button.y
	end
	
	return true
end

return SelectorScreen
