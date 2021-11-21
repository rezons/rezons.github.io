local the       = require"the"
local obj,has   = the"metas obj has"
local shout     = the"prints shout"
local r,e,srand = the"maths r e srand"
local top,ntimes,push,sort,per = the"tables top ntimes push sort per"
local round,sqrt,log,cos,pi,lt,gt,r = the"maths round sqrt log cos pi lt gt r"
local Best = require"best"

local Num=obj"Num"
function Num.new(t) 
  local self = has(Num,{n=0,mu=0,m2=0,sd=0})
  if t then
    if   t.inits 
    then self:adds(t.inits or {})  
    else self.mu, self.sd = t.mu or 0, t.sd or 0 end end
  return self end
 
function Num:z(x)    return (x - self.mu) / self.sd end
function Num:any()   return self.mu+self.sd*sqrt(-2*log(r()))*cos(2*pi*r()) end
function Num:adds(t) for _,x in pairs(t) do self:add(x) end; return self end
function Num:add(x)
  local d = x - self.mu
  self.n  = self.n + 1
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x - self.mu)
  self.sd = ((self.m2<0 or self.n<2) and 0) or ((self.m2/(self.n-1))^0.5)
  return x end

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

local function crossEntropy(it)
  local best,good,one,xs1,xs,ys
  function one(_,x)  x=xs:any(); return {x=x,y=it.f(x)} end
  function good(a,b) return it.better(a.y,b.y) end 
  it = suggestions(it)
  xs = it.before
  best = it.n*it.top
  for i = 1,it.m do
    xs1, ys = Num(), Num()
    for _,xy in pairs(top(best, sort(ntimes(it.n, one), good))) do
      xs1:add(xy.x) 
      ys:add(xy.y) end
    if it.verbose then print(rnd3(xs1.mu), rnd3(ys.mu)) end
    xs = xs1 
  end
  return xs1,ys end

srand(the.seed)
local xs,ys =crossEntropy {
   m=5;n=30; top=.2;
   better = gt,
   verbose= true,
   before = Num{mu=-0,sd=3},
   f      = function(x) return e^(-(x-2)^2) + .8*e^(-(x+2)^2) end}

the"END"
