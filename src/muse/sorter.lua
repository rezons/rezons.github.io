local push,sort,map,fmt,slots,o,new,klass,csv
function push(t,x)   table.insert(t,x); return x end
function sort(t,f)   table.sort(t,f); return t end
function map(t,f, u) u={};for _,v in pairs(t) do push(u, f(v)) end; return u end

fmt=string.format
function slots(t,  u) u={};for k,_ in pairs(t) do push(u,k)end; return u end
function o(t,  u)
  u={}; for _,k in pairs(sort(slots(t))) do push(u,fmt(":%s %s",k,t[k])) end 
  return (t._is or "").."{"..table.concat(u," ").."}" end

function new(mt,t)   return setmetatable(t,mt) end
function klass(s, t) 
  t = {_is=s, __tostring=o}; t.__index = t
  return setmetatable(t,{__call=function(_,...) return t.new(...) end}) end

function csv(file)
  file = io.input(file) 
  return function(    t) 
    x=io.read(); 
    if x then 
      t={}
      for y in x:gsub("%s+",""):gmatch"([^,]+)" do push(t,tonumber(y) or y) end
      return #t>0 and t 
    else io.close(file) end end end 

NUM=klass"NUM"
function SYM.new(at,s) return new(SYM,{at=at,s=s}) end
