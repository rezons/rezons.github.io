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
  
function collect(t,f,walk,  u) 
  walk = walk or pairs
  u={}
  for k,x in walk(t) do 
    x,also = f(k,x) 
    if   also == nil 
    then if x~= nil then u[#u+1] = x end
    else if x~= nil then u[x] = also end end end
  return u end

-- s=s:gsub("[(](.*)for.*(%w).*in(.*)[)]",five)
-- s=s:gsub("[(](.*)for.*(%w).*on(.*)[)]",five)
  
-- s=s:gsub("[(](.*)for.*(%w)%s*,%s*(%w).*in(.*)[)]",five)
-- s=s:gsub("[(](.*)for.*(%w)%s*,%s*(%w).*on(.*)[)]",five)

function Comprehension(s,   act)
  function collect(a,b,c,d,e)
    return fmt("collect(%s,function (%s,%s) return %s end),%s)",
               a,b,c,d,e) end
  function pairs1(src,x,t)    return collect(t,"_",x,src,"pairs") end
  function pairs2(src,k,x,t)  return collect(t,k,   x,src,"pairs") end
  function ipairs1(src,x,t)   return collect(t,"_",x,src,"ipairs") end
  function ipairs2(src,k,x,t) return collect(t,k,  x,src,"ipairs") end

  s= s:gsub("`[(](.*)for%s+(%S+)%s*,%s*(%S+)%s+in(.*)[)]", ipairs2) 
  s= s:gsub("`[{](.*)for%s+(%S+)%s*,%s*(%S+)%s+in(.*)[}]",  pairs2) 
  s= s:gsub("`[(](.*)for%s+(%S+)%s+in(.*)[)]", ipairs1) 
  s= s:gsub("`[{](.*)for%s+(%S+)%s+in(.*)[}]",  pairs1) 
  return s end

s=Comprehension("`(assa() and b(aa) for aa , bb in sds(aa))"); print(100,s)
s=Comprehension("`{assa() and b(aa) for aa , bb in sds(aa)}"); print(200,s)
s=Comprehension("`{assa() and b(aa)  for    aa   in sds })");  print(300,s)
s=Comprehension("`{assa() and b(aa)  for    aa   in sds })");  print(400,s)

