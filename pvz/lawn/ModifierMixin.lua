local ModifierMixin = {}

function ModifierMixin:findModifier(class, filter)
	if not self.modifiers then return nil end
	
	for _, modifier in ipairs(self.modifiers) do
		if modifier.class == class and (not filter or filter(modifier)) then
			return modifier
		end
	end
	
	return nil
end

function ModifierMixin:applyModifier(class, unique, ...)
	if not self.modifiers then self.modifiers = {} end
	
	local mod
	
	if not unique then
		mod = self:findModifier(class)
		
		if mod then
			mod:apply(false, ...)
			
			return mod
		end
	end
	
	mod = class:new(self)
	
	table.insert(self.modifiers, mod)
	
	mod:apply(true, ...)
	
	return mod
end

function ModifierMixin:setupEvent(event, params, variables)
	if not self.__events then self.__events = {} end
	
	local newEvent = {__f = params, __v = variables or {}}
	
	newEvent.cancel = function(ev) ev.cancelled = true end
	newEvent.stopPropagation = function(ev) ev.propagating = false end
	
	self.__events[event] = newEvent
	
	return newEvent
end

function ModifierMixin:dispatchEvent(event, ...)
	local data = self.__events[event]
	
	data.propagating = true
	data.cancelled = false
	
	for i = 1, select('#', ...) do
		local v = select(i, ...)
		
		data[data.__f[i]] = v
	end
	
	for k, v in pairs(data.__v) do
		data[k] = v
	end
	
	for i = #self.modifiers, 1, -1 do
		local mod = self.modifiers[i]
		local f = mod[event]
		
		if f then f(mod, data) end
		
		if not data.propagating then break end
	end
	
	return data
end

return ModifierMixin
