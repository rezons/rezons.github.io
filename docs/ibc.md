
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/rezons/rezons.github.io/actions/workflows/tests.yml/badge.svg"></a>

<hr>

# IBC: iterative bi-clustering
(c) Tim Menzies 2021, unlicense.org
- Divide data samples in two (best and rest)
- Apply some _reasons_ over the `x` or `y` variables to favor one half. 
- Find and print the variable range that selects for best.
- Cull the rest.
- Repeat.

```lua
local the, csv,map,isa,obj,add,out,shout,str,keys,xpect,goods,sort,any,first,fmt
local mu_sd, mode_ent, shuffle, top
local adds, nump,yellow,blue,red,is,green,ignore,Seed,rand,randi,cat,push
```
## Settings, CLI
Check if `the` config variables are updated on the command-line interface.

```lua
local function cli(flag, b4)
  for n,word in ipairs(arg) do if word==flag then
    return (b4==false) and true or tonumber(arg[n+1]) or arg[n+1]  end end 
  return b4 end

local function about() return {
  bw=    cli("-B",  false),
  cohen= cli("-c", .35),
  enough=cli("-e", .5),
  eval=  cli("-F",  8),
  few=   cli("-f",  64),
  p=     cli("-p" , 2),
  seed=  cli("-S",  937162211),
  todo=  cli("-t",  "ls"),
  wild=  cli("-W",  false) } end
```
## Classes
Columns of data either `Num`eric, `Sym`bolic, or things we are going to `Skip` over.
`Sample`s hold rows of data, summarized into `Cols` (columns).

```lua
function obj(is,   k) 
  k={_is=is,__tostring=function(x) return out(x) end}; k.__index=k; return k end
```
----------------------------------------------------------
## Skip

```lua
local Skip=obj"Skip"
function Skip.new(c,s)    return isa(Skip,{n=0,txt=s,at=c or 1}) end
```
Don't bother updating some columns.

```lua
function Skip:add(x,n) return end
```
----------------------------------------------------------
## Sym

```lua
local Sym=obj"Sym"
function Sym.new(c,s)  
  return isa(Sym,{n=0,txt=s,at=c or 1,has={},most=0,mode="?"}) end
```
Update the symbol counts and, maybe, the most commonly seen symbol (the `mode`).

```lua
function Sym:add(x,n)
  n = n or 1
  self.has[x] = 1+(self.has[x] or 0) 
  if self.has[x] > self.most then self.most, self.mode=self.has[x], x end end
```
Return a new sym that combines `self` and `other`

```lua
function Sym:merge(other,     new)
  new = Sym.new(self.at, self.txt)
  for k,n in pairs(self.has) do  new:add(k,n) end
  for k,n in pairs(other.has) do new:add(k,n) end
  return new end
```
Distance

```lua
function Sym:dist(x,y) 
  return  x==y and 0 or 1 end

local function _br(other,     goal)
  local b,r, B, R = 0, 0, 1E-32, 1E-32
  goal = goal == nil and true or goal
  for k,v in pairs(other.has) do 
    if k==goal then B=B+v else R=R+v end end 
  for k,v in pairs(self.has) do 
   if k==goal then b=b+v; B=B+v else r=r+v; R=R+V end end
  return b/B, r/R end  

function Sym:novel(other) b,r=br(self,other); return 1/(b+r) end
function Sym:good(other)  b,r=br(self,other); return b<=r and 0 or b^2/(b+r) end
function Sym:bad(other)   b,r=br(self,other); return r<=b and 0 or r^2/(b+r) end

function Sym:chop(other,out)
  local rule = Sym[the.rule]
  local t={}
  function _add(x,n,y) 
    t[x]=t[x] or Sym.new(self.at, self.txt); t[x]:add(y,n) end
  map(self.has,  function(_,x) _add(x, self.has[x], true) end)
  map(other.has, function(_,x) _add(x, self.has[x], false) end)
  for x1,one in pairs(t) do
    local others = Sym.new()
    for x2,other in pairs(t) do
      if x1 ~= x2 then 
        others = others:merge(other) end end
    local tmp = Sym[the.rule](one,others)
    if tmp > out[1] then out={tmp, out.at,"=",x1} end end
  return out end
```
----------------------------------------------------------
## Num

```lua
local Num=obj"Num"
function Num.new(c,s) 
  s = s or ""
  return isa(Num,{n=0,txt=s,at=c or 1, hi=-1E364,lo=1E64,has={},
                  w=s:find"+" and 1 or s:find"-" and -1 or 0}) end
```
Track the numerics seen so far, as well as the `lo,hi` values.

```lua
function Num:add(x,n)
  for _ = 1,n do self.has[1+#self.has] = x end
  self.lo = math.min(x,self.lo); self.hi = math.max(x,self.hi) end

function Num:norm(x)
  local lo,hi = self.lo,self.hi
  return math.abs(hi-lo)< 1E-16 and 0 or (x-lo)/(hi-lo) end

function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return math.abs(x-y) end

function Num:chop(other, out)
  local rule = Sym[the.rule]
  local t = {}
  local lo,hi=Sym.new(), Sym.new()
  function _add(x,y) hi:add(y); push(t, {x,y}) end 
  map(self.has,  function(_,x) _add(x,true) end )
  map(other.has, function(_,x) _add(x,false) end)
  local enough = (#t)^self.enough
  for i,xy in pairs(sort(t,first)) do
    local x,y,los,his
    x,y = xy[1], xy[2]
    lo:add(x)
    hi:add(y,-1)
    if i >= enough and #xys - i > enough then
      los=rule(lhs,rhs); if los>out[1] then out={los,out.at,"<=",x} end
      his=rule(rhs,lhs); if his>out[1] then out={his,out.at,">",x} end end end 
  return out end
```
----------------------------------------------------------
## Cols
`Cols` are initialized from the names in row1. e.g. Upper case
names are numeric, anything with `:` is skipped over (and all other columns
are symbolic. Columns have roles. 
- Some columns are goals to be minimized or maximized (those marked with a `+`,`-`);
- Some columns are goals to be predicted (marked with `!`);
- All the goals are dependent `y` variables;
- Anything that is not a goal is a dependent `x` variable.

```lua
local is={}
function is.ignore(s) return s:find":" end
function is.goal(s) return s:find"+" or s:find"-" or s:find"!" end
function is.num(s) return s:match"^[A-Z]" end
function is.what(s) 
  return is.ignore(s) and Skip or is.num(s) and Num or Sym end

local Cols=obj"Cols"
function Cols.new(t,      self,new)     
  self = isa(Cols,{names={},all={}, xs={}, ys={}})
  self.names = t
  for at,name in pairs(t) do
    new = is.what(name).new(at,name) 
    push(self.all, new)
    if not is.ignore(name) then
      push(is.goal(name) and self.ys or self.ys, new) end end 
  return self end
```
----------------------------------------------------------
## Sample

```lua
local Sample=obj"Sample"
function Sample.new(file,    self) 
  self= isa(Sample,{rows={},cols=nil})
  if file then for row in csv(file) do self:add(row) end end
  return self end
```
Row1 creates the column headers. All other rows update the summaries in the column headers.

```lua
function Sample:add(t,     adder)
  function adder(c,x) return add(self.cols.all[c],x) end
  if   not self.cols 
  then self.cols=Cols.new(t) 
  else push(self.rows, map(t, adder)) end end

function Sample:clone(inits)
  s=Sample.new({self.cols.names})
  for _,row in pairs(inits or {}) do s:add(row) end
  return s end
```
Find the best range to divide `self` from `other`. 

```lua
function Sample:chop(other)
  out = {-1}
  for i,col in pairs(self.cols.x) do out = col:chop(other.cols.x[i],out) end
  return out end

function Sample:dist(row1,row2)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, the.p
  for _,col in pairs(self.cols.xs) do
    x,y = row1[col.at], row2[col.at]
    inc = x=="?" and y=="?" and 1 or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end

function Sample:neighbors(row1,rows,    twins)
  function twins(_,row2) return {self:dist(row1,row2),row2} end 
  return sort(map(rows, twins), first) end

function Sample:far(row,rows,      all)
  all = self:neighbors(row, shuffle(rows, the.samples))
  return all[the.far*#all // 1].row end

function Sample:div(rows,left,         one,two,three,tmp,c,a,b,l,r)
  function x(a,b) return (a^2 + c^2 - b^2) / (2*c) end
  function d(a,b) return self:dist(a,b) end
  _,left  = _,left or self:far(any(rows), rows)
  c,right = self:far(left, rows)
  drows= map(rows,function(_,row) return {x(d(row,left), d(row,right)),row} end)
  lefts,rights = {},{}
  for i,drow in pairs(sort(drows,first)) do
    push(i<=#rows//2 and lefts or rights, drow[2]) end
  return left, right, lefts, rights end
```
Zitler's domination predicate.
theory note. Pareto frontier. No exact solution. Problem of g>2 goals.

```lua
function Sample:better(row1,row2)
  local e,w,s1,s2,n,a,b,what1,what2
  cols = self.cols.ys
  what1, what2, n, e = 0, 0, #cols, math.exp(1)
  for _,col in pairs(cols) do
    a     = col:norm(row1[col.at])
    b     = col:norm(row2[col.at])
    w     = col.w -- w = (1,-1) if (maximizing,m inimizing)
    what1 = what1 - e^(col.w * (a - b) / n)
    what2 = what2 - e^(col.w * (b - a) / n) end
  return what1 / n < what2 / n end

function Sample:betters(depth,     bests,rests,go)
  function go(rows, above, depth, enough)
    if   #rows < enough or depth  < 1
    then return rows
    else local left,right,lefts,rights = self:div(rows, above)
         if   self:better(left,right) 
         then left,right, lefts,rights = right,left,rights,lefts 
         end
         for _,bad in pairs(lefts) do rests[1+#rests] = bad end
         return go(rights, right, lvl-1,enough) end 
  end ----------
  rests = {}
  bests = go(self.rows, nil, depth or the.depth, 2*(#self.rows)^the.enough)
  return self:clone(bests), self:clone(top(#bests*3, shuffle(rests))) end
```
## Chops
Find best `Sym`bolic range
Find best `Num`eric range
function Sample:ytwo()
  local eval={}
  for i=1,the.eval do push(eval,any(self.rows)) end
  table.sort(eval, function(x,y) return self:better(x,y) end )
  best,rest = self:clone(), self:clone()
  for i=1,the.few do 
    row1=any(self.rows)
    where,d = 1,1E320
    for j,row2 in pairs(eval) do
      tmp = self:dist(row1,row2)
      if tmp<d then where,d = j, tmp end end
    push(where <= the.eval/2 and best or rest, row1) end 
  return best:chop(rest) end
   
  
```lua
      
```
-------------------------------------------------------------
## Lib
### The Usual Short-cuts

```lua
cat  = table.concat
fmt  = string.format
push = table.insert
sort = function(t,f) table.sort(t,f); return t end
```
### Update utilities

```lua
function adds(i,t) 
  for _,v in pairs(t or {}) do add(i,v) end; return i end
```
Skip any unknown cells. Otherwise, add one to the counter `n` and do the update.

```lua
function add(i,x,n) 
  n = n or 1
  if x~="?" then i.n = i.n + n; i:add(x,n) end; return x end
```
### Meta

```lua
function map(t,f,      u) 
  u={};for k,v in pairs(t) do u[k]=f(k,v) end; return u end

function keys(t,   ks)
  ks={}; for k,_ in pairs(t) do ks[1+#ks]=k end; return sort(ks) end

function isa(mt,t) return setmetatable(t, mt) end
```
### Lists
Return the first item in a list.

```lua
function first(t,u) return t[1] < u[1]  end
```
Return any item from a lost

```lua
function any(t)   return t[randi(#t)] end
```
Sort a list using a function `f`.
supplied, then return the  first `n` items.

```lua
function shuffle(t,n,    j)
  for i = #t,2,-1 do j=randi(1,i); t[i],t[j] = t[j],t[i] end
  return n and top(t, n) or t end
```
top n items

```lua
function top(t,n1,     u)
  n1 = math.min(n1, #t)
  u={}; for n2,x in pairs(t) do if n2<=n1 then u[1+#u]=x end end; return u end 
```
### Stats

```lua
function mu_sd(t,   tmp,mu,var)
  tmp=0; for _,x in pairs(t) do tmp=tmp+x        end; mu=tmp/#t
  tmp=0; for _,x in pairs(t) do tmp=tmp+(x-mu)^2 end; var=tmp/(#t-1)
  return mu,var^.5 end

function mode_ent(t)
  local n,e,max,mode = 0,0,-1,"?"
  for x,n1 in pairs(t) do n=n+n1; if n1>max then mode,max=x,n1 end end
  for _,n1 in pairs(t) do if n1>0 then e=e-n1/n*math.log(n1/n,2) end end
  return mode,e end
  ```
### Rand

```lua
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 
```
### Printing
colored strings

```lua
function red(s)    return the.bw and s or "\27[1m\27[31m"..s.."\27[0m" end
function green(s)  return the.bw and s or "\27[1m\27[32m"..s.."\27[0m" end
function yellow(s) return the.bw and s or "\27[1m\27[33m"..s.."\27[0m" end
function blue(s)   return the.bw and s or "\27[1m\27[36m"..s.."\27[0m" end
```
Print a generated string

```lua
function shout(x) print(out(x)) end
```
Generate a string, showing sorted keys, hiding secretes (keys starting with "_")

```lua

function out(t,         u,secret,brace,out1,show)
  function secret(s) return tostring(s):sub(1,1)== "_" end
  function brace(t)  return "{"..table.concat(t,", ").."}" end
  function out1(_,v) return out(v) end
  function show(_,v) return fmt(":%s %s", blue(v[1]), out(v[2])) end
  if     type(t)=="function" then return "#`()"
  elseif type(t)~="table"    then return tostring(t) 
  elseif #t>0                then return brace(map(t, out1),", ") 
  else   u={}
         for k,v in pairs(t) do if not secret(k) then u[1+#u] = {k,v} end end
         return yellow(t._is or "")..brace(map(sort(u,first), show)) end end
```
### Files

```lua
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
```
-------------------------------------------------------------
### Unit tests

```lua
local Eg, fails = {}, -1
local function go(x,     ok,msg) 
  the = about()
  Seed = the.seed 
  if the.wild then return Eg[x][2]() end
  ok, msg = pcall(Eg[x][2])
  if   ok 
  then print(green("PASS: "),x) 
  else print(red("FAIL: "),x,msg); fails=fails+1 end end
```
## Examples

```lua
Eg.ls={"list all examples", function () 
  print("\nKnown examples:\n")
  map(keys(Eg), function (_,k) 
    print("  lua ibc.lua",yellow(fmt("-t %-8s --",k)),Eg[k][1]) end) end}

Eg.all={"run all examples", function() 
  map(keys(Eg),function(_,k) 
                 return k ~= "all" and k ~= "ls" and go(k) end) end}

Eg.fail={"demo failure", function () assert(false,"oops") end}

Eg.config={"show options", function () shout(the) end}

Eg.map={"demo map", function( t) 
  t= map({10,20,30},function(n,x) return n*x end); assert(90 == t[3]) end}

Eg.keys={"demo keys", function( t) 
  assert("age"==keys({name="tim",age=21})[1]) end}

Eg.any={"demo any", function() assert(30==(any{10.20,30,40})) end}

Eg.randi={"demo rand", function(   t) 
  t={};for i = 1,30 do t[1+#t]=randi(0,4) end; print(cat(sort(t))) end}

Eg.num={"demo nums", function (    _,n,sd)
  n=adds(Num.new(),{10,20,30,40,50})
  _,sd=mu_sd(n.has)
  assert(math.abs(15.811-sd) < 0.01) end}

Eg.sym={"demo syms", function(      s,mode,ent)
  local s=Sym.new()
  for _,x in pairs{"a","a","a","a","b","b","c"} do add(s,x) end
  mode,ent = mode_ent(s.has)
  assert(math.abs(1.378- ent)<0.01)
  assert(mode=="a")
  print(s) end}

Eg.sample={"demo sample", function(     s)
  local s=Sample.new("../data/auto93.csv")
  assert(398 == #s.rows)
  assert(392 == s.cols.all[3].n) end}
```
-------------------------------------------------------------
## Start-up

```lua
go(about().todo) 
for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v)) end end 
os.exit(fails) 
```
