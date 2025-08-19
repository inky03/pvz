local TallDialog = Dialog:extend('TallDialog')

TallDialog.textureName = 'options_menuback'
TallDialog.slice = false

function TallDialog:create()
	self.textures[self:getSliceName(1, 1)] = Cache.image(self.textureName, 'images')
end

return TallDialog