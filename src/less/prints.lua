local the = require"the"
local sort,cat,map,keys = the"tables sort cat map keys"
local fmt,shout,out,red,green,yellow,blue

fmt = string.format

function red(s)    return "\27[1m\27[31m"..s.."\27[0m" end
function green(s)  return "\27[1m\27[32m"..s.."\27[0m" end
function yellow(s) return "\27[1m\27[33m"..s.."\27[0m" end
function blue(s)   return "\27[1m\27[36m"..s.."\27[0m" end

-- Generate  a pretty-print string from a table (recursively).
function out(t,    seen,u,f1,f2)
  function key(_,k)   return fmt(":%s %s",yellow(k),out(t[k],seen)) end
  function value(_,v) return out(v,seen) end
  if type(t) == "function" then return "FUN" end
  if type(t) ~= "table"    then return tostring(t) end
  seen = seen or {}
  if   seen[t]
  then return "..."
  else seen[t] = t
       u = #t==0 and map(keys(t),key) or map(t,value)
       return blue(t._is or"")..blue("{")..cat(u," ")..blue("}") end end

-- Print a pretty-print string.
function shout(x) print(out(x)) end

return {red=red,green=green,yellow=yellow,blue=blue,
        out=out,shout=shout,fmt=fmt}
