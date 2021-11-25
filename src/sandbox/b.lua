local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
----------------------------------------------

-- Call `f(key,value)` on all items  in list.
local lunatic, Lambda, Hint, From, Local, Return, Self
local fmt = string.format

function lunatic(s,todo,      act)
  function act(t)
    for k,f in pairs(t) do if (todo or {})[k] ~= false then s=f(s) end end 
  end
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
  function act (file,wants,     sep,pre,post) 
    sep,pre,post = "","",""
    for want in wants:gmatch("([^ ]+)") do 
      pre  = pre  .. sep .. want
      post = post .. sep .. fmt('require("%s").%s',file,want) 
      sep  = ", " end
    return fmt("\nlocal %s = %s\n",pre,post) 
  end
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
  
function collect(t,f,walk,n,  u) 
  walk = walk or pairs
  u={}
  for k,x in walk(t) do 
    if n==2 
    then x,also = f(k,x) 

    else x,also=f(x) end 
    if   also == nil 
    then if x~= nil then u[#u+1] = x end
    else if x~= nil then u[x] = also end end end
  return u end

-- s=s:gsub("[(](.*)for.*(%w).*in(.*)[)]",five)
-- s=s:gsub("[(](.*)for.*(%w).*on(.*)[)]",five)
  
-- s=s:gsub("[(](.*)for.*(%w)%s*,%s*(%w).*in(.*)[)]",five)
-- s=s:gsub("[(](.*)for.*(%w)%s*,%s*(%w).*on(.*)[)]",five)

--- `[x+2 for x          in lst] ==> collect(lst, function(_,x) return x+2 end, pairs,1)
--- `[print(x,y) for x,y in lst] ==> collect(lst, function(k,x) return print(x,y) end,pairs,2)
--- `[print(x,y) for x,y on lst] ==> collect(lst, function(k,x) return print(x,y) end,ipairs,2)
--- `[print(x,y) for x,y on lst] ==> collect(lst, function(k,x) return print(x,y) end,ipairs,2)

-- function Comprehend(s)
--   function two(src,args,how,t) 
--     return fmt("collect(%s,function(%s) return %s end,%s,2)",
--                t, args, body, how=="in" and "pairs" or "ipairs") end
--   function one(src,args,how,t) 
--     return fmt("collect(%s,function(_,%s) return %s end,%s,1)",
--                t, args, body, how=="in" and "pairs" or "ipairs") end
--   function act(s)
--     s = s:gsub("[(](.*)%sfor%s+(%w,%w)%s+(in|on)(.*)[)]",  two)
--     s = s:gsub("[(](.*)%sfor%s+%w%s+(in|on))(.*)[)]",       one)
--     return s
--   end
--   return s:gsub("`(%b[])",act) end
-- s="(assa    aa , bb  sds )"; s=s:gsub("[(].*(%w)%s*,%s*(%w).*[)]",two)
