local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local function cli(flag,b4)
  for n,word in ipairs(arg) do if word==flag then return
    (b4==false and true) or tonumber(arg[n+1]) or arg[n+1] end end
  return b4 end 

-- ## Settings, CLI
local the = {
    bins= cli("-b", 12),
    data= cli("-d", "../data/auto93.csv"),
    help= cli("-h", false),
    seed= cli("-S", 937162211),
    todo= cli("-t", "ls"),
    wild= cli("-W", false) }

-- ## Short-cuts
local ee, abs,cat,fmt,push,same,sort
ee   = math.exp(1)
abs  = math.abs
cat  = table.concat
fmt  = string.format
push = table.insert
sort = function(t,f) table.sort(t,f); return t end

-- ## Lists
local keys,map
function map(t,f,  u) 
  u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 
function keys(t,   k) 
  k={}; for x,_ in pairs(t) do 
    if tostring(x):sub(1,1)~="_" then push(k,x) end end ; return sort(k) end

-- ## Printing
local out,shout
function shout(t) print(out(t)) end
function out(t,    u,f1,f2)
  if type(t) ~= "table" then return tostring(t) end
  function f1(_,x) return fmt(":%s %s",x,out(t[x])) end
  function f2(_,x) return out(x) end
  u=#t==0 and map(keys(t),f1) or map(t,f2)
  return (t._is or"").."{"..cat(u,", ").."}" end

-- ## Encapsulation, polymorphism
local isa,obj
function isa(mt,t)    return setmetatable(t, mt) end
function obj(is,   o) o={_is=is,__tostring=out}; o.__index=o; return o end

-- ## Files
local csv
function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if   tmp 
    then t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
         for y in string.gmatch(tmp, "([^,]+)") do push(t,y) end
         tmp = io.read()
         if  #t > 0
         then for j,x in pairs(t) do t[j] = tonumber(x) or x end
              return t end
    else io.close(stream) end end  end

local Bias=obj"Bias"
function Bias.new(lo,hi,bins)
  self = isa(Bias,{pending={},lo=lo or 0, n=0,v=0, hi=hi or 1, bins=bins or the.bins,has={}})
  local b4,after
  for i=1,bins do 
    lo = self.lo + (self.hi - self.lo)*(i-1)
    hi = self.lo + (self.hi - self.lo)*i
    now={b4=b4,lo=lo,hi=hi,v=0,n=0,first=i==1,last=i==bins} end end
    if i>1 then self.has[i-1].after = now end
    push(self.has, now)
    b4 = now end end

function Bias:add(k1,v1)
  self.v = self.v + v1
  self.n = self.n + 1
  for i,has1 in pairs(self.has) do
    if k1 >= has1.lo and k1<=has1.hi or has1.first and k1<has1.hi or has1.last and k1>has1.lothen
      has1.v = has1.v+v1
      has1.n = has1.n+1 
      if has1.n/self.n > 1.25/self.bins then self:redistribute() end
      
      break end end 


-- ------------------------------------------------------------
-- ## Classes
-- ### Things to Skip
local Skip=obj"Skip"
function Skip.new(at,txt) return isa(Skip,{at=at or 0, txt=txt or ""}) end
function Skip.add(v) return v end

-- ### Numbers  to track
local Num=obj"Num"
function Num.new(at,txt,     w)
  txt= txt or ""
  w=   txt:find"-" and -1 or 1
  return isa(Num,{n=0,w=w,at=at or 0,txt=txt,mu=0,lo=1E32,hi=-1E32}) end

function Num:add(v) 
  self.n = self.n+1
  if v > self.hi then self.hi = v end
  if v < self.lo then self.lo = v end 
  local d = v - self.mu
  self.mu = self.mu + d/self.n end

function Num:norm(v)
  return abs(self.lo-self.hi)<1E-16 and 0 or (v-self.lo)/(self.hi-self.lo) end

-- ### Symbols  to track
local Sym=obj"Sym"
function Sym.new(at,txt) 
  return isa(Sym,{at=at or 0, txt=txt or "",n=0,has={}}) end

function Sym:add(v) 
  self.n = self.n+1
  self.has[v] = 1 + (self.has[v] or 0) end

-- ### Store rows, tracking the column values.
local Sample=obj"Sample"
function Sample.new(inits,    self) 
  self = isa(Sample,{_rows={}, names={},cols={},goals={}}) 
  if type(inits)=="string" then for   x in csv(inits)   do self:add(x) end end
  if type(inits)=="table"  then for _,x in pairs(inits) do self:add(x) end end 
  return self end

function Sample:add(row,  header,keep)
  function header(k,v,     what) 
    what = (v:find":" and Skip) or (v:match("^[A-Z]") and Num) or Sym
    self.cols[k] = what.new(k,v)
    if v:find"+" or v:find"-" then push(self.goals,self.cols[k]) end 
    return v end 
  function keep(  k,v) 
    if v~="?" then self.cols[k]:add(v) end
    return v end
  -------------------
  if   #self.names==0 
  then self.names = map(row,header)
  else push(self._rows, map(row,keep)) end end

function Sample:clone(t,   s)
  s=Sample.new({self.names})
  for _,row in pairs(t or {}) do s:add(row) end
  return s end

function Sample:better(row1,row2)
  local a,b
  local what1, what2, n = 0, 0, #self.goals
  for _,col in pairs(self.goals) do
    a     = col:norm(row1[col.at])
    b     = col:norm(row2[col.at])
    what1 = what1 - ee^(col.w * (a - b) / n)
    what2 = what2 - ee^(col.w * (b - a) / n) end
  return what1 / n < what2 / n end

function Sample:betters()
  return sort(self._rows, function(x,y) return self:better(x,y) end) end

function Sample:ys(t) return map(self.goals, function(_,c) return t[c.at] end) end

local s=Sample.new(the.data)
shout(s)
local rows=s:betters()
for _,row  in pairs(rows) do shout(s:ys(row)) end

-- ## Start-up
for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v)) end end 
