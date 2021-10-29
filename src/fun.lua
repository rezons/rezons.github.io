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
local l={}

--  Short-cuts
l.ee   = math.exp(1)
l.abs  = math.abs
l.log  = math.log
l.cat  = table.concat
l.fmt  = string.format
l.push = table.insert
l.sort = function(t,f) table.sort(t,f); return t end

-- Objects
-- Make class.
function l.obj(is,  o) o={_is=is,__tostring=l.out}; o.__index=o; return o end
-- Make instance.
function l.isa(mt,t) return setmetatable(t, mt) end

-- Handling command-line args
function l.atom(s,b4) return (b4==false and true) or tonumber(s) or s end

function l.cli(fours,   u)
  u={}
  for _,t in pairs(fours) do
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do 
      if word==t[2] then u[t[1]] = l.atom(arg[n+1],t[3]) end end end
  return u end 

function l.help(usage,fours,     one)
  function one(_,t) 
    print(l.fmt("  %-3s %-34s%s",
                t[2],l.blue(t[3]==false and "" or t[3]),t[4])) end 
  print(l.gray(usage).." [OPTIONS]\n\n"..l.gray("OPTIONS:")) 
  l.map(fours,one) end

--  List tricks
function l.map(t,f,  u) 
  u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 

function l.keys(t,   k) 
  k={}; for x,_ in pairs(t) do 
    if tostring(x):sub(1,1)~="_" then l.push(k,x) end end 
  return l.sort(k) end

function l.kopy(obj,seen,    s,out)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj]   then return seen[obj] end
  s,out = seen or {},{}
  s[obj] = out
  for k, v in pairs(obj) do out[l.kopy(k, s)] = l.kopy(v, s) end
  return setmetatable(out, getmetatable(obj)) end

function l.any(t) return t[randi(1,#t)] end

function l.shuffle(t,n,    j)
  for i = #t,2,-1 do j=randi(1,i); t[i],t[j] = t[j],t[i] end
  return n end

-- Maths
l.Seed=937162211
function l.randi(lo,hi) return math.floor(0.5 + l.rand(lo,hi)) end

function l.rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  l.Seed = (16807 * l.Seed) % 2147483647 
  return lo + (hi-lo) * l.Seed / 2147483647 end 

--  Printing
function l.shout(t) print(l.out(t)) end

function l.out(t,    u,f1,f2)
  function f1(_,x) return l.fmt(":%s %s",l.blue(x),l.out(t[x])) end
  function f2(_,x) return l.out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u=#t==0 and l.map(l.keys(t),f1) or l.map(t,f2)
  return l.yellow(t._is or"").."{"..l.cat(u,", ").."}" end

function l.gray(s)   return "\27[1m\27[30m"..s.."\27[0m" end
function l.red(s)    return "\27[1m\27[31m"..s.."\27[0m" end
function l.green(s)  return "\27[1m\27[32m"..s.."\27[0m" end
function l.yellow(s) return "\27[1m\27[33m"..s.."\27[0m" end
function l.purple(s) return "\27[1m\27[34m"..s.."\27[0m" end
function l.pink(s)   return "\27[1m\27[35m"..s.."\27[0m" end
function l.blue(s)   return "\27[1m\27[36m"..s.."\27[0m" end

--  Files
function l.csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if   tmp 
    then t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
         for y in string.gmatch(tmp, "([^,]+)") do l.push(t,y) end
         tmp = io.read()
         if  #t > 0
         then for j,x in pairs(t) do t[j] = l.atom(x) end
              return t end
    else io.close(stream) end end end
-- Fin.
return l
