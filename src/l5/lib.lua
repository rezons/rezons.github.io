local lib={}

-- ROGUES ----------------------------------------------------------------------
-- 
-- Call `rogues`, last thing, to find escaped locals.
lib._b4={}; for k,v in pairs(_ENV) do lib._b4[k]=k end
function lib.rogues()
  for k,v in pairs(_ENV) do 
    if not lib._b4[k] then print("?rogue: ",k,type(v)) end end end

-- OBJECTS ---------------------------------------------------------------------
--
-- Create an instance
function lib.has(mt,x) return setmetatable(x,mt) end
-- Create a clss
function lib.obj(s, o,new)
   o = {_is=s, __tostring=lib.out}
   o.__index = o
   return setmetatable(o,{__call = function(_,...) return o.new(...) end}) end

-- RANDOM ----------------------------------------------------------------------
-- 
lib.Seed = 10019
-- random integers
function lib.randi(lo,hi) return math.floor(0.5 + lib.rand(lo,hi)) end
-- random floats
function lib.rand(lo,hi,     mult,mod) 
  lo, hi = lo or 0, hi or 1
  lib.Seed = (16807 * lib.Seed) % 2147483647
  return lo + (hi-lo) * lib.Seed / 2147483647 end

-- MATHS -----------------------------------------------------------------------
-- 
lib.abs = math.abs
-- Round `x` to `d` decimal places.
function lib.rnd(x,d,  n) n=10^(d or 0); return math.floor(x*n+0.5) / n end
-- Round list of items to  `d` decimal places.
function lib.rnds(t,d) 
  return lib.lap(t, function(x) return lib.rnd(x,d or 2) end) end

-- Sum items, filtered through `f`.
function lib.sum(t,f,     out)
  f= f or function(x) return x end
  out=0; for _,x in pairs(t) do out = out + f(x) end; return out end

-- FILES -----------------------------------------------------------------------
--
-- Return one table per line, split on commas.
function lib.csv(file,   line)
  file = io.input(file)
  line = io.read()
  return function(   t,tmp)
    if line then
      t={}
      for cell in line:gsub("[\t\r ]*",""):gsub("#.*",""):gmatch("([^,]+)") do
        lib.push(t, tonumber(cell) or cell) end 
      line = io.read()
      if #t>0 then return t end 
    else io.close(file) end end end

-- PRINTING --------------------------------------------------------------------
-- 
lib.fmt = string.format
lib.say = function(...) print(lib.fmt(...)) end

-- Print as red, green, yellow, blue.
function lib.color(s,n) return lib.fmt("\27[1m\27[%sm%s\27[0m",n,s) end
function lib.red(s)     return lib.color(s,31) end
function lib.green(s)   return lib.color(s,32) end
function lib.yellow(s)  return lib.color(s,34) end
function lib.blue(s)    return lib.color(s,36) end

-- Printed string from a nested structure.
lib.shout = function(x) print(lib.out(x)) end
-- Generate string from a nested structures
-- (and don't print any contents more than once).
function lib.out(t,seen,    u,key,value,public)
  function key(k) return lib.fmt(":%s %s", lib.blue(k), lib.out(t[k],seen)) end
  function value(v) return lib.out(v,seen) end
  if type(t) == "function" then return "(...)" end
  if type(t) ~= "table"    then return tostring(t) end
  seen = seen or {}
  if seen[t] then return "..." else seen[t] = t end
  u = #t>0 and lib.lap(t, value) or lib.lap(lib.keys(t), key) 
  return lib.red((t._is or"").."{")..lib.cat(u," ")..lib.red("}") end 

-- TABLE -----------------------------------------------------------------------
--
-- Table to string.
lib.cat     = table.concat 
-- Return a sorted table.
lib.sort    = function(t,f) table.sort(t,f); return t end
-- Return first,second, last  item.
lib.first   = function(t) return t[1] end
lib.second  = function(t) return t[2] end
lib.last    = function(t) return t[#t] end
-- Function for sorting pairs of items.
lib.firsts  = function(a,b) return a[1] < b[1] end
-- Add to end, pull from end.
lib.pop     = table.remove
lib.push    = function(t,x) table.insert(t,x); return x end

-- Random order of items in a list (sort in place).
function lib.shuffle(t,   j)
  for i=#t,2,-1 do j=lib.randi(1,i); t[i],t[j]=t[j],t[i] end; return t end

-- Collect values, passed through 'f'.
function lib.lap(t,f)  return lib.map(t,f,1) end
-- Collect key,values, passed through 'f'.    
-- If `f` returns two values, store as key,value.     
-- If `f` returns one values, store at index value.
-- If `f' return nil then add nothing (so `map` is also `select`).
function lib.map(t,f,one,     u) 
  u={}; for x,y in pairs(t) do 
    if one then x,y=f(y) else x,y=f(x,y) end
    if x ~= nil then
      if y then u[x]=y else u[1+#u]=x end end end 
  return u end

-- Shallow copy
function lib.copy(t,  u) u={}; for k,v in pairs(t) do u[k]=v end; return u end

function lib.top(t,n,      u)
  u={};for k,v in pairs(t) do if k>n then break end; push(u,v) end; return u;end

--- Return a table's keys (sorted).
function lib.keys(t,u)
  u={}
  for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then lib.push(u,k) end end
  return lib.sort(u) end

-- Binary chop (assumes sorted lists)
function lib.bchop(t,val,lt,lo,hi,     mid)
  lt = lt or function(x,y) return x < y end
  lo,hi = lo or 1, hi or #t
  while lo <= hi do
    mid =(lo+hi) // 2
    if lt(t[mid],val) then lo=mid+1 else hi= mid-1 end end
  return math.min(lo,#t)  end

-------------------------------------------------------------------------------`
return lib
