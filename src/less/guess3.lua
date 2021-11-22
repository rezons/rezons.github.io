local the                = require"the"
local obj,has            = the"metas obj has"
local out,shout,fmt      = the"prints out shout fmt"
local gt,r,e             = the"maths gt r e"
local srand,cos,pi,lt    = the"maths srand cos pi lt"
local sort,map,per,push  = the"tables sort map per push"
local top,ntimes,firsts  = the"tables top ntimes firsts"
local round,sqrt,abs,log = the"maths round sqrt abs log"

-------------------------------------------------------------------------------
local Num=obj"Num"
function Num.new(t, self) 
  t=t or {}
  self=has(Num,{lo=t.lo or 1E32, hi=t.hi or -1E32, at=t.at or 0,
                txt=t.txt or"", n=0, mu=0, m2=0, sd=0, new=true})
  self.w = self.txt:find"-" and -1 or 1
  return self:adds(t.inits or {}) end

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
function Num:adds(t) 
  for _,x in pairs(t) do self:add(x) end; return self end
function Num:any(    z)   
  if   self.new 
  then  return self.lo+r()*(self.hi - self.lo)
  else  return self.mu+self.sd*sqrt(-2*log(r()))*cos(2*pi*r()) end end 
function Num:mid() 
  return self.mu end
function Num:norm(x,  z)
  local lo, hi = self.lo, self.hi
  local x1= abs(lo - hi) < 1E-31 and 0 or (x - lo) / (hi - lo) 
  print("::",x,lo,hi,x1)
  return x
  end
function Num:z(x)    
  return (x - self.mu) / self.sd end

-------------------------------------------------------------------------------
local Sym=obj"Sym"
function Sym.new(t,  self) 
  t=t or {}
  self=has(Sym,{at=t.at or 0,txt=t.txt or "",has={},most=0,mode=nil})
  return self:adds(t.inits or {}) end

function Sym:add(x,  inc)
  inc = inc or 1
  self.n = self.n + inc
  self.seen[x] = inc + (self.has[x] or 0)
  if self.has[x] > self.most then self.most,self.mode=self.has[x],x end 
  return x end
function Sym:adds(t) 
  for _,x in pairs(t) do self:add(x) end; return self end
function Sym:any(   k1)   
  local n = r(self.n)
  for k,v in pairs(self.has) do k1=k;n=n-v; if n<=0 then return k end end
  return k1 end
function Sym:mid() 
  return self.mode end

-------------------------------------------------------------------------------
local Summary=obj"Summary"
function Summary.new(lst)
  local all,xs,ys={},{},{}
  for k,v in pairs(lst) do
    local now = (v:match"^[A-Z]" and Num or Sym){txt=v,at=k}
    push(all, now)
    push((v:find"+" or v:find"-") and ys or xs, now) end 
  return has(Summary, {header=lst,all=all,xs=xs,ys=ys,n=0}) end

function Summary:add(eg)
  self.n = self.n + 1
  for _,col in pairs(self.all) do col:add(eg[col.at]) end
  return eg end
function Summary:any(cols)  
  return map(cols or self.all, function(_,c) return c:any() end) end 
function Summary:better(eg1,eg2)
  local n,a,b,s1,s2
  s1, s2, n = 0, 0, #self.ys
  for _,col in pairs(self.ys) do
    a  = col:norm(eg1[col.at]) --normalize to avoid
    b  = col:norm(eg2[col.at])
    s1 = s1 - e^(col.w * (a - b) / n)
    s2 = s2 - e^(col.w * (b - a) / n) end
  return s1 / n < s2 / n end
function Summary:betters(egs)
  return sort(egs, function(a,b) return self:better(a,b) end) end
function Summary:clone() 
  return Summary(self.header) end
function Summary:mid(cols)
  return map(cols or self.all,function(_,col) return col:mid() end) end
function Summary:range(lo,hi)
  for _,col in pairs(self.all) do 
    if col._is=="Num" then col.lo=lo or 0; col.hi=hi or 1 end end
  return self end
  
-------------------------------------------------------------------------------
local function zdt1(egx,  d)
  local f1,g,h,f2,eg
  for i=1,(d or 10) do egx[i]=r() end
  f1 = egx[1]
  g  = 0; for i=2,#egx do g = g + egx[i] end
  g  = 1 + 9 / (#egx-1) * g
  h  = 1 - (f1 / g)^.5
  eg = egx
  push(eg, f1)
  push(eg. g*h)
  return eg end

local r2,r3,r3s,nCrossEntropy,with

function r2(x) return round(x,2) end
function r3(x) return round(x,3) end
function r3s(t) return map(t,function(_,x) return round(x,3) end) end

function with(it,it0, out) 
  out, it, it0 = {}, it or {}, it0 or {}
  for k,v in pairs(it)  do assert(it0[k] ~= nil, fmt("with %s not known",k)) end
  for k,v in pairs(it0) do out[k] = it[k]==nil and it0[k] or it[k] end
  return out end

function nCrossEntropy(it0,        now,first,best,it,xy,ok,now,b4,ys)
  it = with(it0, {verbose=false,n=10,generations=100,top=.1,
                  before=false,f=function(_) return true end})
  b4 = it.before
  function xy(_,egx) egx=b4:any(b4.xs); return now:add(it.f(egx)) end
  function ok(a,b)   return now:better(a,b) end 
  for i = 1,it.generations do
    now= b4:clone()
    now= sort(ntimes(it.n, xy), ok)
    if i==1 then first=now end
    if i==1 then
      shout(r3s(now[1]))
      shout(r3s(now[#now//2]))
      shout(r3s(now[#now])) end
    best = b4:clone()
    for _,one in pairs(top(it.n*it.top, now)) do
      best:add(one) end
    if it.verbose then print( out(now:mid(now.ys))) end
    b4 = best 
  end
  return first,best end

-------------------------------------------------------------------------------
srand(the.seed)
local first,last = nCrossEntropy {
   generations = 10,
   n       = 1000,
   top     = .05;
   verbose = false,
   before  = Summary({"X1","X2","X3","X4","X5","Y1-","Y2-"}):range(),
   f       = zdt1}

shout(first:mid(first.ys))
shout(last:mid(last.ys))

-- lean {
--   max=1000, wait=10,  pause=100, 
--   goal=gt,  enough=0, before=Num{mu=-6,sd=100},
--   f = function(x) return e^(-(x-2)^2) + .8*e^(-(x+2)^2) end}

the"END"
