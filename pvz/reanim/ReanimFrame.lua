local ReanimFrame = class('ReanimFrame')

ReanimFrame.x = 0
ReanimFrame.y = 0
ReanimFrame.image = nil
ReanimFrame.xScale = 1
ReanimFrame.yScale = 1
ReanimFrame.xShear = 0
ReanimFrame.yShear = 0
ReanimFrame.xOrigin = 0
ReanimFrame.yOrigin = 0
ReanimFrame.active = true
ReanimFrame.font = nil
ReanimFrame.text = ''

ReanimFrame.layerName = ''
ReanimFrame.xOffset = 0
ReanimFrame.yOffset = 0

ReanimFrame.lerpFields = {
	'red'; 'green'; 'blue'; 'alpha';
	'xOrigin'; 'yOrigin';
	'xOffset'; 'yOffset';
	'xScale'; 'yScale';
	'x'; 'y';
}

ReanimFrame._tempTransform = love.math.newTransform()

function ReanimFrame:init(frameOrX, y, xShear, yShear, xScale, yScale)
	if class.isInstance(frameOrX) then
		self:copy(frameOrX)
	else
		self:set(frameOrX, y, xShear, yShear, xScale, yScale)
		self:setColor()
	end
end

function ReanimFrame:set(x, y, xShear, yShear, xScale, yScale)
	self:setPosition(x, y)
	self:setShear(xShear, yShear)
	self:setScale(xScale, yScale)
	
	return self
end

function ReanimFrame:copy(frame)
	self.font = frame.font
	self.text = frame.text
	self.image = frame.image
	self.active = frame.active
	self.layerName = frame.layerName
	self.xShear, self.yShear = frame.xShear, frame.yShear
	for i = 1, #self.lerpFields do
		local f = self.lerpFields[i]
		self[f] = frame[f]
	end
	
	return self
end

function ReanimFrame:lerp(a, b, t)
	if t == 0 then return self:copy(a)
	elseif t == 1 then return self:copy(b) end
	
	self.font = a.font
	self.text = a.text
	self.image = a.image
	self.active = (a.active and b.active)
	for i = 1, #self.lerpFields do
		local f = self.lerpFields[i]
		self[f] = math.lerp(a[f], b[f], t)
	end
	
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

function ReanimFrame:negate()
	local loveTransform = self:toLoveTransformWithoutOffset()
	
	self:setShear(-self.xShear, -self.yShear)
	self:setScale(1 / self.xScale, 1 / self.yScale)
	self:setPosition(loveTransform:inverseTransformPoint(0, 0))
	
	return self
end

function ReanimFrame.flashTransformToLove(xScale, yScale, xShear, yShear)
	-- https://math.stackexchange.com/questions/861674/decompose-a-2d-arbitrary-transform-into-only-scaling-and-rotation
	
	local m00, m01, m10, m11 =
		(math.dcos(yShear) * xScale), (-math.dsin(xShear) * yScale),
		(math.dsin(yShear) * xScale), (math.dcos(xShear) * yScale)
	
	local e, f, g, h = ((m00 + m11) * .5), ((m00 - m11) * .5), ((m10 + m01) * .5), ((m10 - m01) * .5)
	local q, r = math.sqrt(e * e + h * h), math.sqrt(f * f + g * g)
	local a1, a2 = math.atan2(g, f), math.atan2(h, e)
	
	return (q + r), (q - r), ((a2 - a1) * .5), ((a2 + a1) * .5)
end

function ReanimFrame.toLoveTransform(frame, transform)
	local xScale, yScale, xShear, yShear = ReanimFrame.flashTransformToLove(frame.xScale, frame.yScale, frame.xShear, frame.yShear)
	local transform = (transform or ReanimFrame._tempTransform)
	
	transform:reset()
	transform:translate(frame.x + frame.xOrigin - frame.xOffset, frame.y + frame.yOrigin - frame.yOffset)
	transform:rotate(yShear)
	transform:scale(xScale, yScale)
	transform:rotate(xShear)
	transform:translate(-frame.xOrigin, -frame.yOrigin)
	
	return transform
end
function ReanimFrame.toLoveTransformWithoutOffset(frame, transform)
	local xScale, yScale, xShear, yShear = ReanimFrame.flashTransformToLove(frame.xScale, frame.yScale, frame.xShear, frame.yShear)
	local transform = (transform or ReanimFrame._tempTransform)
	
	transform:reset()
	transform:translate(frame.x + frame.xOrigin, frame.y + frame.yOrigin)
	transform:rotate(yShear)
	transform:scale(xScale, yScale)
	transform:rotate(xShear)
	transform:translate(-frame.xOrigin, -frame.yOrigin)
	
	return transform
end
--[[function ReanimFrame.fromLoveTransform(transform)
	WELL idk how to get shear maybe later
	
	local
		m00, m01, m02, m03,
		m10, m11, m12, m13,
		m20, m21, m22, m23,
		m30, m31, m32, m33
	= transform:getMatrix()
	
	local xScale, yScale = math.sqrt(m00 * m00 + m10 * m10), math.sqrt(m01 * m01 + m11 * m11)
	
	return ReanimFrame:new(m03, m13, xShear, yShear, xScale, yScale)
end]]

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
function ReanimFrame:setColor(r, g, b, a)
	self.red, self.green, self.blue, self.alpha = (r or 1), (g or 1), (b or 1), (a or 1)
	return self
end

function ReanimFrame:getPosition()
	return self.x, self.y
end
function ReanimFrame:getScale()
	return self.xScale, self.yScale
end
function ReanimFrame:getShear()
	return self.xShear, self.yShear
end
function ReanimFrame:getOrigin()
	return self.xOrigin, self.yOrigin
end
function ReanimFrame:getOffset()
	return self.xOffset, self.yOffset
end
function ReanimFrame:getColor()
	return self.red, self.green, self.blue, self.alpha
end

return ReanimFrame