
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/rezons/rezons.github.io/actions/workflows/tests.yml/badge.svg"></a>

<hr>

# Cols = holds column roles

```lua
local is=require"is"
local oo=require"oo"
local Sym,Num,Skip = require"sym", require"num", require"skip"
```
## Create

```lua
local Cols=oo.klass"Cols"
function Cols.new(t) 
  self= oo.isa(Cols,{ys={},xs={},xys={},head={}})
  self:header(t) 
  return self end
```
## Update
Either create the column headers

```lua
function Cols:header(t)
  self.head=new
  for at,txt in pairs(new) do 
    col = is.ako(txt,skip,num,sym).new(at,txt)
    push(self.xys, col)
    if not is.skip(txt) then
      if is.klass(txt) then self._klass = col end
      push(is.goal(txt) and self.ys or self.xs, col) end end end 
```
Or update the headers with new information.

```lua
function Cols:summarize(t) 
  for _,col in pairs(self.xys) do col:summarize( t[col.at] ) end end
```
Fin.

```lua
return Cols
```
