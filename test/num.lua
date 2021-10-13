package.path = '../src/?.lua'
math.randomseed(require("about")().seed)

local Num=require"num"

local function ish(x,y,e) return math.abs(x-y) < (e or 0.01) end

local function norm(mu,sd)
  return mu + sd*(-2*math.log(math.random()))^.5*math.cos(2*math.pi*math.random()) end

local n = Num.new()
for _ = 1,100 do n:add(norm(10,1)) end
assert(ish(n.mu, 10, .05) and ish(n.sd, 1, 0.05))
assert(ish(n:norm(10), .5, 0.05))

local t,sd,n = {},{},Num.new()
for _ = 1,100    do t[1+#t] = norm(10,1) end
for i = 1,100    do n:add(t[i]); sd[i]=n.sd end
for i = 100,5,-1 do assert(ish(n.sd, sd[i], .05)); n:sub(t[i]) end

local left,right = Num.new(), Num.new()
for _ = 1,100 do left:add(norm(10,1)); right:add(norm(20,5)) end
assert(ish( 12.3,  left:border(right), .01))
