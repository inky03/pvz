local BigButton = Button:extend('BigButton')

BigButton.textureName = 'options_backtogamebutton'
BigButton.slice = false
BigButton.fontSize = 36
BigButton.fontOffsets = {
	hovering = {x = 0; y = -5};
	normal = {x = 0; y = -5};
	down = {x = 0; y = -4};
}
BigButton.buttonOffsets = {}
BigButton.defaultOffsets = {x = 0; y = 0}

function BigButton:create()
	self.textures = {
		hovering = {left = Cache.image(self.textureName .. '0', 'images')};
		normal = {left = Cache.image(self.textureName .. '0', 'images')};
		down = {left = Cache.image(self.textureName .. '2', 'images')};
	}
	
	self.w = self.textures.normal.left:getPixelWidth()
end

return BigButton