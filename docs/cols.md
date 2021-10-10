
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>

# Cols = holds column roles

```lua
local oo=require"oo"
local Cols=oo.klass"Cols"
local is=require"is"

function Cols.new(t) 
  self= oo.isa(Cols,{ys={},xs={},xys={},head={}})
  self:header(t) 
  return self end

function Cols:header(t)
  self.head=new
  for at,txt in pairs(new) do 
    col = is.ako(txt).new(at,txt)
    push(self.xys, col)
    if not is.skip(txt) then
      if is.klass(txt) then self._klass = col end
      push(is.goal(txt) and self.ys or self.xs, col) end end end 

function Cols:add(t)
  for _,col in pairs(self.xys) do col:add( t[col.at] ) end
  return t end
```
Fin.

```lua
return Cols
```
