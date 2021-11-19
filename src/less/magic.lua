local function helpString(opt,    show,b4,s)
  s= opt.what .. "\n" .. opt.when .. "\n\nOPTIONS:"
  function show(x) 
    if #x[1]>0 and x[1] ~= b4 then s=s.."\n"..x[1]..":\n" end
    b4 = x[1]
    s = s..string.format("  %3s  %s [%s]\n", x[3],x[5],x[4]) end
  for _,four in pairs(opt.how) do show(four) end
  return s end

local function updateFromCommandLine(fours,    x)
  x={}
  for _,t in pairs(fours) do
    x[t[2]] = t[4]
    for n,word in ipairs(arg) do if word==t[3] then
    x[t[2]] = (t[4]==false) and true or tonumber(arg[n+1]) or arg[n+1] end end end 
  return x end

local function someFunsFromFile(s,   t,u)
  for x in s:gmatch("%w+") do 
    if not t then t,u = require(x),{} else u[ 1+#u ] = t[x] end end
  return table.unpack(u) end
  
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

local function rogues(b4)
  for k,v in pairs(_ENV) do 
    if not b4[k] then 
      print("?? rogue",k,type(v)) end end end

return function(t)
  local function what2do(_,thing)
    if thing=="END"  then return rogues(b4)    end
    if thing=="HELP" then return helpString(t) end
    return someFunsFromFile(thing)  
  end --
  return setmetatable(updateFromCommandLine(t.how), {__call=what2do}) end

