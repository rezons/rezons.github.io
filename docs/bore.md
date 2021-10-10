
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>

# Bore = best or rest

```lua
local oo=require"oo"
local Bore=oo.klass"Bore"

local Sym=require"Sym"
local Some=require"Some"

function Bore.new(all,my)
  return oo.isa(Bore,
    {my=my, some=function () return Some.new(the.some) end}):main(num1,num2) end

function Bore:main(num1,num2,   xys)
  xys={}
  for _,v in pairs(num1.some:all()) do table.insert(xy,{v,true}) end
  for _,v in pairs(num2.some:all()) do table.insert(xy,{v,false}) end
  sd = (self.sd*self.n + other.sd*other.n) / (self.n+other.n)
  return self:merge(
           self:bins(xys, sd*self.my.cohen, (#xys)^self.my.bins)) end

local Nums=oo.klass"Nums"
function Nums(xs,ys,at,name,somes)
   return oo.obj(Nums, {at=at or 0, name=name or "",
                   xs=xs or some(), ys=ys or Sym.new()}) end
```
XXX clone

```lua
function Bore:bins(xys, tiny, enough,         now,out,x,y)
  while width <4 and width<#xy/2 do width=1.2*width end --grow small widths
  now = Nums.new()
  out = {now}
  for j,xy in sort(xys,"x") do
    x,y = xy[1],xy[2]
    if j < #xys - enough then -- (1)
      if x ~= xys[j+1][1] then -- (2)
        if now.x.n > enough then -- (3)
          if now.hi - now.lo > tiny then -- (4)
            now= Nums.new()
            out[ 1+#out ] = now end end end end
    now.xs.add(x)
    now.ys.add(y) end
  return prune(out) end
```
Return a smaller version of `b4` (by subsuming ranges
that do not change the class distributions seen in `ys`)

```lua
function Bore:merge(b4,         j,tmp,n,a,b,cy)
  j, n, tmp = 1, #b4, {}
  while j<=n do
    a= b4[j]
    if j < n-1 then
      b= b4[j+1]
      cy= a.ys:merge(b.ys)
      if cy:var() <= (a.ys:var()*a.ys.n + b.ys:val()*b.ys.n) / cy.n then
         a= Nums.new(a.xs:merge(b.xs),  cy)
         j = j + 1 end end
    tmp[1+#tmp] = a
    j = j + 1
  end
  return #tmp==#b4 and tmp or merge(tmp) end
```
