
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>

# Num = columns to treat as numbers
Theory note: CRUD. Delegation
## Create
`lo` and  `hi` are initialized to ridiculous high and  low values
so that  every number that arrives afterwards is lower than
the initial low and higher than the initia, high,

```lua
local oo=require"oo"
local Num=oo.klass"Num"

function Num.new(at,txt) 
  return oo.isa(Num,{at=at,txt=txt, 
    n=0, mu=0, m2=0, sd=0, lo=1E32,hi -1E32},Num) end
```
## Update
Knuth's incremental valuation  of  standard deviation.

```lua
function Num:summarize(x,    d)
  if x~="?" then
    if self.some then self.some:add(x) end
    self.n  = self.n + 1
    self.lo = math.min(self.lo,x)
    self.hi = math.max(self.hi,x) 
    d       = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n<2 and 0 or (self.m2/(self.n-1))^0.5 end end
```
## Query
Variability about the central tendency.

```lua
function Num:spread() return self.sd end
```
## Services
Aha's distance measure. If missing values, make the assumptions
that maximizes the distance.

```lua
function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return math.abs(x-y) end
```
Normalization of `x` 0..1 for `lo..hi`.

```lua
function Num:norm(x)
  local lo,hi=self.lo,self.hi
  return (x=="?" and x) or (math.abs(lo-hi)<1E-32 and 0) or (x-lo)/(hi-lo) end  

function Num:border(other)
  local mu1,sd1,mu2,sd2,a,b,c,d,r1,r2
  mu1,sd1 = self.my,  self.sd
  mu2,sd2 = other.my, other.sd
  if sd1==sd2  then return (mu1+mu2)/2 end
  if mu2 < mu1 then return border(mu2,sd2,mu1,sd1) end
  a  = 1/(2*sd1^2) - 1/(2*sd2^2)
  b  = mu2/(sd2^2) - mu1/(sd1^2)
  c  = mu1^2 /(2*sd1^2) - mu2^2 / (2*sd2^2) - math.log(sd2/sd1)
  d  = math.sqrt(b^2 - 4*a*c)
  r1 = (-b + d)/(2*a)
  r2 = (-b - d)/(2*a)
  return mu1 <= r1 and r1 <= mu2 and r1 or r2 end
```
Fin.

```lua
return Num
```
