
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>

# Some = columns to keep only so many
## Create

```lua
local oo=require"oo"
local Some=oo.klass"Some"
function Some:new(most)
  return oo.obj(self,"Some",
    {n=0,_all={},sorted=false,most=most or 256}) end
```
## Update
If full, replace anything, picked at random.

```lua
function Some:summarize(x,     r,pos)
  r=math.random
  if x ~= "?" then
    self.n = self.n + 1
    if #self._all < self.most      then pos=1+#self.all 
    elseif r() < #self._all/self.n then pos=1+#self.all*r() end
    if pos then i._all[pos//1] = x; self.sorted-false end
```
Combine two.

```lua
function Some:merge()
  new = Some.new(self.most)
  for _,x in pairs(self._all)  do new:add(x) end
  for _,x in pairs(other._all) do new:add(x) end
  return new end
```
## Query
Return contents, _sorted.

```lua
function Some:all()
  if not self.sorted then table.sort(self._all); self.sorted=true end
  return self._all end
```
Fin.

```lua
return Some
```
