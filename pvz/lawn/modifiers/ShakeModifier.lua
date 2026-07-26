local ShakeModifier = Modifier:extend('ShakeModifier')

function ShakeModifier:apply(new, xRandom, yRandom)
	self.xRandom = xRandom
	self.yRandom = yRandom
end

function ShakeModifier:draw(event)
	event.x = (event.x + random.number(-self.xRandom, self.xRandom))
	event.y = (event.y + random.number(-self.yRandom, self.yRandom))
end

return ShakeModifier
