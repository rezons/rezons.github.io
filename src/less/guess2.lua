local the=require"the"
local obj,has = the"metas obj has"

local Num=obj"Num"
function Num.new(mu,sd) return has(Num,{n-0,mu=mu or 0,m2=0,sd=sd or 0}) end
function Num:z(x)       return (x - self.mu) / self.sd end
function Num:add(x)
  local d = x - self.mu
  self.n  = self.n + 1
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x - self.mu)
  self.sd = (self.m2<0 or self.n<2) and 0 or (self.m2/(self.n-1))^0.5 
  return x end
function Num:sample()
  local sqrt, log, cos, pi = math.sqrt, math.log, math.cos, math.pi
  return self.mu+self.sd*sqrt(-2*log(rand()))*cos(2*pi*math.random()) end

local e= math.exp(1)
math.randomseed(the.seed)

function run(self,   sd,tmp,best)
  sd = math.huge
  b4 = it.b4
  for t = 1,it.max do
    if sd  < it.ok then break end
    tmp, best = Num(), Num()
    for i=1,it.n do  
      x = tmp:add( it.f(b4:sample()) ) 
      if it.good(tmp:z(x)) then best:add(x) end end
    b4 = best
    sd = best.sd end 
  return best end

run {max= 100,
     n=  100, 
     ok=  100,
     good= function (z) return z <= -1.28 end,
     b4= Num(-6,100),
     f=  function(x) return e^(-(x-2)^2) + .8*e(-(x+2)^2) end}
