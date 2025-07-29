local SeedPacket = class('SeedPacket')

function SeedPacket:init()
	self.graphic = Cache.graphic('images/seeds')
	
	self.sprite = Sprite:new()
end