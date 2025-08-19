local Sound = {}

Sound.volume = 1

function Sound.play(path, deviation, pitch)
	if not path or path == '' then return nil end
	local snd = Cache.sound(path)
	if snd then
		local snd = snd:clone()
		local pitch = (pitch or 1)
		local deviation = (deviation or 0)
		snd:setPitch(random.number(pitch, pitch + deviation / 100))
		snd:setVolume(Sound.volume)
		snd:play()
		return snd
	end
	return nil
end

function Sound.playRandom(paths, deviation, pitch)
	return Sound.play(random.object(paths), deviation, pitch)
end

return Sound