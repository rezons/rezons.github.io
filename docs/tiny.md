
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/rezons/rezons.github.io/actions/workflows/tests.yml/badge.svg"></a>

<hr>


```lua
local csv,map,isa,obj,add,out,shout,str
local push=table.insert
```
## Classes

```lua
function obj(name,   k) k={_name=name,__tostring=out}; k.__index=k; return k end
local Num,Skip,Sym = obj"Num", obj"Skip", obj"Sym"
local Cols,Sample  = obj"Cols", obj"Sample"
```
## Initialization

```lua
function Skip.new(at,txt) return isa(Skip,{n=0,txt=txt,at=at}) end

function Num.new(at,txt) 
  txt = txt or ""
  return isa(Num,{n=0,txt=txt,at=at, hi=-1E21,lo=1E31,has={},
                  w=txt:find"+" and 1 or txt:find"-" and -1 or 0}) end

function Sym.new(at,txt) return isa(Sym,{n=0,txt=txt,at=at,has={},most=0,mode="?"}) end

function Cols.new(t) return isa(Cols,{names={},all={}, xs={}, ys={}}):init(t) end

function Sample.new(file) return isa(Sample,{rows={},cols=nil}):init(file) end
```
## Initialization Support

```lua
function Sample:init(file) 
  if file then for row in csv(file) do self:add(row) end end
  return self end

function Cols:init(t,      u,is,goalp) 
  function is(s) return s:find":" and Skip or s:match"^[A-Z]" and Num or Sym end
  function goalp(s) return s:find"+" or s:find"-" or s:find"!" end
  self.names = t
  for at,name in pairs(t) do
    local new = is(name).new(at,name) 
    push(self.all, new)
    if not name:find":" then
      push(goalp(name) and self.ys or self.ys, new) end end 
  return self end
```
## Updating

```lua
function add(i,x) if x~="?" then i.n = i.n+1; i:add(x) end; return x end

function Skip:add(x) return end

function Num:add(x)
  self.has[1+#self.has]=x
  self.lo=math.min(x,self.lo); self.hi=math.max(x,self.hi) end

function Sym.add(i,x)
  i.has[x] = 1+(i.has[x] or 0) 
  if i.has[x] > i.most then i.most,i.mode = i.has[x],x end end

function Sample:add(t)
  local function worker(c,x)  return add(self.cols.all[c],x) end
  if   not self.cols 
  then self.cols=Cols.new(t) 
  else push(self.rows, map(t,worker)) end end
```
## Distance

```lua
```
------------------------------
Misc

```lua
function shout(t) print(#t>0 and str(t) or out(t)) end

function out(t)
  local function show(k)     k=tostring(k); return k:sub(1,1) ~= "_" end 
  local function pretty(_,v) return string.format(":%s %s", v[1], v[2]) end
  local u={}; for k,v in pairs(t) do if show(k) then u[1+#u] = {k,v} end end
  table.sort(u, function(x,y) return x[1] < y[1] end)
  return (t._name or "")..str(map(u, pretty)) end 

function str(t,      u)
  u={}; for _,v in ipairs(t) do u[1+#u] = tostring(v) end 
  return '{'..table.concat(u, ", ").."}"  end

function map(t,f,      u) 
  u={};for k,v in pairs(t) do u[k]=f(k,v) end; return u end

function isa(mt,t) return setmetatable(t, mt) end

function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if  #t > 0
      then for j,x in pairs(t) do t[j] = tonumber(x) or x end
           return t end
    else io.close(stream) end end end

local n=Num.new()
for _,x in pairs{10,20,30,40} do add(n,x) end
shout(n)

local s=Sym.new()
for _,x in pairs{10,10,10,10,20,20,30} do add(s,x) end
shout(s.has)

local s=Sample.new()
shout(s)
local s=Sample.new("../data/auto93.csv")
shout(s.cols.all[3])

for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v))  end end 
```
