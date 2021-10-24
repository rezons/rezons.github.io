local lib={}

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
  f = f or function(k,v) return v end
  u={}
  for k,v in pairs(t) do 
    local tmp = f(k,v)
    if tmp then u[k] = tmp end end 
  return u end

function lib.copy(t)         
  return type(t) ~= 'table' and t or lib.map(t, lib.copy) end

function lib.keys(t,   ks)
  ks={}; for k,_ in pairs(t) do ks[1+#ks]=k end; return lib.sort(ks) end

function lib.isa(mt,t) return setmetatable(t, mt) end

function lib.first(x,y) return x[1] < y[1] end

-- ### Rand
function lib.randi(lo,hi) return math.floor(0.5 + lib.rand(lo,hi)) end
function lib.rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  lib.Seed = (16807 * lib.Seed) % 2147483647 
  return lo + (hi-lo) * lib.Seed / 2147483647 end 

-- ### Files
function lib.csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if  #t > 0
      then for j,x in pairs(t) do t[j] = tonumber(x) or x end
           return t end
    else io.close(stream) end end end


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
         return lib.yellow(t._is or "")..brace(
                                           lib.map(
                                             lib.sort(u,lib.first), 
                                             show)) end end

-- -------------------------------------------------------------
-- ### Start-up
function lib.cli(listOfFours,   u)
  u={}
  for _,t in pairs(listOfFours) do
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do if word==t[2] then
      u[t[1]] = (t[3]==false) and true or tonumber(arg[n+1]) or arg[n+1] end end end 
  return u end 

function lib.help(usage,listOfFours)
  print(usage.." [OPTIONS]\n\nOPTIONS:\n"); 
  for _,t in pairs(listOfFours) do
    print(lib.fmt("  %-4s%s %s",t[2],lib.fmt("%-10s",t[3]==false and "" or t[3]),t[4])) end 
  print("\nSTART-UP ACTIONS:\n"); lib.go("ls") end

-- -------------------------------------------------------------
-- ### Unit tests
lib.Eg={}
lib.fails= -1

function lib.main(b4, usage, listOfFours,  the)
  the = lib.cli(listOfFours)
  if the.help then lib.help(usage, listOfFours) else lib.go(the.todo, the) end
  for k,v in pairs(_ENV) do if not b4[k] then 
    print("?? ",k,type(v)) end end 
  os.exit(lib.fails) end

function lib.go(x,the,     ok,msg) 
  lib.Seed = the.seed 
  if the.wild then return lib.Eg[x][2](the) end
  ok, msg = pcall(lib.Eg[x][2], the)
  if   ok 
  then print(lib.green("PASS: "),x) 
  else print(lib.red("FAIL: "),x,msg)
       lib.fails = lib.fails + 1 end end

-- ## Examples
lib.Eg.ls={"list all examples", function (_) 
  lib.map(lib.keys(lib.Eg), function (_,k) 
    print(lib.fmt("  -t  %-10s ",k)..lib.Eg[k][1]) end ) end}

lib.Eg.all={"run all examples", function(the) 
  lib.map(lib.keys(lib.Eg),
    function(_,k)  
      return k ~= "all" and k ~= "ls" and lib.go(k, lib.copy(the)) end) end}

return lib
