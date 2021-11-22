local the      = require"the"
local r,srand  = the"maths r srand"
local obj,has  = the"metas obj has"
local firsts,sort,sum = the"tables firsts sort sum"

local key=function(x) return x[1] end
local val=function(x) return x[2] end

--- constructor   
-- No args
local Best=obj"Best"
function Best.new(inits:tab, keep:bool) :Best
  return has(Best, {keep=keep or 10, total=sum(inits, key), all=sort(inits, firsts)}) end

function Best:add(k:num, v:any,        border,pos) :nil
  border = #self.all - self.keep
  if border<1 then border = #self.all//2 end
  if #self.all < self.keep or k > key(self.all[border])then
    pos = bchop(self.all,{k,v},firsts)
    push(self.best,pos,{k,v}) 
    self.total = self.total + k end end 

function Best:one(   pos)
  print("!",math.random(),self.total)
  local enough = r()*self.total
  pos=1
  for i = #self.all,1,-1 do
    enough  = enough - key(self.all[i])
    if enough <=0 then pos=i; break end end
  print(key(self.all[1]), key(self.all[pos]), key(self.all[#self.all]))
  return val(self.all[pos]) end

return Best
