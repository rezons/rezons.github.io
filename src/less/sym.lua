local the     = require"the"
local obj,has = the.get"metas obj has"
local push    = the.get"tables push"
local Score   = require"score"

local Sym = obj"Sym" 
function Sym.new(i,s) 
  return has(Sym, {at=i or 0,txt=s or "",n=0,seen={},mode=nil,most=0}) end

function Sym:add(x, inc)    
  if x=="?" then return x end; 
  inc = inc or 1
  self.n = self.n + inc
  self.seen[x] = inc + (self.seen[x] or 0) 
  if self.seen[x] > self.most then 
     self.most,self.mode = self.seen[x],x end end

function Sym:dist(x,y) return  x==y and 0 or 1 end

function Sym:fuse(other,   tmp)
  tmp = Sym.new()
  for x,inc in pairs(self.seen)  do tmp:add(x,inc) end
  for x,inc in pairs(other.seen) do tmp:add(x,inc) end
  return tmp end

-- return a fused `Sym` if  that combination is simpler than
-- its parts (i.e. if the expected value of the spread reduces).
function Sym:fused(other,  a,b,c)
  a,b,c = self, other, self:fuse(other)
  if c:spread() <= (a:spread()*a.n + b:spread()*b.n)/c.n then return c end end

function Sym:mid()     return self.mode end

function Sym:spread()  -- entropy
  return sum(self.seen, 
             function(n) return n<-0 and 0 or -n/self.n*log(n/self.n,2) end) end

function Sym:ranges(other,out,   r,B,R)
  B, R = self.n, other.n
  for x,b in pairs(self.seen) do
    r =  other.seen[x] or 0
    push(out, {col=self, lo=x, hi=x, val=Score.score(b,r,B,R)}) end end 

return Sym
