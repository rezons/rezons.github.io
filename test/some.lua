package.path = '../src/?.lua'
math.randomseed(require("about")().seed)

local Some=require"some"

local function ish(x,y,e) return math.abs(x-y) < (e or 0.01) end

local function norm(mu,sd)
  return mu + sd*(-2*math.log(math.random()))^.5*math.cos(2*math.pi*math.random()) end

local s = Some.new()
for _ = 1,1000 do s:add(norm(10,1)) end
assert(ish(s:mid(), 10, .1) and ish(s:spread(), 1, 0.1))
assert(256 == #s:all())
