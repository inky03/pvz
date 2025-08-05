local Unit = Reanimation:extend('Unit')

Unit.pvzShader = love.graphics.newShader([[
	uniform float frost;
	uniform float glow;
	
	vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
		vec4 texColor = Texel(tex, texture_coords);
		
		if (frost > 0.) {
			vec3 frostColor = (vec3(texColor.rgb * .6) + vec3(0., 0., texColor.b));
			texColor.rgb = mix(texColor.rgb, frostColor, frost);
		}
		
		return (vec4(texColor.rgb + texColor.rgb * glow, texColor.a) * color);
	}
]])

Unit.reanimName = 'SunFlower'
Unit.previewAnimation = 'idle'
Unit.packetRecharge = 750
Unit.packetCost = 100

Unit.maxHp = 300

Unit.allowedSurfaces = {'ground'}

function Unit:init(x, y, challenge)
	Reanimation.init(self, self.reanimName, x, y)
	
	self.lawn = (challenge and challenge.lawn or nil)
	self.challenge = challenge
	self.active = true
	
	self.glow = 0
	self.frost = 0
	self.dead = false
	self.canDie = true
	self.damageGlow = 0
	self.damagePhase = 0
	self.hp = self.maxHp
	self.selected = false
	self.state = 'normal'
	self.speedMultiplier = 1
	
	self.xOffset, self.yOffset = 0, 0
	
	self.board, self.boardX, self.boardY = nil, 0, 0
	self.autoBoardPosition = false -- optimization
	self.shader = Unit.pvzShader
	
	self.flags = {}
	self:setSpeed(random.number(.75, 1))
	
	self.damage = 20
	self.damageGroup = nil
	self.damageFilter = function(test) return (not test.dead and not test.flags.ignoreCollisions) end
	
	self.shadow = Cache.image('images/plantshadow')
	self.shadowOffset = {x = -3; y = 50}
end

function Unit:setHitbox(x, y, w, h, hurtX, hurtY, hurtW, hurtH)
	Reanimation.setHitbox(self, x, y, w, h)
	self.hurtbox = (self.hurtbox or {})
	self.hurtbox.x = (hurtX or self.hitbox.x)
	self.hurtbox.y = (hurtY or self.hitbox.y)
	self.hurtbox.w = (hurtW or self.hitbox.w)
	self.hurtbox.h = (hurtH or self.hitbox.h)
end

function Unit:update(dt)
	if self.inactive or self.hover then return end
	
	Reanimation.update(self, dt * self.speedMultiplier)
	
	if self.frost > 0 then
		self.frost = (self.frost - dt * self.speed)
		if self.frost < 0 then
			self.frost = 0
			self.speedMultiplier = 1
		end
	end
	
	self.damageGlow = math.max(self.damageGlow - dt * 6, 0)
	
	if self.board and self.autoBoardPosition then
		self:updateBoardPosition()
	end
end
function Unit:updateBoardPosition()
	self.boardX, self.boardY = self.board:getBoardPosition(self.x, self.y)
end
function Unit:destroy()
	if self.board then
		self.board:removeUnit(self)
	end
	
	Reanimation.destroy(self)
end
function Unit:collidesWith(unit)
	return (math.within(self.x - self.xOffset + self.hitbox.x, unit.x - unit.xOffset + unit.hurtbox.x - self.hitbox.w, unit.x - unit.xOffset + unit.hurtbox.x + unit.hitbox.w)
		and math.within(self.y - self.yOffset + self.hitbox.y, unit.y - unit.yOffset + unit.hurtbox.y - self.hitbox.h, unit.y - unit.yOffset + unit.hurtbox.y + unit.hitbox.h))
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
	return (math.within(screenX, -self.hurtbox.w, windowWidth) and math.within(screenY, -self.hurtbox.h, windowHeight))
end
function Unit:hitboxOnScreen()
	local screenX, screenY = self:elementToScreen(-self.xOffset + self.hitbox.x, -self.yOffset + self.hitbox.y)
	return (math.within(screenX, -self.hitbox.w, windowWidth) and math.within(screenY, -self.hitbox.h, windowHeight))
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
	
	for _, unit in ipairs(self.board.units) do
		if (not kind or unit:instanceOf(kind)) and unit:hurtboxOnScreen() and self:collidesWith(unit) and (not filter or filter(unit)) then
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
function Unit:hit(collision, multiplier)
	collision:hitBy(self, multiplier)
end
function Unit:hitBy(unit, multiplier)
	local multiplier = (multiplier or 1)
	self:hurt(unit.damage * multiplier, multiplier)
end
function Unit:hurt(hp, glow)
	local multiplier = (multiplier or 1)
	self.hp = math.max(self.hp - hp * multiplier, 0)
	self.damageGlow = math.max(self.damageGlow, glow or 1)
	
	if self.hp <= 0 then
		self:die()
	end
end
function Unit:die()
	if not self.canDie or self.dead then return end
	self.dead = true
	self:onDeath()
end
function Unit:onSpawn() end
function Unit:onDeath()
	self:destroy()
end

function Unit:setDamagePhase(phase)
	self.damagePhase = phase
end
function Unit:setState(state)
	self.state = state
end
function Unit:setSpeed(speed)
	self.speed = speed
	self.animation.speed = speed
end

function Unit:drawShadow(x, y)
	if self.flags.ignoreCollisions then return end
	
	love.graphics.draw(self.shadow, x + self.shadowOffset.x, y + self.shadowOffset.y)
end
function Unit:draw(x, y, transforms)
	Unit.pvzShader:send('frost', (self.frost > 0 and 1 or 0))
	Unit.pvzShader:send('glow', self.selected and 1 or self.glow + self.damageGlow)
	
	self:drawSprite(x - self.xOffset, y - self.yOffset)
end
function Unit:drawSprite(x, y)
	Reanimation.draw(self, x, y, transforms)
end
function Unit:debugDraw(x, y)
	if self.flags.ignoreCollisions then return end
	
	Reanimation.debugDraw(self, x, y)
	
	x, y = (x or 0), (y or 0)
	
	love.graphics.setColor(0, 1, 0)
	love.graphics.rectangle('line', x + self.hurtbox.x + 1, y + self.hurtbox.y + 1, self.hurtbox.w - 1, self.hurtbox.h - 1)
	love.graphics.setColor(1, 1, 1)
	outlineText(('%d,%d'):format(math.round(self.boardX), math.round(self.boardY)), math.floor(x), math.floor(y))
end

return Unit