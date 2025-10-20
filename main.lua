require 'import'

trace('PVZ')

gameWidth, gameHeight = love.graphics.getDimensions()
hoveringElement = nil
draggingElement = nil
username = 'Player'
accumulator = 0

local gc = 0
local objs = 0
local stats = nil
local gcTimer = 0
local fpsCount = 0
local drawtime = {}

function love.load(arguments)
	shaders = true
	complex = flags.complex
	debugMode = (table.find(arguments, '-debug') or flags.debugMode)
	tickPerSecond = (flags.maxFramerate > 0 and (1 / flags.maxFramerate) or -1)
	math.randomseed(os.clock())
	reloadCursors()
	
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')
	love.mouse.setCursor(cursors.pointer)
	
	Strings.reload()
	Resources.reload()
	Cache.createDefaults()
	game = UIContainer:new(0, 0, gameWidth, gameHeight)
	state = game:addElement(Cache.module('pvz.lawn.states.ReanimatedMusicVideo'):new())
	-- state = game:addElement(Cache.module('pvz.lawn.challenges.FogChallenge'):new(35))
	debugInfo = Font:new('Pico12', 9, 0, 0, 120, 60)
	
	debugCanvas = love.graphics.newCanvas(220, 200)
	
	--[[
	grasswalk = love.audio.newSource('resources/love/music/grasswalk.mp3', 'stream')
	grasswalk:setLooping(true)
	grasswalk:play()
	]]
end

function love.mousepressed(mouseX, mouseY, button, isTouch, presses)
	local mouseX, mouseY = windowToGame(mouseX, mouseY)
	updateHover(mouseX, mouseY)
	game:mousePressedAnywhere(mouseX, mouseY, button, isTouch, presses)
	if hoveringElement then
		hoveringElement:mousePressed(mouseX, mouseY, button, isTouch, presses)
		
		if hoveringElement.canDrag and button == hoveringElement.dragButton then
			draggingElement = hoveringElement
			draggingElement.dragging = true
			draggingElement:mouseGrabbed(mouseX, mouseY, button, isTouch, presses)
		end
	end
end
function love.mousereleased(mouseX, mouseY, button, isTouch, presses)
	local mouseX, mouseY = windowToGame(mouseX, mouseY)
	
	if draggingElement and button == draggingElement.dragButton then
		draggingElement.dragging = false
		draggingElement:mouseDropped(mouseX, mouseY, button, isTouch, presses)
		draggingElement = nil
	end
	
	updateHover(mouseX, mouseY)
	game:mouseReleasedAnywhere(mouseX, mouseY, button, isTouch, presses)
	if hoveringElement then hoveringElement:mouseReleased(mouseX, mouseY, button, isTouch, presses) end
end
function love.mousemoved(mouseX, mouseY, deltaX, deltaY, touch)
	local aspect = getAspectRatio()
	local mouseX, mouseY = windowToGame(mouseX, mouseY)
	local deltaX, deltaY = (deltaX / aspect), (deltaY / aspect)
	
	if draggingElement then draggingElement:mouseDrag(mouseX, mouseY, deltaX, deltaY, touch) end
	
	updateHover(mouseX, mouseY)
	game:mouseMovedAnywhere(mouseX, mouseY, deltaX, deltaY, touch)
	if hoveringElement then hoveringElement:mouseMoved(mouseX, mouseY, deltaX, deltaY, touch) end
end

function updateHover(mouseX, mouseY)
	if draggingElement then return end
	
	local prevHovering = hoveringElement
	hoveringElement = game:getHoveringElement(mouseX, mouseY)
	
	if prevHovering ~= hoveringElement and prevHovering then prevHovering:setHovering(false) end
	if hoveringElement then hoveringElement:setHovering(true) end
end
function updateCursor()
	if draggingElement then
		love.mouse.setCursor(cursors.drag)
	elseif hoveringElement and (hoveringElement.cursor or hoveringElement.useHand) and hoveringElement:canBeClicked() then
		love.mouse.setCursor(hoveringElement.cursor and cursors[hoveringElement.cursor] or cursors.hand)
	else
		love.mouse.setCursor(cursors.pointer)
	end
end
function reloadCursors()
	cursors = {
		pointer = love.mouse.newCursor(love.image.newImageData('resources/cursor.png'));
		drag = love.mouse.newCursor(love.image.newImageData('resources/drag.png'), 9, 6);
		hand = love.mouse.newCursor(love.image.newImageData('resources/hand.png'), 4);
	}
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
	if love.timer then love.timer.step() end
	
	local accumulator = 0
	return function()
		if love.event then -- Process events.
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
		
		accumulator = (accumulator + love.timer.step())
		
		if accumulator >= (flags.useFrameskip and Constants.tickPerSecond or tickPerSecond) then
			if love.update then
				if flags.useFrameskip then
					for i = 1, math.floor(math.min(flags.maxFrameskip, accumulator)) do
						game:update(1 / Constants.tickPerSecond)
					end
					
					accumulator = (accumulator % 1)
				else
					love.update(math.min(accumulator, flags.maxFrameskip / Constants.tickPerSecond))
					
					accumulator = 0
				end
			end

			if love.graphics and love.graphics.isActive() then
				love.graphics.origin()
				love.graphics.clear(love.graphics.getBackgroundColor())

				if love.draw then love.draw() end

				love.graphics.present()
			end
		end
		
		love.timer.sleep(.0001)
	end
end
function love.update(dt)
	game:update(dt)
	
	updateHover(windowToGame(love.mouse:getPosition()))
	updateCursor()
	
	gcTimer = (gcTimer - dt)
end
function love.draw()
	love.graphics.setCanvas(debugCanvas)
	love.graphics.clear()
	love.graphics.setCanvas()
	
	local ratio = getAspectRatio()
	local winW, winH = love.graphics.getDimensions()
	local gameOffsetX, gameOffsetY = windowToGame(0, 0)
	
	love.graphics.push()
	love.graphics.setColor(1, 1, 1)
	love.graphics.scale(ratio, ratio)
	love.graphics.translate(-gameOffsetX, -gameOffsetY)
	
	game:draw(game.x, game.y)
	game:drawTop(game.x, game.y)
	
	love.graphics.pop()
	love.graphics.setColor(0, 0, 0)
	
	local borderW, borderH = (gameOffsetX * ratio), (gameOffsetY * ratio)
	local wr, hr = (winW / gameWidth), (winH / gameHeight)
	if wr > hr then
		love.graphics.rectangle('fill', 0, -borderH, -borderW, gameHeight * ratio)
		love.graphics.rectangle('fill', winW + borderW, -borderH, -borderW, gameHeight * ratio)
	elseif wr < hr then
		love.graphics.rectangle('fill', -borderW, 0, gameWidth * ratio, -borderH)
		love.graphics.rectangle('fill', -borderW, winH + borderH, gameWidth * ratio, -borderH)
	end
	
	game:drawWindow()
	drawDebug()
end

function getAspectRatio()
	local winW, winH = love.graphics.getDimensions()
	return math.min(
		winW / gameWidth,
		winH / gameHeight
	)
end
function windowToGame(x, y)
	local ratio = getAspectRatio()
	local winW, winH = love.graphics.getDimensions()
	return (math.round(x - (winW - gameWidth * ratio) * .5) / ratio), (math.round(y - (winH - gameHeight * ratio) * .5) / ratio)
end
function gameToWindow(x, y)
	local ratio = getAspectRatio()
	local winW, winH = love.graphics.getDimensions()
	return (math.round(x + (winW / ratio - gameWidth) * .5) * ratio), (math.round(y + (winH / ratio - gameHeight) * .5) * ratio)
end

function drawDebug()
	if gcTimer < 0 then
		gcTimer = (gcTimer + 1 / 15)
		gc = collectgarbage('count')
		stats = love.graphics.getStats()
		objs = game:getCount()
	end
	
	local time = love.timer.getTime()
	table.insert(drawtime, time)
	while drawtime[1] < time - 1 do
		table.remove(drawtime, 1)
	end
	local fps = math.round((fpsCount + #drawtime) / 2)
	fpsCount = #drawtime
	
	love.graphics.setCanvas(debugCanvas)
	
	local text = ('%d fps\n%d mb\n%d objects\n%d drawcalls'):format(fps, ((stats.texturememory / 1024) + gc) / 1024, objs, stats.drawcalls)
	love.graphics.setColor(1, 1, 1)
	debugInfo:setText(text)
	debugInfo:draw(5, 5)
	
	love.graphics.setCanvas()
	
	love.graphics.setColor(0, 0, 0)
	for ang = 0, 7 do
		local rad = (ang * math.pi * .25)
		love.graphics.draw(debugCanvas, math.round(math.cos(rad)), math.round(math.sin(rad)))
	end
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(debugCanvas)
end