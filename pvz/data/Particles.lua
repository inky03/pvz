local ParticlesTrackNode = class('ParticlesTrackNode')

function ParticlesTrackNode:init(time, low, high, curve, distribution)
	self.time, self.low, self.high = (time or 0), (low or 0), (high or low or 0)
	self.curve, self.distribution = Particles.getCurve(curve), Particles.getCurve(distribution)
end
function ParticlesTrackNode:__tostring()
	local range = (self.high ~= self.low and '%d;%d' or '%d'):format(math.round(self.low * 1000) / 1000, math.round(self.high * 1000) / 1000)
	return ('ParticlesTrackNode(time:%d, value:%s)'):format(self.time, range)
end


local Particles = class('Particles')

Particles.ParticlesTrackNode = ParticlesTrackNode
Particles.flags = {
	randomLaunchSpin = 0;
	alignLaunchSpin = 1;
	alignToPixels = 2;
	systemLoops = 3;
	particleLoops = 4;
	particlesDontFollow = 5;
	randomStartTime = 6;
	dieIfOverloaded = 7;
	additive = 8;
	fullscreen = 9;
	softwareOnly = 10;
	hardwareOnly = 11;
}
Particles.fieldTypes = {
	'Invalid' ;
	'Friction' ; 'Acceleration'; 'Attractor' ; 'MaxVelocity' ; 'Velocity' ;
	'Position' ; 'SystemPosition' ; 'GroundConstraint' ;
	'Shake' ; 'Circle' ; 'Away'
}
Particles.curveTypes = {
	'Constant' ; 'Linear' ;
	'EaseIn' ; 'EaseOut' ; 'EaseInOut' ; 'EaseInOutWeak' ;
	'FastInOut' ; 'FastInOutWeak' ; 'WeakFastInOut' ;
	'Bounce' ; 'BounceFastMiddle' ; 'BounceSlowMiddle' ; 'SinWave' ; 'EaseSinWave'
}
Particles.emitterTypes = {
	'Circle' ; 'Box' ; 'BoxPath' ; 'CirclePath' ; 'CircleEvenSpacing'
}
Particles.curves = { -- TODO: update curve and finish
	Linear = Curve.LINEAR;
	EaseIn = Curve.QUAD_IN; EaseOut = Curve.QUAD_OUT; EaseInOut = Curve.QUAD_IN_OUT;
	Bounce = Curve.BOUNCE_OUT;
}
Particles.definitions = { -- yup !
	{'systemDuration', nil};
	{'spawnRate', 0};
	{'spawnMinActive', nil};
	{'spawnMaxActive', nil};
	{'spawnMaxLaunched', nil};
	{'emitterRadius', 0};
	{'emitterOffsetX', 0};
	{'emitterOffsetY', 0};
	{'emitterBoxX', 0};
	{'emitterBoxY', 0};
	{'emitterSkewX', 0};
	{'emitterSkewY', 0};
	{'particleDuration', 100};
	{'launchSpeed', 0};
	{'systemRed', 1};
	{'systemGreen', 1};
	{'systemBlue', 1};
	{'systemAlpha', 1};
	{'systemBrightness', 1};
	{'launchAngle', 0};
	{'crossFadeDuration', 0};
	{'particleRed', 1};
	{'particleGreen', 1};
	{'particleBlue', 1};
	{'particleAlpha', 1};
	{'particleBrightness', 1};
	{'particleSpinAngle', 0};
	{'particleSpinSpeed', 0};
	{'particleScale', 1};
	{'particleStretch', 1};
	{'collisionReflect', 0};
	{'collisionSpin', 0};
	{'clipTop', 0};
	{'clipBottom', 0};
	{'clipLeft', 0};
	{'clipRight', 0};
	{'animationRate', nil};
}
Particles.fieldIds = {} for i, field in ipairs(Particles.fieldTypes) do Particles.fieldIds[field] = i end
Particles.definitionIds = {} for i, def in ipairs(Particles.definitions) do Particles.definitionIds[def[1]] = i end

function Particles.getFieldName(field)
	return (type(field) == 'number' and Particles.fieldTypes[field + 1] or field)
end
function Particles.getCurveName(curve)
	return (type(curve) == 'number' and Particles.curveTypes[curve + 1] or curve)
end
function Particles.getCurve(curve)
	return (curve and Particles.curves[Particles.getCurveName(curve)] or Curve.LINEAR)
end

function Particles:init(name)
	self.emitters = {}
	self.images = {}
	self.name = name
end

function Particles.loadXML(path, kind)
	trace('XML currently unsupported')
	
	return Particles:new(kind)
end

function Particles.loadBinary(path, kind)
	local particle = Particles:new(kind)
	local bytePos = 0x08
	local null = -10000
	
	local data = Cache.decompressFile(path)
	local function readByte(kind, count)
		local prevByte = bytePos
		count = (count or 4)
		
		bytePos = (bytePos + count)
		local v = data:sub(prevByte + 1, prevByte + count)
		
		if kind == 'i32' then v = love.data.unpack('<i4', v)
		elseif kind == 'f32' then v = love.data.unpack('f', v)
		elseif kind == 'string' then --[[ well its already a string ]] end
		
		return v
	end
	local function throw(expected)
		error(('Particle file format mismatch at 0x%08x (expected 0x%02x)'):format(bytePos, expected))
	end
	local function readTrackNodes()
		local nodeCount = readByte('i32')
		if nodeCount == 0 then return nil end
		
		local trackNodes, v = {}, nil
		for i = 1, nodeCount do
			table.insert(trackNodes, ParticlesTrackNode:new(readByte('f32'), readByte('f32'), readByte('f32'), readByte('i32'), readByte('i32')))
		end
		
		return trackNodes
	end
	
	local emitterCount = readByte('i32')
	if readByte('i32') ~= 0x164 then throw(0x164) end
	
	local emitters, v = {}, nil
	for i = 1, emitterCount do
		bytePos = (bytePos + 4)
		
		local emitter = {}
		v = readByte('i32') if v ~= 0 then emitter.imageColumn = v end
		v = readByte('i32') if v ~= 0 then emitter.imageRow = v end
		v = readByte('i32') emitter.imageFrames = v
		v = readByte('i32') emitter.animated = (v ~= 0)
		v = readByte('i32') emitter.particleFlags = v
		v = readByte('i32') emitter.emitterType = v
		bytePos = (bytePos + 8)
		bytePos = (bytePos + 22 * 8)
		bytePos = (bytePos + 4)
		v = readByte('i32') emitter._fields = v
		bytePos = (bytePos + 4)
		v = readByte('i32') emitter._systemFields = v
		bytePos = (bytePos + 16 * 8)
		
		table.insert(emitters, emitter)
	end
	for i = 1, #emitters do
		local emitter = emitters[i]
		v = readByte('string', readByte('i32')) if #v > 0 then emitter.image = v end
		v = readByte('string', readByte('i32')) if #v > 0 then emitter.name = v end
		emitter.systemDuration = readTrackNodes()
		v = readByte('string', readByte('i32')) if #v > 0 then emitter.onDuration = v end
		
		if emitter.image then
			particle.images[emitter.image] = Particles.getResource(emitter.image)
		end
		
		for _, field in ipairs({ 'crossFadeDuration' ; 'spawnRate' ; 'spawnMinActive' ; 'spawnMaxActive' ; 'spawnMaxLaunched' ;
			'emitterRadius' ; 'emitterOffsetX' ; 'emitterOffsetY' ; 'emitterBoxX' ; 'emitterBoxY' ; 'emitterPath' ; 'emitterSkewX' ; 'emitterSkewY' ;
			'particleDuration' ;
			'systemRed' ; 'systemGreen' ; 'systemBlue' ; 'systemAlpha' ; 'systemBrightness' ;
			'launchSpeed' ; 'launchAngle' }) do
			emitter[field] = readTrackNodes()
		end
		if readByte('i32') ~= 0x14 then throw(0x14) end
		
		emitter.fields = {}
		emitter.systemFields = {}
		
		local fieldsArray = {}
		for i = 1, emitter._fields do
			local field = {}
			v = readByte('i32') local fieldName = Particles.getFieldName(v)
			emitter.fields[fieldName] = field
			table.insert(fieldsArray, fieldName)
			bytePos = (bytePos + 16)
		end
		for i = 1, emitter._fields do
			local fieldName = fieldsArray[i]
			emitter.fields[fieldName].x = readTrackNodes()
			emitter.fields[fieldName].y = readTrackNodes()
		end
		if readByte('i32') ~= 0x14 then throw(0x14) end
		
		table.clear(fieldsArray)
		for i = 1, emitter._systemFields do
			local field = {}
			v = readByte('i32') local fieldName = Particles.getFieldName(v)
			emitter.systemFields[fieldName] = field
			table.insert(fieldsArray, fieldName)
			bytePos = (bytePos + 16)
		end
		for i = 1, emitter._systemFields do
			local fieldName = fieldsArray[i]
			emitter.systemFields[fieldName].x = readTrackNodes()
			emitter.systemFields[fieldName].y = readTrackNodes()
		end
		
		emitter._fields, emitter._systemFields = nil, nil
		
		for _, field in ipairs({ 'particleRed' ; 'particleGreen' ; 'particleBlue' ; 'particleAlpha' ; 'particleBrightness' ;
			'particleSpinAngle' ; 'particleSpinSpeed' ;
			'particleScale' ; 'particleStretch' ;
			'collisionReflect' ; 'collisionSpin' ;
			'clipTop' ; 'clipBottom' ; 'clipLeft' ; 'clipRight' ;
			'animationRate' }) do
			emitter[field] = readTrackNodes()
		end
		
		for _, def in ipairs(Particles.definitions) do
			if not emitter[def[1]] and def[2] then
				emitter[def[1]] = {ParticlesTrackNode:new(0, def[2], def[2])}
			end
		end
		
		table.insert(particle.emitters, emitter)
	end
	
	return particle
end

function Particles.getEmitterType(emitter)
	return Particles.emitterTypes[emitter.emitterType + 1]
end
function Particles.getEmitterFlag(emitter, flag)
	local flagTest = Particles.flags[flag]
	if not flagTest then return trace('Invalid emitter flag: ' .. flag) end
	return (bit.band(emitter.particleFlags, bit.lshift(1, flagTest)) > 0)
end
function Particles.trackIsConstantZero(track)
	for i = 1, #track do
		local node = track[i]
		if node.low ~= 0 or node.high ~= 0 then
			return false
		end
	end
	return true
end

function Particles.evaluateTrack(track, time, interp)
	if #track == 0 then return 0 end
	
	if time < track[1].time then
		return Particles.evaluateCurve(interp, track[1].low, track[1].high, track[1].distribution)
	end
	
	for i = 2, #track do
		local nextNode = track[i]
		
		if time <= nextNode.time then
			local lastNode = track[i - 1]
			local progress = math.remap(time, lastNode.time, nextNode.time, 0, 1)
			local leftValue = Particles.evaluateCurve(interp, lastNode.low, lastNode.high, lastNode.distribution)
			local rightValue = Particles.evaluateCurve(interp, nextNode.low, nextNode.high, nextNode.distribution)
			return Particles.evaluateCurve(progress, leftValue, rightValue, lastNode.curve)
		end
	end
	
	local lastNode = track[#track]
	return Particles.evaluateCurve(interp, lastNode.low, lastNode.high, lastNode.distribution)
end
function Particles.evaluateCurve(time, first, last, curve)
	return math.lerp(first, last, curve(time))
end

function Particles.getResource(key)
	return (key and (Cache.image(key:gsub('IMAGE_', ''), 'particles', true) or Resources.fetch(key, 'Image')))
end

return Particles