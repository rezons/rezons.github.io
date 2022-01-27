function lib.any(t) return t[math.random(#t)] end 

function lib.bsearch(t,x,     lo,hi,        mid) 
  lo,hi = lo or 1,hi or #t
  while lo <= hi do
    io.write(".")
    mid = (lo + hi)//2
    if t[mid] >= x then hi= mid - 1 else lo= mid + 1 end end
  return lo>#t and #t or lo end

function lib.firsts(a,b)  return a[1] < b[1] end

fmt = string.format

function lib.many(t,n, u) u={};for j=1,n do t[1+#t]=lib.any(t) end; return u end

function lib.map(t,f,       p,u)
  f,u = f or lib.same, {}
  p = debug.getinfo(f).nparams -- only available in  LUA 5.2+
  f= function(k,v) if p==2 then return f(k,v) else return f(v) end end
  for k,v in pairs(t) do lib.push(u, f(k,v)) end; return u end

function lib.new(k,t) k.__index=k; return setmetatable(t,k) end

function lib.o(t,   u)
  if type(t)~="table" then return tostring(t) end
  local key=function(k) return string.format(":%s %s",k,lib.o(t[k])) end
  u = #t>0 and map(t,lib.o) or lib.map(lib.sort(lib.slots(t)),key) 
  return '{'..table.concat(u," ").."}" end 

function lib.push(t,x) table.insert(t,x); return x end

function lib.rows(file,      x)
  file = io.input(file)
  return function() 
    x=io.read(); if x then return lib.things(x) else io.close(file) end end end

function lib.same(x) return x end

function lib.seconds(a,b) return a[2] < b[2] end

function slots(t, u) 
  u={}
  for k,_ in pairs(t) do k=tostring(k); if k:sub(1,1)~="_" then u[1+#u]=k end end
  return u end 

function lib.sort(t,f)   table.sort(t,f); return t end

function lib.thing(x)   
  x = x:match"^%s*(.-)%s*$" 
  if x=="true" then return true elseif x=="false" then return false end
  return tonumber(x) or x end

function lib.things(x,sep,  t)
  t={}
  for y in x:gmatch(sep or"([^,]+)") do lib.push(lib.thing(y)) end
  return t end


return lib

