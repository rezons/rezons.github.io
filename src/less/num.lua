local the      = require"the"
local obj,has  = the"metas obj has"
local abs      = the"maths abs"
local push,per = the"tables push pers"

local Num= obj"Num" 
function Num.new(i,s) 
  s=s or ""
  return has(Num,{
    at=i or 0,txt=s, n=0,_contents={}, lo=1E32,hi=-1E32, ok=false,
    w =s:find"+" and 1 or s:find"-" and  -1 or 0}) end

function Num:add(x) 
  if x=="?" then return x end
  self.n = self.n + 1
  if x>self.hi then self.hi=x end
  if x<self.lo then self.lo=x end
  push(self._contents, x)
  self.ok = false end -- note: the updated contents are no longer sorted

-- Ensure the contents are shorted; them return those concents.
function Num:all(x)
  if not self.ok then self.ok=true; table.sort(self._contents) end
  return self._contents end

-- If either of `x,y` is unknown, guess a value that maximizes the distance.
function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return abs(x-y) end

-- central tendency
function Num:mid(    a) a=self:all(); return a[#a//2] end

-- convert `x` to 0..1 for min..max.
function Num:norm(x,     lo,hi)
  lo,hi = self.lo,self.hi
  return abs(lo - hi)< 1E-16 and 0 or (x - lo)/(hi-lo) end

-- The standard deviation of a list of sorted numbers  is the
-- 90th - 10th percentile, divided by 2.56. Why? It is widely
-- know that &plusmn; 1 to 2 standard deviations is 66 to 95% 
-- of the probability. Well, it is also true that
-- &plusmn; is 1.28 is 90% of the mass which, to say that 
-- another way, one standard deviation is 2\*1.28 of &plusmn; 90%.
function Num:spread(   a) a=self:all(); return (per(a,.9) - per(a,.1))/2.56 end

return  Num
