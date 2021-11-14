local my      = require"my"
local obj,has = my.get"metas obj has"
local rand    = my.get"rands rand"

local key=function(x) return x[1] end
local val=function(x) return x[2] end
local firsts=function(x,y) return  x[1] < y[1] end

local Best=obj"Best"
function Best.new(keep,inits,  self) return has(Best,
  {keep=keep or 10, total=sum(inits, key), all=sort(inits, firsts)}) end

function Best:add(k,v, border,pos)
  border = #self.all - self.keep
  if border<1 then border = #self.all//2 end
  if #self.all < self.keep or k > key(self.all[border])then
    pos = bchop(self.all,{k,v},firsts)
    push(self.best,pos,{k,v}) 
    self.total = self.total + k 
  end end 

function Best:one()
  local r=rand()*self.total
  for i = #self.all,1,-1 do
    r = r - key(self.all[i])
    if r<=0 then return val(self.all[i]) end end
  return val(self.all[1]) end

return Best
