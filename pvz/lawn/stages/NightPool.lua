local Lawn = Cache.module('pvz.lawn.Lawn')
local DayPool = Cache.module('pvz.lawn.stages.DayPool')
local NightPool = DayPool:extend('NightPool')

local NightPoolEffect = Cache.module('pvz.lawn.stages.objects.PoolEffect'):extend('NightPoolEffect')
NightPoolEffect.glistening = false
NightPoolEffect.causticAlpha = (0x30 / 255)
NightPoolEffect.textureName = 'pool_night'
NightPoolEffect.baseTextureName = 'pool_base_night'
NightPoolEffect.shadingTextureName = 'pool_shading_night'

NightPool.textureName = 'background4'
NightPool.poolEffect = NightPoolEffect

return NightPool