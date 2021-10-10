-- vim: ft=lua ts=2 sw=2 et:

-- # Nums = columns to treat as numbers
local oo=require"oo"
local Num=oo.klass"Num"

-- ## Create
-- `lo` and  `hi` are initialized to ridiculous high and  low values
-- so that  every number that arrives afterwards is lower than
-- the initial low and higher than the initia, high,
function Num.new(at,txt) 
  return oo.isa(Num,{at=at,txt=txt, 
    n=0, mu=0, m2=0, sd=0, lo=1E32,hi -1E32},Num) end

-- ## Update
-- Knuth's incremental valuation  of  standard deviation.
function Num:add(x,    d)
  if x~="?" then
    if self.some then self.some:add(x) end
    self.n  = self.n + 1
    self.lo = math.min(self.lo,x)
    self.hi = math.max(self.hi,x) 
    d       = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n<2 and 0 or (self.m2/(self.n-1))^0.5 end end

-- ## Query
-- Variability about the central tendency.
function Num:spread() return self.sd end

-- ## Services

-- Aha's distance measure. If missing values, make the assumptions
-- that maximizes the distance.
function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return math.abs(x-y) end

-- Normalization of `x` 0..1 for `lo..hi`.
function Num:norm(x)
  local lo,hi=self.lo,self.hi
  return (x=="?" and x) or (math.abs(lo-hi)<1E-32 and 0) or (x-lo)/(hi-lo) end  

local function border(mu1,sd1,mu2,sd2,     a,b,c,d,r1,r2)
  if sd1==sd2  then return (mu1+mu2)/2 end
  if mu2 < mu1 then return border(mu2,sd2,mu1,sd1) end
  a  = 1/(2*sd1^2) - 1/(2*sd2^2)
  b  = mu2/(sd2^2) - mu1/(sd1^2)
  c  = mu1^2 /(2*sd1^2) - mu2^2 / (2*sd2^2) - math.log(sd2/sd1)
  d  = math.sqrt(b^2 - 4*a*c)
  r1 = (-b + d)/(2*a)
  r2 = (-b - d)/(2*a)
  return mu1 <= r1 and r1 <= mu2 and r1 or r2 end

-- Fin.
return border
