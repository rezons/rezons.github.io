local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local EG, EGS, NUM, SYM
local add, coerce, col, copy, csv, dist, fmt, klass, map, new
local o, push, rand, randi, rnd, rnds, same, slots, sort, the

the = {p=2, some=512, seed=10019, far=.9, round=2, 
       file="../../data/auto93.csv"}

local function klass(s, it)
  it = {_is=s, __tostring=o} 
  it.__index = it
  return setmetatable(it,{__call=function(_,...) return it.new(...) end}) end

EG,EGS,NUM,SYM = klass"EG", klass"EGS", klass"NUM", klass"SYM"

-------------------------------------------------------------------------------
function NUM.new(n,s)  
  return col(n,s, new(NUM,{mu=0, m2=0, lo=math.huge, hi=-math.huge})) end

function NUM.add(i,x,  d)  
  d    = x    - i.mu
  i.mu = i.mu + d/i.n
  i.m2 = i.m2 + d*(x-i.mu) 
  i.lo = math.min(i.lo,x); i.hi = math.max(i.hi,x) end

function NUM.dist(i,x,y)
  if     x=="?" then y= i:norm(y); x=y>.5 and 0 or 1
  elseif y=="?" then x= i:norm(x); y=x>.5 and 0 or 1
  else   x,y = i:norm(x), i:norm(y) end
  return math.abs(x-y) end

function NUM.div(i) return i.n<2 and 0 or (i.m2/(i.n-1))^0.5 end 

function NUM.mid(i) return i.mu end

function NUM.norm(i,x) return i.hi-i.lo<1E-9 and 0 or (x-i.lo)/(i.hi-i.lo) end

-------------------------------------------------------------------------------
function SYM.new(n,s) return col(n,s, new(SYM,{has={},most=0,mode=nil})) end

function SYM.add(i,x,n)   
  n = n or 1
  i.has[x] = n + (i.has[x] or 0)
  if i.has[x] > i.most then i.most,i.mode = i.has[x], x end end

function SYM.dist(i,x,y) return x==y and 0 or 1 end

function SYM.div(i,   e)  
  e=0; for _,n in pairs(i.has) do e=e-n/i.n*math.log(n/i.n,2) end; return e end

function SYM.mid(i) return i.mode end

--------------------------------------------------------------------------------
function EG.new(t) return new(EG, {cooked={}, has=t}) end

function EG.better(eg1,eg2,egs)
  local s1,s2,e,n,a,b = 0,0,10,#egs.cols.y
  for _,c in pairs(egs.cols.y) do
    a  = c:norm(eg1.has[c.at])
    b  = c:norm(eg2.has[c.at])
    s1 = s1 - e^(c.w * (a-b)/n) 
    s2 = s2 - e^(c.w * (b-a)/n) end 
  return s1/n < s2/n end 

function EG.cols(i,cols) return map(cols,function(x) return i.has[x.at] end) end

function EG.dist(i,j,egs,    d)
  d = 0
  for _,c in pairs(egs.cols.x) do 
    d = d + dist(i.has[c.at], j.has[c.at], c)^the.p end 
  return (d/(1E-31 + #egs.cols.x))^(1/the.p) end

--------------------------------------------------------------------------------
function EGS.new(i) return new(EGS, {rows={}, cols={all={},x={},y={}}}) end

function EGS.add(i,eg,    now,here)
  eg = eg.has and eg.has or eg -- If data is buried inside, the expose it.
  if #i.cols.all>0 then               
    push(i.rows, EG(map(i.cols.all, function(c) return add(eg[c.at],c) end)))
  else
    for at,s in pairs(eg) do    -- First row. Create the right columns
      now = col(at,s, (s:find"^[A-Z]" and NUM or SYM)())
      push(i.cols.all, now)
      if not s:find":" then  
        here = (s:find"-" or s:find"+") and i.cols.y or i.cols.x
        push(here, now) end end end end  

function EGS.clone(i,inits,    j)
  j = EGS()
  j:add(map(i.cols.all, function(col) return col.txt end))
  for _,x in pairs(inits or {}) do  j:add(x) end
  return j end

function EGS.from(t, i) 
  i=i or EGS(); for _,eg in pairs(t) do i:add(eg) end; return i end

function EGS.read(c, i) 
  i=i or EGS(); for eg in csv(c) do i:add(eg) end; return i end

function EGS.far(i,eg1,    fun,tmp)
  fun = function(eg2) return {eg2, eg1:dist(eg2,i)} end
  tmp = #i.rows > the.some and any(i.egs, the.some) or i.egs
  tmp = sort(map(tmp, fun), function(a,b) return a[2] < b[2] end)
  return table.unpack(tmp[#tmp*the.far//1] ) end

function EGS.branch(i)
  local zero,one,two,ones,twos,both,a,b,c 
  zero  = any(i.egs)
  one   = i:far(zero) 
  two,c = i:far(one) 
  ones,twos,both = {},{},{} 
  for _,eg in pairs(i.egs) do
    a = eg:dist(one,i)
    b = eg:dist(two,i)
    push(both, {(a^2 + c^2 - b^2) / (2*c),eg}) end
  for n,pair in pairs(sort(both, function(a,b) return a[1] < b[1] end)) do
    push(n <= #both//2 and ones or twos, pair[2]) end
  return ones, twos end                              

function EGS.tree(i,top)
  top = top or i end

-------------------------------------------------------------------------------
function add(x,i) if x~="?" then i.n = i.n+1; i:add(x) end; return x end

function any(t,  n) 
  if not n then return t[randi(1,#t)] end 
  u={};for j=1,n do push(u,any(t)) end; return u end

function coerce(x)
  if x=="true" then return true elseif x=="false" then return false end
  return tonumber(x) or x end

function col(at,s,i)
  i.n, i.at, i.txt = 0, at or 0, s or ""
  i.w = i.txt:find"-" and -1 or 1
  return i end

function copy(t,u) 
  u={}; for k,v in pairs(t) do u[k]=v end
  return setmetatable(u, getmetatable(t)) end

function csv(file,   x,row)
  function row(x,  t)
    for y in x:gsub("%s+",""):gmatch"([^,]+)" do push(t,coerce(y)) end
    return t 
  end -----------------
  file = io.input(file) 
  return function() 
    x=io.read(); if x then return row(x,{}) else io.close(file) end end end

function dist(x,y,i) return x=="?" and y=="?" and 1 or i:dist(x,y) end

function fmt(...) return string.format(...) end

function map(t,f,  u) 
  u= {};for k,v in pairs(t) do push(u,(f or same)(v)) end; return u end

local _oid=0
function new(mt,x) 
  _oid=_oid+1; x._oid=_oid -- Everyone gets a unique id.
  return setmetatable(x,mt) end        -- Methods now delegate to `mt`.

function o(t)
  local u,key
  key= function(k) return fmt(":%s %s", k, o(t[k])) end
  if type(t) ~= "table" then return tostring(t) end
  u = #t>0 and map(t,o) or map(slots(t),key)
  return (t._is or "").."{"..table.concat(u, " ").."}" end 

function push(t,x) table.insert(t,x); return x end

function rand(lo,hi)
  the.seed = (16807 * the.seed) % 2147483647
  return (lo or 0) + ((hi or 1) - (lo or 0)) * the.seed / 2147483647 end

function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end

function rnd(x,d,  n) 
  if type(x)~="number" then return x end
  n=10^(d or the.round) 
  return math.floor(x*n+0.5)/n end

function rnds(t,d) return map(t,function(x) return rnd(x,d) end) end

function same(x,...) return x end

function slots(t,   u) 
  u={};for k,_ in pairs(t) do if tostring(k):sub(1,1) ~= "_" then push(u,k) end end
  return sort(u) end

function sort(t,f) table.sort(t,f);   return t end

-------------------------------------------------------------------------------
local go={}
function go.num(    m,n)
  m=NUM()
  for i=1,10 do add(i,m) end
  n = copy(m)
  for i=1,10 do add(i,n) end
  assert(2.95 == rnd(n:div()),"sd ok?") end

function go.egs(    egs)
  egs = EGS.read(the.file)
  assert(egs.cols.y[1].hi==5140,"most seen?") end

function go.clone(     egs1,egs2,s1,s2)
  egs1 = EGS.read(the.file)
  s1   = o(egs1.cols.y)
  egs2 = egs1:clone(egs1.rows) 
  s2   = o(egs2.cols.y) 
  assert(s1==s2, "cloning works?") end

function go.dist()
  local egs,eg1,dist,tmp,j1,j2,d1,d2,d3,one
  egs  = EGS.read(the.file)
  eg1  = egs.rows[1]
  dist = function(eg2) return {eg2,eg1:dist(eg2,egs)} end
  tmp  = sort(map(egs.rows, dist), function(a,b) return a[2] < b[2] end)
  one  = tmp[1][1]
  for j=1,30 do
    j1 = randi(1,#tmp)
    j2 = randi(1,#tmp)
    if j1>j2 then j1,j2=j2,j1 end
    d1 = tmp[j1][1]:dist(one,egs)
    d2 = tmp[j2][1]:dist(one,egs)
    assert(d1 <= d2,"distance ?") end end

go.num()
go.egs()
go.clone()
go.dist()
-------------------------------------------------------------------------------
for k,v in pairs(_ENV) do if not b4[k] then print("?rogues",k,type(v)) end end 
