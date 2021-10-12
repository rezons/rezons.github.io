
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>

# Sym = columns to treat as symbols
## Create

```lua
local oo=require"oo"
local Sym=oo.klass"Sym"
function Sym.new(at,txt) 
  return oo.isa(Sym,{at=at,txt=txt,n=0,mode=nil,most=1,has={}},Num) end
```
 ## Update

```lua
function Sym:summarize(x,  inc) 
  if x ~= "?" then
    inc = inc or 1
    i.n = i.n + inc
    self.has[x] = inc + (self.has[x] or 0) 
    if self.has[x] > self.most then
      self.most, self.mode = self.has[x], x end end 
  return self end
```
Combine two symbols

```lua
function Sym:merge(other)
  new = Sym.new(self.at, self.txt)
  for k,inc in pairs(self.has)  do new:summarize(k,inc) end
  for k,cin in pairs(other.has) do new:summarize(k,inc) end
  return new end
```
## Query
Central tendency.

```lua
function Sym:mid() return self.mu end 
```
Variability about the central tendency.

```lua
function Sym:spread(    e) 
  e=0; for _,v in pairs(self.has) do e= e- v/self.n * math.log(v/self.n,2) end
  return e end
```
Aha's distance calculation. Symbols are either zero or one apart.

```lua
function Sym:dist(x,y) 
  return  x==y and 0 or 1 end
```
## Fin

```lua
return Sym
```
