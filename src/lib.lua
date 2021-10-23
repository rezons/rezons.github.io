local Eg,lib={},{}

-- ## Classes
-- Columns of data either `Num`eric, `Sym`bolic, or things we are going to `Skip` over.
-- `Sample`s hold rows of data, summarized into `Cols` (columns).
function lib.obj(is,   k) 
  k={_is=is,__tostring=function(x) return out(x) end}; k.__index=k; return k end

-- -------------------------------------------------------------
-- ## Lib
-- ### The Usual Short-cuts
lib.cat  = table.concat
lib.fmt  = string.format
lib.push = table.insert
lib.sort = function(t,f) table.sort(t,f); return t end

function lib.map(t,f,      u) 
  u={};for k,v in pairs(t) do u[k]=f(k,v) end; return u end

function lib.keys(t,   ks)
  ks={}; for k,_ in pairs(t) do ks[1+#ks]=k end; return sort(ks) end

function lib.isa(mt,t) return setmetatable(t, mt) end

-- ### Rand
function lib.randi(lo,hi) return math.floor(0.5 + lib.rand(lo,hi)) end
function lib.rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 


-- ### Printing
-- colored strings
function lib.red(s)    return "\27[1m\27[31m"..s.."\27[0m" end
function lib.green(s)  return "\27[1m\27[32m"..s.."\27[0m" end
function lib.yellow(s) return "\27[1m\27[33m"..s.."\27[0m" end
function lib.blue(s)   return "\27[1m\27[36m"..s.."\27[0m" end

-- Print a generated string
function lib.shout(x) print(lib.out(x)) end
-- Generate a string, showing sorted keys, hiding secretes (keys starting with "_")

function lib.out(t,         u,secret,brace,out1,show)
  function secret(s) return tostring(s):sub(1,1)== "_" end
  function brace(t)  return "{"..lib.cat(t,", ").."}" end
  function out1(_,v) return lib.out(v) end
  function show(_,v) return lib.fmt(":%s %s", lib.blue(v[1]), lib.out(v[2])) end
  if     type(t)=="function" then return "#`()"
  elseif type(t)~="table"    then return tostring(t) 
  elseif #t>0                then return brace(lib.map(t, lib.out1),", ") 
  else   u={}
         for k,v in pairs(t) do if not secret(k) then u[1+#u] = {k,v} end end
         return lib.yellow(t._is or "")..brace(lib.map(lib.sort(u,first), show)) end end



-- -------------------------------------------------------------
-- ### Start-up
function lib.cli(   u)
  u={}
  for _,t in pairs(about()) do
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do if word==t[2] then
      u[t[1]] = (t[3]==false) and true or tonumber(arg[n+1]) or arg[n+1] end end end 
  return u end 

function lib.help(s)
  print(s.." [OPTIONS]\n\nOPTIONS:\n"); 
  for _,t in pairs(about()) do
    print(lib.fmt("  %-4s%s %s",t[2],lib.fmt("%-10s",t[3]==false and "" or t[3]),t[4])) end 
  print("\nSTART-UP ACTIONS:\n"); lib.go("ls") end

-- -------------------------------------------------------------
-- ### Unit tests
local fails = {}, -1
function lib.go(x,     ok,msg) 
  the = cli()
  Seed = the.seed 
  if the.wild then return Eg[x][2]() end
  ok, msg = pcall(Eg[x][2])
  if   ok 
  then print(lib.green("PASS: "),x) 
  else print(lib.red("FAIL: "),x,msg); fails=fails+1 end end

-- ## Examples
Eg.ls={"list all examples", function () 
  lib.map(lib.keys(Eg), function (_,k) 
    print(fmt("  -t  %-10s ",k)..Eg[k][1]) end) end}

Eg.all={"run all examples", function() 
  lib.map(lib.keys(Eg),function(_,k) 
                 return k ~= "all" and k ~= "ls" and lib.go(k) end) end}

Eg.fail={"demo failure", function () assert(false,"oops") end}

return Eg,lib
