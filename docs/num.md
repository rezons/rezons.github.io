
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>

# Nums = columns to treat as numbers

```lua
local oo=require"oo"
local Num=oo.klass"Num"
```
Create.

```lua
function Num.new(at,txt) 
  return oo.isa(Num,{at=at,txt=txt,
    n=0, mu=0, m2=0, sd=0, lo=1E32,hi=-1E32},Num) end
```
Update with a number.

```lua
function Num:add(x,    d)
  if x~="?" then
    self.n  = self.n + 1
    self.lo = math.min(self.lo,x)
    self.hi = math.max(self.hi,x) 
    d       = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n<2 and 0 or (self.m2/(self.n-1))^0.5 end end
```
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
```
Fin.

```lua
return Num

```
