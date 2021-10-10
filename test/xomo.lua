package.path = '../src/?.lua'
local obj=require"obj"
local Cocomo = require"xomo"

for _=1,100 do
  local c=Cocomo.new{loc={1800,2000}}
  e1= c:effort()
  local c=Cocomo.new{loc={2,2}}
  e2= c:effort()
  print(e1/e2)
end
