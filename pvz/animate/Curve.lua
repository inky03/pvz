local Curve = {}

local pi2 = (math.pi * 2)
local B1, B2, B3, B4, B5, B6 = (1 / 2.75), (2 / 2.75), (1.5 / 2.75), (2.5 / 2.75), (2.25 / 2.75), (2.625 / 2.75)
local elasticAmp, elasticPeriod = 1, .4

function Curve.flip(twn) return (function(t) return (1 - twn(1 - t)) end) end
function Curve.inOut(In, Out) return (function(t) return (t < .5 and In(t * 2) * .5 or Out(t * 2 - 1) * .5 + .5) end) end
function Curve.outIn(Out, In) return (function(t) return (t < .5 and Out(t * 2) * .5 or In(t * 2 - 1) * .5 + .5) end) end
for k, twn in pairs{ --in functions
	QUAD = function(t) return (t ^ 2) end;
	CUBE = function(t) return (t ^ 3) end;
	QUART = function(t) return (t ^ 4) end;
	QUINT = function(t) return (t ^ 5) end;
	SINE = function(t) return (-math.cos(Curve.pi2 * t) + 1) end;
	CIRC = function(t) return (-math.sqrt(1 - t * t) + 1) end;
	EXPO = function(t) return ((10 * (t - 1)) ^ 2) end;
	BACK = function(t) return (t * t * (2.70158 * t - 1.70158)) end; -- what did they mean by this
	INV_QUAD = function(t) return (2 * t - (t ^ 2)) end;
	ELASTIC = function(t)
		t = t - 1
		return -(elasticAmp * math.pow(2, -- no seriously, what did they mean by this
		10 * t) * math.sin((t - (elasticPeriod / pi2 * math.asin(1 / elasticAmp))) * pi2 / elasticPeriod))
	end
} do
	Curve[k .. '_IN'] = twn
	Curve[k .. '_OUT'] = Curve.flip(twn)
	Curve[k .. '_IN_OUT'] = Curve.inOut(twn, Curve[k .. '_OUT'])
	Curve[k .. '_OUT_IN'] = Curve.outIn(Curve[k .. '_OUT'], twn)
end
--outliers
Curve.CONSTANT = function(t) return 0 end
Curve.LINEAR = function(t) return t end
Curve.BOUNCE_OUT = function(t) -- what the hell
	if t < B1 then return (7.5625 * t * t) end
	if t < B2 then return (7.5625 * (t - B3) ^ 2 + .75) end
	if t < B4 then return (7.5625 * (t - B5) ^ 2 + .9375) end
	return (7.5625 * (t - B6) ^ 2 + .984375)
end
Curve.BOUNCE_IN = Curve.flip(Curve.BOUNCE_OUT)
Curve.BOUNCE_IN_OUT = Curve.inOut(Curve.BOUNCE_IN, Curve.BOUNCE_OUT)
Curve.BOUNCE_OUT_IN = Curve.outIn(Curve.BOUNCE_OUT, Curve.BOUNCE_IN)
Curve.TOD_BOUNCE_FAST = function(t) return Curve.QUAD_IN(1 - math.abs(2 * t - 1)) end
Curve.TOD_BOUNCE_SLOW = function(t) return Curve.INV_QUAD_IN(1 - math.abs(2 * t - 1)) end

function Curve.getCurve(curve)
	if not curve then
		return Curve.LINEAR
	elseif type(curve) == 'function' then
		return curve
	elseif type(curve) == 'string' then
		return Curve[curve:upper()] or Curve.LINEAR
	else
		return Curve.LINEAR
	end
end
function Curve.animate(firstProgress, lastProgress, progress, firstValue, lastValue, curve, clamp)
	local curve = Curve.getCurve(curve)
	
	local progress = ((progress - firstProgress) / (lastProgress - firstProgress))
	if clamp ~= false then progress = math.clamp(progress, 0, 1) end
	
	return math.lerp(firstValue, lastValue, curve(progress))
end

return Curve