local my  = require"my"
local fmt = my.get"funs fmt"
local map = my.get"tables map"

local cli,help
function cli(old,a,    x)
  x={}
  for _,t in pairs(old) do
    x[t[2]] = t[4]
    for n,word in ipairs(a) do if word==t[3] then
      x[t[2]] = (t[4]==false) and true or tonumber(a[n+1]) or a[n+1] end end end 
  return x end

function  help(    show,b4)
  function show(_,x) 
    if #x[1]>0 and x[1] ~= old then print("\n"..x[1]..":") end
    b4 = x[1]
    print(fmt("\t%4s %20s %s [%s]", x[3],x[4],x[5],x[1])) end
  print(the.what,"\n",the.how,"\n\nOPTIONS:")
  map(the.how,show) end

return {cli=cli, help=help}
