local lib={}

--  __. ,              
-- (__ -+-._.*._  _  __
-- .__) | [  |[ )(_]_) 
--               ._|   
lib.fmt = string.format
function lib.say(...)  print(lib.fmt(...)) end
function lib.color(n,s)    return lib.fmt("\27[1m\27[%sm%s\27[0m",n,s) end
function lib.shout(x) print(lib.out(x)) end

function lib.out(t,     u,key,val)
  function key(_,k) return string.format(":%s %s", k, lib.out(t[k])) end
  function val(_,v) return lib.out(v) end
  if type(t) ~= "table" then return tostring(t) end
  u = #t>0 and lib.map(t, val) or lib.map(lib.keys(t), key) 
  return "{"..table.concat(u," ").."}" end 


-- Create an instance
function lib.has(mt,x) return setmetatable(x,mt) end
-- Create a clss
function lib.obj(s, o,new)
   o = {_is=s, __tostring=lib.out}
   o.__index = o
   return setmetatable(o,{__call = function(_,...) return o.new(...) end}) end

-- .___.   .  .      
--   |   _.|_ | _  __
--   |  (_][_)|(/,_) 
function lib.push(t,x)     t[ 1+#t ]=x; return x end
function lib.copy(t,  u)   u={};for k,v in pairs(t) do u[k]=v end; return u end

function lib.map(t,f,   u)    
  u,f={},f or same; for k,v in pairs(t) do u[1+#u] = f(k,v) end; return u end

function lib.keys(t,u)     
  u={}; for k,_ in pairs(t) do u[1+#u]=k end;return lib.sort(u);end

--  __.       ,        
-- (__  _ ._.-+-*._  _ 
-- .__)(_)[   | |[ )(_]
--                  ._|
function lib.sort(t,f)     table.sort(t,f); return t end
function lib.firsts(x,y)   return x[1] < y[1] end
function lib.seconds(x,y)  return x[2] < y[2] end

-- .  .    , .     
-- |\/| _.-+-|_  __
-- |  |(_] | [ )_) 
function lib.norm(lo,hi,x) 
  return math.abs(lo-hi)<1E-32 and 0 or (x-lo)/(hi-lo) end

function lib.sum(t,f,   n) 
  n,f=0,f or same; for _,v in pairs(t) do n = n + f(v)  end; return n end

-- .__         .        
-- [__) _.._  _| _ ._ _ 
-- |  \(_][ )(_](_)[ | )
function lib.randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end

function lib.rand(lo,hi)
  lo, hi = lo or 0, hi or 1
  the.seed = (16807 * the.seed) % 2147483647
  return lo + (hi-lo) * the.seed / 2147483647 end

-- .  .    ,    
-- |\/| _ -+- _.
-- |  |(/, | (_]
function lib.same(x,...)   return x end

-- .___ .      
-- [__ *| _  __
-- |   ||(/,_) 
function lib.csv(file,   x)
  file = io.input(file)
  return function(   t,tmp)
    x  = io.read()
    if x then
      t={}
      for y in x:gsub("[\t ]*",""):gmatch"([^,]+)" do t[1+#t]=tonumber(y) or y end
      if #t>0 then return t end 
    else io.close(file) end end end

-- .__     ,          
-- [__) _ -+-. .._.._ 
-- |  \(/, | (_|[  [ )
return lib
