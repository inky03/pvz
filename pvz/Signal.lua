local Signal = class('Signal')

function Signal:init()
	self.listeners = {}
end

function Signal:add(fun, name)
	table.insert(self.listeners, {
		once = false;
		name = name;
		fun = fun;
	})
end
function Signal:addOnce(fun, name)
	table.insert(self.listeners, {
		once = true;
		name = name;
		fun = fun;
	})
end
function Signal:get(needle)
	return lambda.find(self.listeners, function(listener)
		return (listener == needle or listener.name == needle)
	end)
end
function Signal:remove(needle)
	local signal, index = self:get(needle)
	if index then
		table.remove(self, index)
	end
end
function Signal:removeAll()
	table.clear(self.listeners)
end

function Signal:dispatch(...)
	for i = 1, #self.listeners do
		local listener = self.listeners[i]
		listener.fun(...)
		if listener.once then
			table.remove(self.listeners, i)
			i = i - 1
		end
	end
end

return Signal