--    , ; ,   .-'"""'-.   , ; ,
--    \\|/  .'         '.  \|//
--     \-;-/  ()     ()  \-;-/
--     // ;               ; \\
--    //__; :.         .; ;__\\
--   `-----\'.'-.....-'.'/-----'
--          '.'.-.-,_.'.'
--    jgs     '(  (..-'
--              '-'      
-- ## Misc lua tricks       
-- (c) 2021 Tim Menzies (timm@ieee.org), WTFPL v2.0 (wtfpl.net)
local l={}

--  Short-cuts
l.ee   = math.exp(1)
l.abs  = math.abs
l.log  = math.log
l.cat  = table.concat
l.fmt  = string.format
l.push = table.insert
l.sort = function(t,f) table.sort(t,f); return t end
l.isa  = function(mt,t) return setmetatable(t, mt) end

-- Objects
function l.obj(is,  o) o={_is=is,__tostring=l.out}; o.__index=o; return o end

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
    print(l.fmt("  %-4s%-20s%s",t[2],t[3]==false and "" or t[3],t[4])) end 
  print(usage.." [OPTIONS]\n\nOPTIONS:") 
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
  function f1(_,x) return l.fmt(":%s %s",x,l.out(t[x])) end
  function f2(_,x) return l.out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u=#t==0 and l.map(l.keys(t),f1) or l.map(t,f2)
  return (t._is or"").."{"..l.cat(u,", ").."}" end

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
------------------------------------
return l
