local the       = require"the"
local obj,has   = the"metas obj has"
local shout     = the"prints shout"
local r,e,srand = the"maths r e srand"
local top,each,firsts,push,sort,per = the"tables top each firsts push sort per"
local round,sqrt,log,cos,pi,lt,gt,r = the"maths round sqrt log cos pi lt gt r"
local Best = require"best"

-------------------------------------------------------------------------------
local Num=obj"Num"
function Num.new(t, self) 
  t=t or {}
  self=has(Num,{lo=t.lo or 1E32, hi=t.hi or -1E32, at=t.at or 0,
                txt=t.txt or"", n=0, mu=0, m2=0, sd=0, new=true})
  self.w = self.txt:find"-" and -1 or 1
  return self:adds(t.inits or {}) end

function Num:z(x)    return (x - self.mu) / self.sd end
function Num:mid() return self.mu end
function Num:adds(t) for _,x in pairs(t) do self:add(x) end; return self end
function Num:any()   
  if   self.new 
  then return self.lo+r()*(self.hi - self.lo) 
  else return self.mu+self.sd*sqrt(-2*log(r()))*cos(2*pi*r()) end end 
function Num:norm(x)
  local lo, hi = self.lo, self.hi
  return abs(lo - hi) < 1E-31 and 0 or (x - lo) / (hi - lo) end
function Num:add(x)
  self.new = false
  local d = x - self.mu
  self.n  = self.n + 1
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x - self.mu)
  self.sd = ((self.m2<0 or self.n<2) and 0) or ((self.m2/(self.n-1))^0.5)
  self.lo = math.min(self.lo,x)
  self.hi = math.max(self.hi,x)
  return x end

-------------------------------------------------------------------------------
local Sym=obj"Syn"
function Sym.new(t,  self) 
  t=t or {}
  self=has(Sym,{at=t.at or 0,txt=t.txt or "",has={},most=0,mode=nil})
  return self:adds(t.inits or {}) end

function Sym:any(   k1)   
  local n = r(self.n)
  for k,v in pairs(self.has) do k1=k;n=n-v; if n<=0 then return k end end
  return k1 end
function Syn:mid() return self.mode end
function Sym:adds(t) for _,x in pairs(t) do self:add(x) end; return self end
function Sym:add(x,  inc)
  inc = inc or 1
  self.n = self.n + inc
  self.seen[x] = inc + (self.has[x] or 0)
  if self.has[x] > self.most then self.most,self.mode=self.has[x],x end 
  return x end

-------------------------------------------------------------------------------
local Cols=obj"Cols"
function Cols.new(lst)
  local all,xs,ys={},{},{}
  for k,v in pairs(lst) do
    local now = (k:match("^[A-Z]") and Num or Sym){txt=v,at=k}
    push(self.all, now)
    push((k:find"+" or k:find"-") and self.ys or self.xs, now) end 
  return has(Cols, {header=lst,all=all,xs=xs,ys=ys}) end

function Cols:clump() return Cols{self.header} end
function Cols:xany()  return map(self.xs, function(_,c) return c:any() end) end 

function Cols:better(row1,row2)
  local n,a,b,s1,s2,e
  s1, s2, n = 0, 0, #self.ys
  for _,col in pairs(self.ys) do
    a  = col:norm(row1[col.at]) --normalize to avoid
    b  = col:norm(row2[col.at])
    s1 = s1 - e^(col.w * (a - b) / n)
    s2 = s2 - e^(col.w * (b - a) / n) end
  return s1 / n < s2 / n end

function Cols:betters(rows)
  return sort(self.rows or rows, function(a,b) return self:better(a,b) end) end

function Cols:add(row)
  for _,col in pairs(self.all) do col:add(row[col.at]) end; return row end

function Cols:mid(cols)
  return map(cols or self.all,function(_,col) return col:mid() end) end

-------------------------------------------------------------------------------
local function zdt1(t)
  local f1,g,h,f2
  for i=1,(d or 10) do t[i]=r() end
  f1 = t[1]
  g  = 0; for i=2,#t do g = g + t[i] / (#t - 1) end
  g  = 1 + 9 * g
  h  = 1 - (f1 / g)^.5
  t[1+#t] = f1
  t[1+#t] = g*h
  return t end

local function rnd2(x) return round(x,2) end
local function rnd3(x) return round(x,3) end

local function suggestions(it)
  it.verbose= it.verbose or false
  it.m      = it.m      or 10
  it.n      = it.n      or 100
  it.top    = it.top    or .1
  it.better = it.better or lt
  it.before = it.before or Num{mu=0,sd=1}
  it.f      = it.f      or function(x) return x^2 end
  return it end

local function nCrossEntropy(it, best,good,one,xs1,xs,ys)
  it = suggestions(it)
  b4 = it.before
  function xy()    return it.f( b4:xany() ) end
  function ok(a,b) return b4:better(a,b) end 
  for i = 1,it.generations do
    now = Cols(it.names)
    for _,one in pairs(top(it.n*it.top, sort(ntimes(it.n, xy), ok))) do
      now:add(one) end
    if it.verbose then shout(new:mid(new.ys)) end
    b4 = now 
  end
  return now end

srand(the.seed)
local xs,ys = nCrossEntropy {
   generations = 5,
   n = 30,
   top = .2;
   verbose = true,
   names   = {"X1","X2","X3","X4","X5","Y1-","Y2-"},
   before  = {Num{lo=0,hi=1}, Num{lo=0,hi=1}, Num{lo=0,hi=1}, 
              Num{lo=0,hi=1}, Num{lo=0,hi=1},
              Num(), Num()},
   f      = zdt1}

-- lean {
--   max=1000, wait=10,  pause=100, 
--   goal=gt,  enough=0, before=Num{mu=-6,sd=100},
--   f = function(x) return e^(-(x-2)^2) + .8*e^(-(x+2)^2) end}

print(5, table.unpack(zdt1(5)))
the"END"
