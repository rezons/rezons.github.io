-- vim: ft=lua ts=2 sw=2 et:

-- # Nums = columns to treat as numbers
local oo=require"oo"
local Num=oo.klass"Num"

-- Create.
function Num.new(at,txt) 
  return oo.isa(Num,{at=at,txt=txt,
    n=0, mu=0, m2=0, sd=0, lo=1E32,hi=-1E32},Num) end

-- Update with a number.
function Num:add(x,    d)
  if x~="?" then
    self.n  = self.n + 1
    self.lo = math.min(self.lo,x)
    self.hi = math.max(self.hi,x) 
    d       = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n<2 and 0 or (self.m2/(self.n-1))^0.5 end end

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

-- Fin.
return Num
