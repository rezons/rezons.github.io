
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>


```lua
Num=oo();function Num.new(z) return it(Num,{a=z,b=2}) end
Sym=oo();function Sym.new(z) return it(Sym,{k=X.new(31),zz=2}) end
```
function nums(t,     mu,sd)
  mu=0; for _,x in pairs(t) do mu=mu+x        end; mu=mu/#t
  sd=0; for _,x in pairs(t) do sd=sd+(x-mu)^2 end; sd=(sd/(n-1))^.5
  return mu,sd end

```lua
--
```
local is={}
function is.goal(s) return s:find"+" or s:find"-" or s:find"=" end
function is.skip(s) return s:find":" end
function is.num(s)  return s:match("^[A-Z]") end
function is.ako(s)  return is.skip(s) and Skip or (is.num(s) and Num or Sym) end
function is.wght(s) return (s:find"+" and 1) or (s:find"-" and -1) or 0 end

```lua
--
```
local bests=klass() 
function bests.new() return setmetatable({best={},rest={}},best) end

```lua
--
```
local num=klass()
function num.new(at,) return setmetatable({lo=1E21,hi=-1E31},num) end

```lua
--
```
function bests:better(row1,row2, ws)
  local e,w,s1,s2,n,a,b,what1,what2
  for _ in pairs(w) do n=n+1 end
  what1, what2, e = 0, 0, math.exp(1)
  for col,w in pairs(ws) do
    a     = col:norm(row1[col])
    b     = col:norm(row2[col])
    w     = col.w -- w = (1,-1) if (maximizing,minimizing)
    what1 = what1 - e^(col.w * (a - b) / n)
    what2 = what2 - e^(col.w * (b - a) / n) end
  return what1 / n < what2 / n end

```lua
--
```
function yweights(names)
  ws={}
  for i,s in pairs(names) do if is.goal(s) and is.wght(s) ~= 0 then 
    ws[i] = is.wght(s) end end 
  return ws end

```lua
--
```
function bore(n,guess,f,names,     xs,ys)
  for _ = 1,(n or 256) do
    xs= guess()
    ys= f(xs)
    for _,zs in pairs{xs,ys} do
      for _,z in pairs(zs) do egs[1+#egs]=z end end end
  for i,name in pairs(names) do
    if is.num(name) then
      t={}, for _,eg in pairs(egs) do t[1+#t] = eg[i] end
      mu,sd = nums(t)
      stats[i] = {at=i,name=name,sd=sd,mu=mu,all={}}
      nums(t,stats[i])
    
end
