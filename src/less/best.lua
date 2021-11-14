local my      = require"my"
local obj,has = my.get"metas obj has"
local rand    = my.get"rands  rand"

local Best=obj"Best"
function Best.new(inits,  self) 
  return has(Best,{keep=my.keep,
                   total= sum(inits, function(x) return x[1] end),
                   all =sort(inits, function(x,y) return  x[1] < y[1] end)}) end

function Best:add(k,v, border,pos)
  border = #self.all - self.keep
  if border<1 then border = #self.all//2 end
  if #self.all < self.keep or k > self.all[border][1] then
    pos = bchop(self.all,{k,v},firsts)
    push(self.best,pos,{k,v}) 
    self.total = self.total + k 
  end end 

function Best:one()
  local r=rand()*self.all
  for i = #self.all,1,-1 do
    r = r - self.all[i][1]
    if r<=0 then return self.all[i][2] end end
  return self.all[1][2] end

return Best
