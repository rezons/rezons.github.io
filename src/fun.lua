-- ________________________     Q
-- |                      |  ___|\_.-,
-- | FUN= Misc LUA tricks S\ Q~\___ \|
-- | (c) 2021 Tim Menzies |(   )o 5) Q
-- | WTFPL v2.0           |\\  \_ ()
-- | wtfp.net             | \'. _'/'.
-- |                     .-. '-(  x< \
-- |         ,o         /\, '.  )  /'\\
-- |_________\'.__.----/ .'\  '.-'/   \\
--      snd   '---'q__/.'__ ;    /     \\_
--                 '---'     '--'       `"'
--  Short-cuts
local e   = math.exp(1)
abs  = math.abs
log  = math.log
cat  = table.concat
fmt  = string.format
push = table.insert
sort = function(t,f) table.sort(t,f); return t end

-- Objects
-- Make class.
function obj(is,  o) o={_is=is,__tostring=out}; o.__index=o; return o end
-- Make instance.
function isa(mt,t) return setmetatable(t, mt) end

-- Handling command-line args
function atom(s,b4) return (b4==false and true) or tonumber(s) or s end

function cli(fours,   u)
  u={}
  for _,t in pairs(fours) do
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do 
      if word==t[2] then u[t[1]] = atom(arg[n+1],t[3]) end end end
  return u end 

function help(usage,fours,     one)
  function one(_,t) 
    print(fmt("  %-3s %-34s%s",
                t[2],blue(t[3]==false and "" or t[3]),t[4])) end 
  print(gray(usage).." [OPTIONS]\n\n"..gray("OPTIONS:")) 
  map(fours,one) end

--  List tricks
function map(t,f,  u) 
  u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 

function keys(t,   k) 
  k={}; for x,_ in pairs(t) do 
    if tostring(x):sub(1,1)~="_" then push(k,x) end end 
  return sort(k) end

function kopy(obj,seen,    s,out)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj]   then return seen[obj] end
  s,out = seen or {},{}
  s[obj] = out
  for k, v in pairs(obj) do out[kopy(k, s)] = kopy(v, s) end
  return setmetatable(out, getmetatable(obj)) end

function any(t) return t[randi(1,#t)] end

function shuffle(t,n,    j)
  for i = #t,2,-1 do j=randi(1,i); t[i],t[j] = t[j],t[i] end
  return n end

function top(n,t,      u)
  n = math.min(n,#t)
  u={}; for m,x in pairs(t) do u[m]=x; if m>=n then break end end
  return u end

-- Maths
local Seed=937162211
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end

function rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 

--  Printing
function shout(t) print(out(t)) end

function out(t,    u,f1,f2)
  function f1(_,x) return fmt(":%s %s",blue(x),out(t[x])) end
  function f2(_,x) return out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u=#t==0 and map(keys(t),f1) or map(t,f2)
  return yellow(t._is or"").."{"..cat(u,", ").."}" end

local function _color(n,s) return fmt("\27[1m\27[%sm%s\27[0m",n,s) end
function gray(s)    return _color(30,s) end
function red(s)     return _color(31,s) end
function green(s)   return _color(32,s) end
function yellow(s)  return _color(33,s) end
function purple(s)  return _color(34,s) end
function pink(s)    return _color(35,s) end
function blue(s)    return _color(36,s) end

--  Files
function csv(file,      split,stream,tmp)
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
