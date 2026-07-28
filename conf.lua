function love.conf(t)
	t.accelerometerjoystick = false
	
	t.identity = 'pvz-love'
	t.release = false
	t.console = true
	
	t.modules.physics = false
	t.modules.thread = false
	t.modules.video = false
	t.modules.event = true
	t.modules.timer = true
	t.modules.mouse = true
	
	t.window.width = 800
	t.window.height = 600
	t.window.vsync = false
	t.window.resizable = true
	t.window.usedpiscale = false
	t.window.identity = 'pvz-love'
	t.window.title = 'Plants Vs. Zombies'
	
	local major = love.getVersion()
	if major >= 12 then
		t.graphics.renderers = {'vulkan'}
	end
	
	-- project flags
	flags = {
		complex = true;
		debugMode = true;
		useFrameskip = false;
		maxFrameskip = 15;
		maxFramerate = 120;
	}
end