local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
----------------------------------------------
local function map(t,f,  u,y,z) 
  u={}
  for k,x in pairs(t) do 
    y,z = f(k,x) 
    if y ~= nil then
      if z==nil then u[#u+1]=y else u[y]=x end end end
  return u end
----------------------------------------------
-- Call `f(key,value)` on all items  in list.
local lunatic, inquire

function lunatic(s,control)
  local Local,Return,Self,Lambda,Hint,From,act,fmt
  fmt = string.format
  function Local(s) return s:gsub("`","local ") end

  function Self(s) return s:gsub("%f[%w_]o%f[^%w_]","self") end

  function Return(s) 
    return s:gsub("(%s)^",
      function(b4) return b4.." return " end) end

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

  function act(t)
    for k,f in pairs(t) do 
      if (control or {})[k] ~= false then s=f(s) end end end

  act{Lambda=Lambda}
  act{Local=Local,Self=Self,Return=Return,From=From,Hint=Hint} 
  return s end

local seen={}
function inquire(path,    file,content)
  if   seen[path] 
  then return seen[path]
  else file = io.input(path)
       content = file:read "*a" 
       io.close(file)
       seen[path] = load(lunatic(content))()
       return seen[path] end end

-- return lunatic
local function demo()
 return print(lunatic[[

from f1 import aa mm nn

function asda(a : ?[int],b:num) : fasdas
  return o end

`function X:bad(c:num,d) :nil
   x= map(d, `((x) ^x+(1/math.exp(1))))
   ^o.bad end

^aa

map(x,`((_,y) 

^x+1))

]]) end

demo()
----------------------------------------------
for k,v in pairs(_ENV) do if not b4[k] then print("?? rogue",k,type(v)) end end 


return inquire

