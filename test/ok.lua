package.path = '../src/?.lua'
local b4={}; for k,v in pairs(_ENV) do b4[k]=v end

local red,green
function red(...) print('\27[1m\27[31m'..string.format(...)..'\27[0m') end
function green(...)  print('\27[1m\27[32m'..string.format(...)..'\27[0m') end

local fails=0

for _,f in ipairs(arg) do
  if f ~= "ok.lua" and f ~= "lua" then
    local ok,msg = pcall(dofile,f) 
    if   ok 
    then green("%s",f)
    else red("%s",tostring(msg)); fails=fails+1 end end end 

for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v))  end end 
print(2)
os.exit(fails)
