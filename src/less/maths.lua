local m = {}

m.gt    = function(x,y) return x>y end
m.lt    = function(x,y) return x<y end
m.abs   = math.abs
m.log   = math.log
m.sin   = math.sin
m.cos   = math.cos
m.sqrt  = math.sqrt
m.pi    = math.pi
m.e     = math.exp(1)
m.r     = math.random
m.srand = math.randomseed

function m.round(x,d,  n) n=10^(d or 0); return math.floor(x*n+0.5) / n end

return m
