local get,help,cli,updateFromCommandLine

function get(s,   t,u)
  for x in s:gmatch("%w+") do 
    if not t then t,u = require(x),{} else u[ 1+#u ] = t[x] end end
  return table.unpack(u) end

function help(opt,    show,b4,s)
  s= opt.what .. "\n" .. opt.when .. "\n\nOPTIONS:"
  function show(x) 
    if #x[1]>0 and x[1] ~= b4 then s=s.."\n"..x[1]..":\n" end
    b4 = x[1]
    s = s..string.format("  %3s  %s [%s]\n", x[3],x[5],x[4]) end
  for _,four in pairs(opt.how) do show(four) end
  return s end

function updateFromCommandLine(fours,    x)
  x={}
  for _,t in pairs(fours) do
    x[t[2]] = t[4]
    for n,word in ipairs(arg) do if word==t[3] then
    x[t[2]] = (t[4]==false) and true or tonumber(arg[n+1]) or arg[n+1] end end end 
  return x end

function cli(t,  b4,the) 
  the = updateFromCommandLine(t.how)
  the._b4 = {}
  for k,v in pairs(_ENV) do the._b4[k]=v end
  the._help = help(t)
  the.get = get  
  return the end

return cli
