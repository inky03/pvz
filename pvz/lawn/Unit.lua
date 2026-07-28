ModifierMixin = require 'pvz.lawn.ModifierMixin'

local Unit = Reanimation:extend('Unit'):with(ModifierMixin)

Unit.pvzShader = Cache.shader('pvz')

Unit.reanimName = 'SunFlower'
Unit.previewAnimation = 'idle'
Unit.packetRecharge = 750
Unit.packetCost = 100
Unit.id = -1

Unit.maxHealth = 300

Unit.allowedSurfaces = {'ground'}

function Unit:init(x, y, challenge)
	Reanimation.init(self, self.reanimName, x, y)
	
	self.lawn = (challenge and challenge.lawn or nil)
	self.challenge = challenge
	self.active = true
	
	self.glow = 0
	self.hard = false
	self.dead = false
	self.canDie = true
	self.damageGlow = 0
	self.health = self.maxHealth
	self.selected = false
	self.state = 'normal'
	self.speedMultiplier = 1
	
	self.xOffset, self.yOffset = 0, 0
	
	self.board, self.boardX, self.boardY = nil, 0, 0
	self.autoBoardPosition = false -- optimization
	self.shader = Unit.pvzShader
	
	self.flags = {}
	self.modifiers = {}
	self:setSpeed(random.number(.75, 1))
	
	self.damage = 20
	self.damageGroup = nil
	self.damageFilter = function(test) return (not test.dead and not test.flags.ignoreCollisions) end
	
	self.shadow = Cache.image('images/plantshadow')
	self.shadowOffset = {x = -3; y = 50}
	
	self.debugInfo = Font:new('Pico12', 9, 0, 0, self.w)
	
	self:setupEvent('update', {'dt'})
	
	self:setupEvent('draw', {'x', 'y', 'transforms'})
	self:setupEvent('drawBack', {'x', 'y'})
	self:setupEvent('drawShadow', {'x', 'y'})
	self:setupEvent('debugDraw', {'x', 'y'})
	
	self:setupEvent('hurt', {'damage', 'glow'}, {
		cancelledDamage = false;
		cancelledGlow = false;
		cancelDamage = function(ev) ev.cancelledDamage = true end;
		cancelGlow = function(ev) ev.cancelledGlow = true end;
	})
	
	self:setupEvent('hit', {'collision', 'multiplier'})
	self:setupEvent('hitBy', {'collision', 'multiplier'})
	
	self:setupEvent('die', {})
	
	self._initializedHurtbox = false
end

function Unit:setHitbox(x, y, w, h, hurtX, hurtY, hurtW, hurtH)
	Reanimation.setHitbox(self, x, y, w, h)
	
	if not self._initializedHurtbox then
		self.hurtbox = { x = self.hitbox.x ; y = self.hitbox.y ; w = self.hitbox.w; h = self.hitbox.h }
		self._initializedHurtbox = true
	end
	
	if hurtX then self:setHurtbox(hurtX, hurtY, hurtW, hurtH) end
end

function Unit:setHurtbox(x, y, w, h)
	self.hurtbox.x = (x or self.hitbox.x)
	self.hurtbox.y = (y or self.hitbox.y)
	self.hurtbox.w = (w or self.hitbox.w)
	self.hurtbox.h = (h or self.hitbox.h)
end
function Unit:getHurtboxPosition()
	return (self.x + self.hurtbox.x), (self.y + self.hurtbox.y)
end
function Unit:getHurtboxDimensions()
	return self.hurtbox.w, self.hurtbox.h
end

function Unit:update(dt)
	if self.inactive or self.hover then return false end
	
	if self:dispatchEvent('update', dt).cancelled then return false end
	
	Reanimation.update(self, dt * self.speed * self:getMultiplier('speed', self.speedMultiplier))
	
	self.damageGlow = math.max(self.damageGlow - dt * 6, 0)
	
	if self.board and self.autoBoardPosition then
		self:updateBoardPosition()
	end
end
function Unit:updateBoardPosition()
	self.boardX, self.boardY = self.board:getBoardPosition(self.x, self.y)
end
function Unit:destroy()
	for i = #self.modifiers, 1, -1 do
		self.modifiers[i]:destroy()
	end
	
	if self.board then
		self.board:removeUnit(self)
	end
	
	Reanimation.destroy(self)
end
function Unit:proxy()
	return self
end
function Unit:collidesWith(other)
	local hitX, hitY = self:getHitboxPosition()
	local hurtX, hurtY = other:getHurtboxPosition()
	
	return (
		math.max(hitY, hurtY) < math.min(hitY + self.hitbox.h, hurtY + other.hurtbox.h) and
		math.max(hitX, hurtX) < math.min(hitX + self.hitbox.w, hurtX + other.hurtbox.w)
	)
end
function Unit:getHurtboxCenter(x, y)
	local x, y = (x or self.x), (y or self.y)
	return (x - self.xOffset + self.hurtbox.x + self.hurtbox.w * .5), (y - self.yOffset + self.hurtbox.y + self.hurtbox.h * .5)
end
function Unit:getHitboxCenter(x, y)
	local x, y = (x or self.x), (y or self.y)
	return (x - self.xOffset + self.hitbox.x + self.hitbox.w * .5), (y - self.yOffset + self.hitbox.y + self.hitbox.h * .5)
end
function Unit:hurtboxOnScreen()
	local screenX, screenY = self:elementToScreen(-self.xOffset + self.hurtbox.x, -self.yOffset + self.hurtbox.y)
	return (math.within(screenX, -self.hurtbox.w, gameWidth) and math.within(screenY, -self.hurtbox.h, gameHeight))
end
function Unit:hitboxOnScreen()
	local screenX, screenY = self:elementToScreen(-self.xOffset + self.hitbox.x, -self.yOffset + self.hitbox.y)
	return (math.within(screenX, -self.hitbox.w, gameWidth) and math.within(screenY, -self.hitbox.h, gameHeight))
end
function Unit:isInTile(col, row, error)
	local error = (error or .05)
	return ((not col or math.abs(self.boardX - col) < error) and (not row or math.abs(self.boardY - row) < error))
end

function Unit:canBeSpawnedAt(lawn, col, row)
	return table.find(self.allowedSurfaces, lawn:getSurfaceAt(col, row))
end

function Unit:queryCollision(kind, filter, baseX, baseY)
	if self.flags.canCollide == false or not self:hitboxOnScreen() or not kind then return end -- always be kind!
	
	local closest, closestDist = nil, nil
	
	local units = self.board.units
	for i = #units, 1, -1 do
		local unit = units[i]:proxy()
		
		if unit:instanceOf(kind) and unit:hurtboxOnScreen() and self:collidesWith(unit) and (not filter or filter(unit)) then
			local xA, yA = self:getHitboxCenter(baseX, baseY)
			local xB, yB = unit:getHurtboxCenter()
			local dist = math.eucldistance(xA, yA, xB, yB)
			
			if not closest or (closest and dist < closestDist) then
				closest, closestDist = unit, dist
			end
		end
	end
	
	return closest
end
function Unit:queryCollisionMultiple(kind, filter, recursive)
	if self.flags.canCollide == false or not self:hitboxOnScreen() or not kind then return end -- always be kind!
	
	local collisions
	
	local units = self.board.units
	
	if not recursive then
		for i = #units, 1, -1 do
			local unit = units[i]:proxy()
			
			if unit:instanceOf(kind) and unit:hurtboxOnScreen() and self:collidesWith(unit) and (not filter or filter(unit)) then
				collisions = (collisions or {})
				
				table.insert(collisions, unit)
			end
		end
	else
		local recursed = {}
		
		local function recurseUnit(unit)
			if unit:instanceOf(kind) and unit:hurtboxOnScreen() and self:collidesWith(unit) and (not filter or filter(unit)) then
				collisions = (collisions or {})
				
				table.insert(collisions, unit)
			end
			
			if recursed[unit] then return end
			recursed[unit] = true
			
			local proxy = unit:proxy()
			if unit ~= proxy then recurseUnit(proxy) end
		end
		
		for i = #units, 1, -1 do
			recurseUnit(units[i])
		end
	end
	
	return collisions
end
function Unit:hit(collision, multiplier)
	if not collision then return end
	
	if self:dispatchEvent('hit', collision, multiplier).cancelled then return false end
	
	collision:hitBy(self, multiplier)
end
function Unit:hitBy(collision, multiplier)
	if not collision then return end
	
	if self:dispatchEvent('hitBy', collision, multiplier).cancelled then return false end
	
	local multiplier = (multiplier or 1)
	
	self:hurt(collision.damage * multiplier, multiplier)
end
function Unit:hurt(damage, glow)
	if self.dead then return end
	
	local event = self:dispatchEvent('hurt', damage, glow)
	
	if event.cancelled then return false end
	
	if not event.cancelledDamage then self.health = math.max(self.health - event.damage, 0) end
	if not event.cancelledGlow then self.damageGlow = math.max(self.damageGlow, event.glow or 1) end
	
	if self.health <= 0 then
		self:die()
	end
end
function Unit:die()
	if not self.canDie or self.dead then return false end
	
	if self:dispatchEvent('die').cancelled then return false end
	
	self.dead = true
	self:onDeath()
end
function Unit:onSpawn() end
function Unit:onDeath()
	self:destroy()
end

function Unit:setState(state)
	self.state = state
end
function Unit:setSpeed(speed)
	self.speed = speed
	self.animation.speed = speed
end

function Unit:drawShadow(x, y)
	if self.flags.ignoreCollisions then return false end
	
	if self:dispatchEvent('drawShadow', x, y).cancelled then return false end
	
	love.graphics.draw(self.shadow, x + self.shadowOffset.x, y + self.shadowOffset.y)
end
function Unit:drawBack(x, y)
	if self:dispatchEvent('drawBack', x, y).cancelled then return false end
end
function Unit:draw(x, y, transforms)
	Unit.pvzShader:send('frost', 0)
	Unit.pvzShader:send('glow', self.selected and 1 or self.glow + self.damageGlow)
	
	local event = self:dispatchEvent('draw', x, y, transforms)
	
	if event.cancelled then return false end
	
	self:drawSprite(event.x - self.xOffset, event.y - self.yOffset, event.transforms)
end
function Unit:drawSprite(x, y, transforms)
	Reanimation.draw(self, x, y, transforms)
end
function Unit:debugDraw(x, y)
	local x, y = (x or 0), (y or 0)
	local event = self:dispatchEvent('debugDraw', x, y)
	
	if event.cancelled then return false end
	
	if self.flags.ignoreCollisions then return false end
	
	Reanimation.debugDraw(self, event.x, event.y)
	
	love.graphics.setColor(1, 1, 0)
	love.graphics.rectangle('line', event.x + self.hurtbox.x + 1, event.y + self.hurtbox.y + 1, self.hurtbox.w - 1, self.hurtbox.h - 1)
	love.graphics.setColor(1, 1, 0, UIContainer.debugBoxFillAlpha)
	love.graphics.rectangle('fill', event.x + self.hurtbox.x + 1, event.y + self.hurtbox.y + 1, self.hurtbox.w - 1, self.hurtbox.h - 1)
	
	love.graphics.setColor(1, 1, 1)
	
	self.debugInfo:setText(('%d,%d'):format(math.round(self.boardX), math.round(self.boardY)))
	self.debugInfo:draw(math.floor(event.x), math.floor(event.y))
end
function Unit:drawSeedPacket()
	self.xOffset, self.yOffset = 0, 0
	self.transform:setScale(.5, .5)
	self:render(4.75, 8.75)
end

function Unit:getMultiplier(tag, base)
	local value = (base or 1)
	
	for i = #self.modifiers, 1, -1 do
		local mult = self.modifiers[i].multipliers[tag]
		
		if mult then value = (value * mult) end
	end
	
	return value
end

function Unit.__tostring(self)
	if self.class then
		return ('%s(health:%d, maxHealth:%d)'):format(self.class.name, math.round(self.health), math.round(self.maxHealth))
	else
		return ('%s(maxHealth:%d)'):format(self.name, math.round(self.maxHealth))
	end
end

return Unit