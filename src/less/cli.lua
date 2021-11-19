local function generateHelpString(opt,    show,b4,s)
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

local function getSomeFunctionsFromFile(s,   t,u)
  for x in s:gmatch("%w+") do 
    if not t then t,u = require(x),{} else u[ 1+#u ] = t[x] end end
  return table.unpack(u) end

local function rogues(now, before)
  for k,v in pairs(now) do
    if not before[k] then
       print("?? rogue",k,type(v)) end end end

local function cli(t,  b4,the) 
  the = updateFromCommandLine(t.how)
  the._etc={}
  the.__call  = the._etc.get
  the._etc= {help   = generateHelpString(t),
             get    = getSomeFunctionsFromFile,  
             b4     = {},
             rogues = function() rogies(_ENV,the._etc.b4) end}
  for k,v in pairs(_ENV) do the._etc.b4[k]=v end
    return the end

return cli
