
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>

# Sample = summarize rows into columns

```lua
local oo=require"oo"
local Cols=require"Cols"
local Sym=require"Sym"
local Num=require"Num"
local Skip=require"Skip"
```
Create

```lua
local Sample=klass"Sample"
function Sample.new(my, inits)
  return isa(Sample,
           {rows={},cols=Cols.new(),my=my,keep=true}):adds(inits) end
```
Initialize.

```lua
function Sample:adds(inits)
  if type(inits)=="table"  then for _,t in pairs(inits) do it:add(t) end end
  if type(inits)=="string" then for _,t in csv(inits)   do it:add(t) end end
  return it end
```
Update with a new row. If this is the first row, then use it to create our
headers.

```lua
function Sample:add(new)
  if #self.cols.xys>0 then
    for _,col in pairs(self.cols.xys) do col:add(new[col.at]) end
    if self.keep then push(self.rows,new) end
  else
    self.cols:header(new) end end
   
function Sample:distance(row1,row2,cols)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, self.my.p
  for _,col in pairs(cols or self.xs) do
    x,y = row1[col.at],row2[col.at]
    inc = x=="?" and y=="?" and 1 or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end
    
function Sample:neighbors(row1,rows,cols,    t)
  rows = rows or top(self.my.some, shuffle(self.rows))
  t={}
  for _,row2 in pairs(rows) do 
    push(t, {self:distance(row1,row2,cols),row2}) end
  table.sort(t, function (x,y) return x[1] < y[1] end)
  return t end

function Sample:faraway(row1,rows,cols,    tmp)
  tmp = self:neighbors(row1,rows,cols)
  return tmp[self.my.far * #tmp // 1] end

function Sample:klass(row) return row[self._klass.at] end
```
Fin.

```lua
return Sample

```
