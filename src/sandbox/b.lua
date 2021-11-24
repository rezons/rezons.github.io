local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
----------------------------------------------

local lunatic, Lambda, Hint, From, Local, Return, Self
local fmt = string.format

function lunatic(s,todo,      act)
  function act(t)
    for k,f in pairs(t) do if (todo or {})[k] ~= false then s=f(s) end end end
  act{Lambda=Lambda}
  act{Local=Local,Self=Self,Return=Return,From=From,Hint=Hint} 
  return s end

function Local(s)  return s:gsub("`","local ") end
function Return(s) return s:gsub("(%s)^"," return ")end
function Self(s)   return s:gsub("%f[%w_]o%f[^%w_]","self") end
function Lambda(s) 
  return s:gsub("(`)(%b())", 
           function(_,b) return fmt("function %s end", b:sub(2,#b-1)) end) end
 
function Hint(s)
  return s:gsub("(function[^\n]+)(%b())(%s*:[^\n]*)\n",
           function(a,b,c) return fmt("%s%s\n",a,b:gsub(":[^,)]+","")) end) end

function From(s,        act)
  function act (file, wants,     t,pre,post) 
    t={}; for want in wants:gmatch("([^ ]+)") do t[#t+1] = want end
    pre,post = t[1], fmt('require("%s").%s',file ,t[1]) 
    for i=2,#t do
      pre  = pre  ..  ", " .. t[i] 
      post = post ..  ", " .. fmt('require("%s").%s',file, t[i]) end
    return "\nlocal "..pre .." = "..post.."\n"  end 
  return s:gsub("\nfrom%s+([^\n]*)%s+import([^\n]*)\n", act) end


-- return lunatic
----------------------------------------------

local s = lunatic[[

from f1 import aa mm nn

function asda(a : ?[int],b:num) : fasdas
  return o end

`function X:bad(c:num,d) :nil
   x= map(d, `((x) ^x+(1/math.exp(1))))
   ^o.bad end

^aa

`((x) a (1 1+3 ^(aa)))

`((y) ^a)
]]

print(s)

----------------------------------------------
for k,v in pairs(_ENV) do if not b4[k] then print("?? rogue",k,type(v)) end end 
