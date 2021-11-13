local the = {
  what="guess",
  when= "(c) 2021, timm",
  how={
      {"misc", "todo", "-do","help", "start up action"},
      {"misc", "help", "-h", false,  "show help"},
      {"misc", "seed", "-S", 10019,  "randomnumber seed"},
      {"dist", "p",    "-p", 2,      "distance exponent"},
      {"dist", "some", "-s", 128,    "sample size for dist"}},
  b4= {}}

for k,v in pairs(_ENV) do the.b4[k]=v end

-------------------------------------------------------------------------------
-- ## lib.misc
local push,fmt
push = table.insert
fmt = string.fmt

-------------------------------------------------------------------------------
-- ## lib.list
local map,keys
function map(t,f,  u) u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 

function keys(t,  u) 
  u={};for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then push(u,k) end end
  return sort(u) end

-------------------------------------------------------------------------------
-- ## lib.print
local out,shout
function out(t,    u,f1,f2)
  function f1(_,x) return fmt(":%s %s",yellow(x),out(t[x])) end
  function f2(_,x) return out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u = #t==0 and map(keys(t),f1) or map(t,f2)
  return blue(t._is or"")..blue("{")..cat(u," ")..blue("}") end

function shout(x) print(out(x)) end

-------------------------------------------------------------------------------
-- ## lib.cli
local cli,help
function cli(old,a,    x)
  x={}
  for _,t in pairs(old) do
    x[t[2]] = t[4]
    for n,word in ipairs(a) do if word==t[3] then
      x[t[2]] = (t[4]==false) and true or tonumber(a[n+1]) or a[n+1] end end end 
  return x end

function  help(    show,b4)
  function show(_,x) 
    if x[1] ~= old then print("\n"..x[1]..":") end
    b4 = x[1]
    print(fmt("\t%4s %20s %s [%s]", x[3],x[4],x[5],x[1])) end
  print(the.what,"\n",the.how,"\n\nOPTIONS:")
  map(the.how,show) end

-------------------------------------------------------------------------------
-- ## lib.files
function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do push(t,y) end
      tmp = io.read()
      if  #t > 0 then return map(t, function(_,x) return tonumber(x) or x end) end
    else io.close(stream) end end end


-------------------------------------------------------------------------------
local Seed, randi, rand 
Seed=937162211
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 

-------------------------------------------------------------------------------
local Todo={}
Todo.help={"show help",help}

-------------------------------------------------------------------------------
the.how = cli(the.how,arg)
Seed=the.seed
Todo[the.todo][2]()
for k,v in pairs(_ENV) do if not the.b4[k] then print("? ",k,type(v)) end end

