local my           = require"my"
local cat,fmt,sort = my.get"funs cat fmt sort"
local map,keys     = my.get"tables map keys"
local shout,out,red,green,yellow,blue

function red(s)    return "\27[1m\27[31m"..s.."\27[0m" end
function green(s)  return "\27[1m\27[32m"..s.."\27[0m" end
function yellow(s) return "\27[1m\27[33m"..s.."\27[0m" end
function blue(s)   return "\27[1m\27[36m"..s.."\27[0m" end

-- Generate  a pretty-print string from a table (recursively).
function out(t,    u,f1,f2)
  function f1(_,x) return fmt(":%s %s",yellow(x),out(t[x])) end
  function f2(_,x) return out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u = #t==0 and map(keys(t),f1) or map(t,f2)
  return blue(t._is or"")..blue("{")..cat(u," ")..blue("}") end

-- Print a pretty-print string.
function shout(x) print(out(x)) end

return {red=red,green=green,yellow=yellow,blue=blue,
        out=out,shout=shout}
