local ReanimFrame = class('ReanimFrame')

ReanimFrame.x = 0
ReanimFrame.y = 0
ReanimFrame.alpha = 1
ReanimFrame.image = nil
ReanimFrame.xScale = 1
ReanimFrame.yScale = 1
ReanimFrame.xShear = 0
ReanimFrame.yShear = 0
ReanimFrame.xOrigin = 0
ReanimFrame.yOrigin = 0
ReanimFrame.xOffset = 0
ReanimFrame.yOffset = 0
ReanimFrame.active = true
ReanimFrame.scaleCoords = false
-- TODO: IMPLEMENT TEXT AND FONT ?

function ReanimFrame:init(frame)
	if frame then
		self:copy(frame)
	end
end

function ReanimFrame:copy(frame)
	self.alpha = frame.alpha
	self.image = frame.image
	self.active = frame.active
	self:setPosition(frame.x, frame.y)
	self:setScale(frame.xScale, frame.yScale)
	self:setShear(frame.xShear, frame.yShear)
	self:setOrigin(frame.xOrigin, frame.yOrigin)
	self:setOffset(frame.xOffset, frame.yOffset)
	
	return self
end

function ReanimFrame:lerp(a, b, t)
	self.image = a.image
	self.active = a.active
	self.alpha = math.lerp(a.alpha, b.alpha, t)
	self:setPosition(math.lerp(a.x, b.x, t), math.lerp(a.y, b.y, t))
	self:setScale(math.lerp(a.xScale, b.xScale, t), math.lerp(a.yScale, b.yScale, t))
	self:setShear(math.lerp(a.xShear, b.xShear, t), math.lerp(a.yShear, b.yShear, t))
	self:setOrigin(math.lerp(a.xOrigin, b.xOrigin, t), math.lerp(a.yOrigin, b.yOrigin, t))
	self:setOffset(math.lerp(a.xOffset, b.xOffset, t), math.lerp(a.yOffset, b.yOffset, t))
	
	return self
end

function ReanimFrame:__tostring()
	local function round(n)
		return (math.round(n * 100) / 100)
	end
	
	return ('ReanimFrame(x:%s, y:%s, xShear:%s, yShear:%s, xScale:%s, yScale:%s, active:%s, alpha:%s)'):format(
		round(self.x), round(self.y),
		round(self.xShear), round(self.yShear),
		round(self.xScale), round(self.yScale),
		tostring(self.active), round(self.alpha)
	)
end

function ReanimFrame:setPosition(x, y)
	self.x, self.y = x, y
	return self
end
function ReanimFrame:setScale(x, y)
	self.xScale, self.yScale = x, y
	return self
end
function ReanimFrame:setShear(x, y)
	self.xShear, self.yShear = x, y
	return self
end
function ReanimFrame:setOrigin(x, y)
	self.xOrigin, self.yOrigin = x, y
	return self
end
function ReanimFrame:setOffset(x, y)
	self.xOffset, self.yOffset = x, y
	return self
end

return ReanimFrame