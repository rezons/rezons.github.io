package.path = '../src/?.lua'
local Cocomo = require"xomo"

local c,e1,e2
for _=1,10 do
  local c=Cocomo.new{loc={1800,2000}}
  e1= c:effort()
  local c=Cocomo.new{loc={2,2}}
  e2= c:effort()
  print(e1/e2)
end
