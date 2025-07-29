local Signal = class('Signal')

function Signal:init()
	self.listeners = {}
end

function Signal:add(fun)
	self.listeners[fun] = 0
end
function Signal:addOnce(fun)
	self.listeners[fun] = 1
end
function Signal:remove(fun)
	self.listeners[fun] = nil
end

function Signal:dispatch(...)
	for listener, kind in pairs(self.listeners) do
		listener(...)
		if kind == 1 then
			self.listeners[listener] = nil
		end
	end
end

return Signal