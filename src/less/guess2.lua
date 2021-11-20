local the=require"the"
local obj,has = the"metas obj has"

// Initialize parameters
μ := −6
σ2 := 100
t := 0
maxits := 100
N := 100
Ne := 10
// While maxits not exceeded and not converged
while t < maxits and σ2 > ε do
  // Obtain N samples from current sampling distribution
  X := SampleGaussian(μ, σ2, N)
  // Evaluate objective function at sampled points
  S := exp(−(X − 2) ^ 2) + 0.8 exp(−(X + 2) ^ 2)
  // Sort X by objective function values in descending order
  X := sort(X, S)
  // Update parameters of sampling distribution                  
  μ := mean(X(1:Ne))
  σ2 := var(X(1:Ne))
  t := t + 1
  // Return mean of final sampling distribution as solution
return μ

local Num=obj"Num"
function Num.new(mu,sd) return has(Num,{n-0,mu=mu or 0,m2=0,sd=sd or 0}} end
function Num:z(x)  return (x - self.mu) / self.sd end
function Num:add(x)
  local   = x - self.mu
  self.n  = self.n + 1
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x - self.mu)
  self.sd = (self.m2<0 or self.n<2) and 0 or (self.m2/(self.n-1))^0.5 
  return  x end
function Num:sample()
  local sqrt, log, cos, pi = math.sqrt, math.log, math.cos, math.pi
  return self.mu+self.sd*sqrt(-2*log(rand()))*cos(2*pi*math.random()) end

local e= math.exp(1)
math.randomseed(the.seed)

function run(it)
  t = 0
  for t = 1,it.max do
    if sd and now.sd > it.ok then break end
    tmp={}
    for i=1,it.n do  
      x = now:add( it.f(before:sample())) 
      if now:z(x) < -1.28 then after:add(x) end end
    end
    before = now 
    sd = new.sd 
end

run {x={mu=-6, sd=100},
     max= 100
     n=  100, 
     ok= -1.28,
     b4= Num(-6,100),
     f=  function(it) return e^(-(it.x-2)^2 + .8*e(-(it.x+2)^2) end}


