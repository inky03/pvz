local AlmanacPage = State:extend('AlmanacPage')
local PlantButton = Cache.module('pvz.lawn.hud.almanac.AlmanacPlantButton')

AlmanacPage.backgroundTextureName = 'Almanac_PlantBack'

function AlmanacPage:init()
	State.init(self)
	
	self.entities = {}
	self.backgroundTexture = Cache.image(self.backgroundTextureName, 'images')
	
	for _, entityFile in ipairs(Cache.fileList('pvz.lawn.plants', true, '%.lua$')) do
		local entity = Cache.module(entityFile)
		if entity and entity.id >= 0 then
			table.insert(self.entities, entity)
		end
	end
	
	table.sort(self.entities, function(a, b) return a.id < b.id end)
	
	local xx, yy = 0, 0
	for i = 1, #self.entities do
		self.packet = self:addElement(PlantButton:new(self.entities[i], 26 + xx * 52, 92 + yy * 78))
		
		xx = (xx + 1)
		if xx >= 8 then
			yy = (yy + 1)
			xx = 0
		end
	end
end

function AlmanacPage:draw(x, y)
	love.graphics.draw(self.backgroundTexture, x, y)
	
	State.draw(self, x, y)
end

return AlmanacPage