package.path = '../src/?.lua'
local Cocomo = require"xomo"

for _=1,10 do
  local x=Cocomo.new()
  print(x:effort())
end
