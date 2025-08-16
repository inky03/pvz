local State = UIContainer:extend('CutsceneState')

function State:init()
	UIContainer.init(self, 0, 0, game.w, game.h)
	
	self.cutscenes = {}
	self.activeCutscene = nil
	self.pausedOnCutscene = false
	
	self.onStartCutscene = Signal:new()
	self.onFinishCutscene = Signal:new()
	self.onCutscenesFinished = Signal:new()
end

function State:queueCutscene(cutscene, pos, ...)
	table.insert(self.cutscenes, pos or #self.cutscenes + 1, {
		kind = cutscene;
		params = {...}
	})
end
function State:findCutsceneIndex(cutscene, start)
	for i = (start or 1), #self.cutscenes do
		local cut = self.cutscenes[i]
		if cut.kind and (cut.kind == cutscene or cut.kind.name == cutscene) then
			return i
		end
	end
	return nil
end
function State:dequeueCutscene(cutscene)
	local index = self:findCutsceneIndex(cutscene)
	if index then
		table.remove(self.cutscenes, index)
	end
end
function State:startNextCutscene()
	if #self.cutscenes > 0 then
		local prevCutscene = self.activeCutscene
		local cutscene = self.cutscenes[1]
		table.remove(self.cutscenes, 1)
		
		if not cutscene.kind then
			trace('Cutscene was invalid')
			return true
		else
			self.activeCutscene = cutscene.kind:new(self, unpack(cutscene.params))
			self:addElement(self.activeCutscene)
		end
		
		if prevCutscene then self.onFinishCutscene:dispatch(prevCutscene) end
		self.onStartCutscene:dispatch(self.activeCutscene)
		
		return true
	else
		self.activeCutscene = nil
		self.onCutscenesFinished:dispatch()
		
		return false
	end
end

function State:update(dt)
	if not self.activeCutscene and #self.cutscenes > 0 then
		self:startNextCutscene()
	end
	
	if self.activeCutscene and self.pausedOnCutscene then
		self.activeCutscene:update(dt)
	end
	
	if not self.pausedOnCutscene or not self.activeCutscene then
		UIContainer.update(self, dt)
	end
end

return State