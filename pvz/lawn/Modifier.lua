local Modifier = class('Modifier')

function Modifier:init(parent)
	self.parent = parent
	self.multipliers = {}
	self.events = {}
	
	self.exists = true
end

function Modifier:apply(new, ...)
	-- thing here
end

function Modifier:addEvent(event, func)
	self.events[event] = func
end

function Modifier:setMultiplier(var, val)
	self.multipliers[var] = val
end
function Modifier:getMultiplier(var)
	return self.multipliers[var]
end

function Modifier:destroy()
	if not self.exists then return end
	
	local i = table.find(self.parent.modifiers, self)
	
	if i then table.remove(self.parent.modifiers, i) end
	
	self.exists = false
end

return Modifier
