local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end 
local atom,csv,inc,isa, map,o,obj,NB
local help=[[

./duo [OPTIONS]
Data miners using/used by optimizers.
Understands "N" items by peeking at at few (maybe zero) items.
(c) 2022, Tim Menzies, opensource.org/licenses/MIT

OPTIONS
  -ample  max items in a 'SAMPLE'       : 512
  -bins   max number of bins            : 16
  -Debug  one crash, show stackdump     : true
  -h      show help                     : false
  -p      coefficient on distance calcs : 2
  -round  print to 'round' decimals     : 2
  -seed   random number seed            : 10019
  -Some   max number items to explore   : 512
  -Tiny   bin size = #t^'Tiny'          : .5
  -todo   start up action ('all'=every) : -]]
 
-- oo stuff
function as(mt,t) return setmetatable(t,mt) end
function klass(s,  t) 
  t= {_is=s, __tostring=o, __index=t} 
  return as({__call=function(_,...) return t.new(...) end},t) end

-- list stuff
function sort(t,f) table.sort(t,f); return t end
function push(t,x) table.insert(t,x); return x end
function inc(d,k)  d[k]= 1+(d[k] or 0); return k end
function map(t,f)  local u={};for k,v in pairs(t) do u[#u+1]=f(v) end; return u; end

-- display stuff
fmt = string.format
function slots(t) u={}; for k,_ in pairs(t) do u[1+#u]=k end; return sort(u) end
function o(t,     show)
  function show(k) return fmt(":%s %s", k, t[k]) end
  t= #t>0 and map(t,tostring) or map(slots(t),show)
  return (t._is or "").."{"..table.concat(t,", ").."}" end
function rnd(x,d,  n) 
  n=10^(d or the.round)
  return type(x)~="number" and x or math.floor(x*n+0.5)/n end

-- os stuff
function atom(x)   
  if x=="true" then return true elseif x=="false" then return false end
  return tonumber(x) or x end
function csv(file)
  file = io.input(file) 
  return function(    t) 
    x=io.read(); 
    if x then 
      t={}; for y in x:gsub("%s+",""):gmatch"([^,]+)" do t[1+#t]=atom(y) end
      return #t>0 and t 
    else io.close(file) end end end 

-- settings stuff
function settings(help,       t)
  t = {}
  help:gsub("\n  [-]([^%s]+)[^\n]*%s([^%s]+)", function(flag, x)
    for n,txt in ipairs(arg) do             
      if   txt:sub(1,1)=="-" and flag:match("^"..txt:sub(2)..".*") 
      then x = x=="false" and"true" or x=="true" and"false" or arg[n+1] end end 
    t[flag] = atom(x) end)
  return t end

-- random stuff
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi)
  the.seed = (16807 * the.seed) % 2147483647
  return (lo or 0) + ((hi or 1) - (lo or 0)) * the.seed / 2147483647 end

-- math stuff
function xpects(t,       sum,n)
  sum,n = 0,0
  for _,one in pairs(t) do n= n + one.n; sum= sum + one.n*one:div() end
  return sum/n end

-- error stuff
errors=0
function asserts(test,msg) 
  msg=msg or ""
  if test then return print("  PASS : "..msg) end
  our.fails = our.fails+1                       
  print("  FAIL : "..msg)
  if your.Debug then assert(test,msg) end end

function rogues()
  for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end end
  
List=klass""
function List.new() return as(LIST,{}) end

-- ----------------------------------------------------------------------------
-- 
function Range.new(col,lo,hi,has) 
  lo = lo or -math.huge
  return new(Range, {n=0,score=nil,col=col, lo=lo, hi=hi or lo, has=has or Sym()}) end

function Range.__tostring(i) 
  if i.lo == i.hi       then return fmt("%s == %s",i.col.txt,i.lo) end
  if i.lo == -math.huge then return fmt("%s < %s",i.col.txt,i.hi) end
  if i.ho ==  math.huge then return fmt("%s >= %s",i.col.txt,i.lo) end
  return fmt("%s <= %s < %s", i.col.txt, i.lo, i.hi) end

function Range.add(i,x,y) 
  i.n = n.n+1
  i.hi = math.max(x,i.hi)
  i.lo = math.min(x,i.lo)
  i.has:add(y) end

function Range.div(i) return i.has:div() end

function Range.select(i,eg,       x)
  x = eg.has[i.col.at]
  return x=="?" or i.lo <= x and x < i.hi end

function Range.merge(i,j,      k)
 k = Range(i.col, i.lo, j.hi, i.has:merged(j.has))
 k.n = i.n + j.n
 if k.has:div()*1.01 <= xpects{i, j} then return k end end

function Range.eval(i,goal)
    local best, rest, goals = 0,0,{}
  if not i.score then
    function goals.smile(b,r) return r>b and 0 or b*b/(b+r +1E-31) end
    function goals.frown(b,r) return b<r and 0 or r*r/(b+r +1E-31) end
    function goals.xplor(b,r) return 1/(b+r                +1E-31) end
    function goals.doubt(b,r) return 1/(math.abs(b-r)      +1E-31) end
    for x,n in pairs(i.has) do
      if x==goal then best = best+n/i.n else rest = rest+n/i.n end end
    i.score = best + rest < 0.01 and 0 or goals[your.goal](best,rest) end
  return i.score end


Num=klass"Num"
function Num.new(n,s) 
  return as(Num,{at=n or 0, txt=s or "", n=0, has={}, ready=false,
                 w=(s or ""):find"-" and -1 or 1}) end
  
function Num.add(i,x,     pos)
  if x ~="?" then
    i.n= i.n + 1
    if     #i.has < the.ample  then pos= #i.has + 1 
    elseif rand() < #i.has/i.n then pos= #i.has * rand() end
    if pos then i.ready=false; i.has[pos//1]= x end end 
  return x end

function Num.merge(i,j,         k)
  k = Num(i.at, i.txt)
  for _,x in pairs(i.has) do k:add(x) end
  for _,x in pairs(j.has) do k:add(x) end
  return k end

-- dist stuff
function Num.norm(i,x,    a) 
  a=i:all(); return  (a[#a]-a[1]) < 1E-9 and 0 or (x-a[1])/(a[#a] - a[1]) end
function Num.dist(i,x,y)
  if     x=="?" and y=="?" then return 1
  elseif x=="?"            then y= i:norm(y); x=y>.5 and 0 or 1
  elseif y=="?"            then x= i:norm(x); y=x>.5 and 0 or 1
  else   x,y = i:norm(x), i:norm(y) end
  return math.abs(x-y) end
   
-- queries
function Num.lo(i) i:all(); return i.has[1] end
function Num.hi(i) i:all(); return i.has[#i.has] end
function Num.mid(i) return i:per(.5) end
function Num.div(i) return (i:per(.9) - i:per(.1))/2.56 end
function Num.per(i,p,   a) a=i:all(); return a[math.min(#a, 1+p*#a //1 )] end
function Num.all(i)
  if not i.ready then table.sort(i.has); i.ready=true end; return i.has end

-- ranges
function Num.ranges(i,j, yklass)
  local xys, dull, tiny, range,out
  yklass = yklass or Sym
  lo = math.min(i:lo(),j:lo())
  hi = math.max(i:hi(),j:hi())
  b=(x-lo)/(hi-lo)*the.bins // 1

  for _,x in pairs(i._has.all) do push(xys, {x=x, y="best"}) end
  for _,x in pairs(j,_has.all) do push(xys, {x=x, y="rest"}) end
  xys    = sort(xys, function(a,b) return a.x < b.x end)
  dull   = xpects{i,j}*your.dull
  tiny   = (#xys)^your.Tiny 
  range  = Range(i,xys[1].x, xys[1].x, yklass())
  out = {range}
  for k,xy in pairs(xys) do
    if   k < #xys - tiny    and xy.x ~= xys[k+1].x and 
         range.has.n > tiny and range.hi - range.lo > dull
    then range = push(out, Range(i, range.hi, xy.x, yklass())) 
    end
    range:add(xy.x, xy.y) end
  out[1].lo       = -math.huge
  out[#ranges].hi =  math.huge
  return out end
 
NB=klass"NB"
function NB.new() return as(NB, {k=1,m=2,names=LIST(),n, hs=0,h={}, f={}}) end

i=NB()
i.names[23]=34
print(i)
function NB.read(i, file) 
  for row in csv(file) do if row then i:add(n,row) end end end

function NB.add(i, n,row,          k,klass)
  if n==0 then i.names=row else
    k=#row
    if n > 5 then print(row[k], i:classify(row)) end
    klass=row[k]
    if not i.h[klass] then i.hs=i.hs+1; i.h[klass]=0 end
    inc(i.h,row[k])
    i.n=i.n+1
    for col,x in pairs(row) do
      if col~=k and x~="?" then
        inc(i.f, {col,x,klass}) end end end  end

function NB.classify(i,row,      best)
  best=-1
  for klass,nh in pairs(i.h) do
    local prior = (nh+i.k)/(i.n + i.k*i.hs)
    local tmp   = prior
    for col,x in pairs(row) do
      if col ~= #row and x~="?" then
        tmp = tmp * ((i.f[{col,x,klass}] or 0) +i.m*prior)/(nh+i.m) end end
    if tmp > best then best,out=tmp,klass end end
  return klass end

local i=NB.new()
--i:read("../../data/weathernom.csv")
--print(o(i.h))

-- start up stuff
the=settings(help)
if the.h then print(help) end 
errors=0

-- finish stuff
rogues()
os.exits(errors)
