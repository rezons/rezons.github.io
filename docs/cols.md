
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

function Cols.new() return oo.isa(Cols,{ys={},xs={},xys={},head={}}) end
```
Definitions of special column header roles.

```lua
function Cols:isKlass(s) return s:find"=" end
function Cols:isGoal(s)  return s:find"+" or s:find"-" or s:find"=" end
function Cols:isSkip(s)  return s:find":" end
function Cols:isNum(s)   return s:match("^[A-Z]") end
function Cols:ako(s) 
  return self:isSkip(s) and Skip or (self:isNum(s) and Num or Sym) end

function Cols:header(t)
  self.head=new
  for at,txt in pairs(new) do 
    col = ako(txt).new(at,txt)
    push(self.xys, col)
    if not self:isSkip(txt) then
      if self:isKlass(txt) then self._klass = col end
      push(self:isGoal(txt) and self.ys or self.xs, col) end end end 
```
Fin.

```lua
return Cols

```
