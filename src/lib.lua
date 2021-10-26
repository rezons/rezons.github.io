local function obj(is,  o) 
  o={_is=is,__tostring=out}; o.__index=o; return o end

local function atom(s,b4) 
  return (b4==false and true) or tonumber(s) or s end

local function flag(it,b4) 
  for n,s in ipairs(arg) do 
    if s==it then return atom(arg[n+1],b4) end end end

--  Short-cuts
local ee   = math.exp(1)
local abs  = math.abs
local log  = math.log
local cat  = table.concat
local fmt  = string.format
local push = table.insert
local sort = function(t,f) table.sort(t,f); return t end
local isa  = function(mt,t) return setmetatable(t, mt) end

--  Lists
local function map(t,f,  u) 
  u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 

local function keys(t,   k) 
  k={}; for x,_ in pairs(t) do 
    if tostring(x):sub(1,1)~="_" then push(k,x) end end 
  return sort(k) end

local function kopy(obj,seen,    s,out)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj]   then return seen[obj] end
  s,out = seen or {},{}
  s[obj] = out
  for k, v in pairs(obj) do out[kopy(k, s)] = kopy(v, s) end
  return setmetatable(out, getmetatable(obj)) end

--  Printing
local function shout(t) print(out(t)) end

local function out(t,    u,f1,f2)
  function f1(_,x) return fmt(":%s %s",x,out(t[x])) end
  function f2(_,x) return out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u=#t==0 and map(keys(t),f1) or map(t,f2)
  return (t._is or"").."{"..cat(u,", ").."}" end

--  Files
local function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if   tmp 
    then t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
         for y in string.gmatch(tmp, "([^,]+)") do push(t,y) end
         tmp = io.read()
         if  #t > 0
         then for j,x in pairs(t) do t[j] = atom(x) end
              return t end
    else io.close(stream) end end end

return {
  obj=obj,atom=atom, flag=flag,
  ee=ee,abs=abs,log=log,cat=cat,fmt=fmt,push=push,isa=isa,sort=sort,
  keys=keys,map=map,kopy=kopy,out=out,shout=shout,csv=csv}
