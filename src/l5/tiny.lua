local b4={}; for k,v in pairs(_ENV) do b4[k]=k end
local function cli(flag,x)
  for n,word in ipairs(arg) do if word==flag then 
    x = x and (tonumber(arg[n+1]) or arg[n+1]) or true end end 
  return x end

local the= {BEST= cli("-b" , .5),
            TRAIN= cli("-t", .5),
            SEED= cli("-s",2000),
            FILE= cli("-f","../../data/auto93.csv")}

---------------------------------------
local same, push,sort, map,csv,norm
function same(x)    return x end
function push(t,x)  table.insert(t,x); return x end
function sort(t,f)  table.sort(t,f);   return t end
function map(t,f,u) u={}; for k,v in pairs(t) do push(u,f(k,v)) end; return u end
function norm(lo,hi,x) return math.abs(lo-hi)<1E-32 and 0 or (x-lo)/(hi-lo) end

function csv(file,   x)
  file = io.input(file)
  x    = io.read()
  return function(   t,tmp)
    if x then
      t={}
      for y in x:gsub("[\t ]*",""):gmatch"([^,]+)" do push(t,tonumber(y) or y) end
      x = io.read()
      if #t>0 then return t end 
    else io.close(file) end end end

local shout,out
function shout(x) print(out(x)) end
function out(t,    u,key,keys,value)
  function keys(t,u)
    u={}; for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then push(u,k) end end
    return sort(u) end
  function key(_,k)   return string.format(":%s %s", k, out(t[k])) end
  function value(_,v) return out(v) end
  if type(t) ~= "table" then return tostring(t) end
  u = #t>0 and map(t, value) or map(keys(t), key) 
  return "{"..table.concat(u," ").."}" end 

--------------------------
local slurp,sample,ordered
function slurp(out)
  for eg in csv(the.FILE) do out=sample(eg,out) end
  return out end

function sample(eg,i)
  local numeric, independent,dependent,head,datum
  i = i or {n=0,xs={},nys=0,ys={},lo={},hi={},w={},egs={},heads={}} 
  function head(n,x)
    function numeric()     i.lo[n]= math.huge; i.hi[n]= -i.lo[n] end 
    function independent() i.xs[n]= x end
    function dependent()
      i.w[n] = x:find"-" and -1 or 1
      i.ys[n]= x
      i.nys  = i.nys+1 end
    if not x:find":" then
      if x:match"^[A-Z]"        then numeric() end 
      ((x:find"-" or x:find"+") and dependent or independent)() end
    return x end
  function datum(n,x)
    if x ~= "?" then
      if i.lo[n] then 
        i.lo[n]= math.min(i.lo[n],x)
        i.hi[n]= math.max(i.hi[n],x) end end
    return x end
  if #i.heads==0 then i.heads=map(eg,head) else push(i.egs, map(eg,datum)) end 
  i.n = i.n + 1
  return i end

function ordered(i)
  local function better(eg1,eg2,     e,n,a,b,s1,s2)
    s1,s2,e = 0, 0, 2.71828
    for n,_ in pairs(i.ys) do
      a  = norm(i.lo[n], i.hi[n], eg1[n])
      b  = norm(i.lo[n], i.hi[n], eg2[n])
      s1 = s1 - e^(i.w[n] * (a-b)/i.nys) 
      s2 = s2 - e^(i.w[n] * (b-a)/i.nys) end
    return s1/i.nys < s2/i.nys end 
  i.egs = sort(i.egs, better)
  return i end

local s= slurp()
for i =1,20 do shout(s.egs[i]) end
print("")
for i =#s.egs,#s.egs-20,-1 do shout(s.egs[i]) end

for k,v in pairs(_ENV) do if not b4[k] then print("?rogue: ",k,type(v)) end end 
