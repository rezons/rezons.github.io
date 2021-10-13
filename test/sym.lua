package.path = '../src/?.lua'
math.randomseed(1)
local Sym=require"sym"

local function ish(x,y,e) return math.abs(x-y) < (e or 0.01) end

local s = Sym.new()
for _,x in pairs{"a","b","b","c","c","c","c"} do s:add(x)  end
assert(ish(1.378,s:spread(), .01))

local t,e,s = {},{},Sym.new()
for _ = 1,100    do t[1+#t] = tostring(math.random(10)//1) end
for i = 1,100    do s:add(t[i]); e[i]=s:spread()  end
for i = 100,10,-1 do assert(ish(s:spread(), e[i])); s:sub(t[i]) end
