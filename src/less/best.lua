local my      = require"my"
local obj,has = my.get"metas obj has"
local rand    = my.get"rands  rand"

local Best=obj"Best"
function Best.new() return has(Best,{total=0, all={}, keep=my.keep) end

function Best:add(k,v)
  pos = bchop(self.all,{k,v},firsts)
  if pos > #self.best-self.keep then
    table.insert(self.best,pos,{k,v}) 
    self.total = self.total + k end end

function Best:one()
  local r=rand()*self.all
  for i = #self.all,1,-1 do
    r = r - self.all[i][1]
    if r<=0 then return self.all[i][2] end end
  return self.all[1][2] end

return Best
