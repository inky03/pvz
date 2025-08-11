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
ReanimFrame.layerName = ''
ReanimFrame.scaleCoords = false
-- TODO: IMPLEMENT TEXT AND FONT ?

ReanimFrame._internalXOffset = 0
ReanimFrame._internalYOffset = 0

function ReanimFrame:init(frameOrX, y, xShear, yShear, xScale, yScale)
	if class.isInstance(frameOrX) then
		self:copy(frameOrX)
	else
		self:set(frameOrX, y, xShear, yShear, xScale, yScale)
	end
end

function ReanimFrame:set(x, y, xShear, yShear, xScale, yScale)
	self:setPosition(x, y)
	self:setShear(xShear, yShear)
	self:setScale(xScale, yScale)
	
	return self
end

function ReanimFrame:copy(frame)
	self.image = frame.image
	self.alpha = frame.alpha
	self.active = frame.active
	self.layerName = frame.layerName
	self:setPosition(frame.x, frame.y)
	self:setScale(frame.xScale, frame.yScale)
	self:setShear(frame.xShear, frame.yShear)
	self:setOrigin(frame.xOrigin, frame.yOrigin)
	self:setOffset(frame.xOffset, frame.yOffset)
	
	return self
end

function ReanimFrame:lerp(a, b, t)
	if t == 0 then return self:copy(a)
	elseif t == 1 then return self:copy(b) end
	
	self.image = a.image
	self.active = a.active
	self.alpha = math.lerp(a.alpha, b.alpha, t)
	self:setPosition(math.lerp(a.x, b.x, t), math.lerp(a.y, b.y, t))
	self:setScale(math.lerp(a.xScale, b.xScale, t), math.lerp(a.yScale, b.yScale, t))
	self:setOrigin(math.lerp(a.xOrigin, b.xOrigin, t), math.lerp(a.yOrigin, b.yOrigin, t))
	self:setOffset(math.lerp(a.xOffset, b.xOffset, t), math.lerp(a.yOffset, b.yOffset, t))
	
	local xsDiff, ysDiff = (b.xShear - a.xShear), (b.yShear - a.yShear) -- TODO: this is probably not right...
	xsDiff = (xsDiff > 180 and -360 or (xsDiff < -180 and 360 or 0))
	ysDiff = (ysDiff > 180 and -360 or (ysDiff < -180 and 360 or 0))
	self:setShear(math.lerp(a.xShear, b.xShear + xsDiff, t), math.lerp(a.yShear, b.yShear + ysDiff, t))
	
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
	self.x, self.y = (x or 0), (y or 0)
	return self
end
function ReanimFrame:setScale(x, y)
	self.xScale, self.yScale = (x or 1), (y or 1)
	return self
end
function ReanimFrame:setShear(x, y)
	self.xShear, self.yShear = (x or 0), (y or x or 0)
	return self
end
function ReanimFrame:setOrigin(x, y)
	self.xOrigin, self.yOrigin = (x or 0), (y or 0)
	return self
end
function ReanimFrame:setOffset(x, y)
	self.xOffset, self.yOffset = (x or 0), (y or 0)
	return self
end

return ReanimFrame