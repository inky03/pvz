local Sound = {}

function Sound.play(path, deviation, pitch)
	local snd = Cache.sound(path)
	if snd then
		local snd = snd:clone()
		local pitch = (pitch or 1)
		local deviation = (deviation or 0)
		snd:setPitch(random.number(pitch, pitch + deviation / 100))
		snd:play()
		return snd
	end
	return nil
end

function Sound.playRandom(paths, deviation, pitch)
	return Sound.play(random.object(paths), deviation, pitch)
end

return Sound