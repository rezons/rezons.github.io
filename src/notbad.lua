local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local the,Skip, Num,Sym,Sample, Syms,Nyms
local ee, abs,cat,fmt,push,same,sort, keys,map,out,shout,csv 
local function obj(is,  o) o={_is=is,__tostring=out}; o.__index=o; return o end
local function atom(b4,s) return (b4==false and true) or tonumber(s) or s end
local function flag(it,b4) for n,s in ipairs(arg) do if s==it then return atom(b4,arg[n+1]) end end end

--  Settings, CLI
the = {
  bins= flag("-b", 12),
  data= flag("-d", "../data/auto93.csv"),
  help= flag("-h", false),
  seed= flag("-S", 937162211),
  todo= flag("-t", "ls"),
  wild= flag("-W", false) }

-- ### Things to Skip

Skip=obj"Skip"
function Skip.new(at,txt) return isa(Skip,{at=at or 0, txt=txt or ""}) end
function Skip:add(v) return v end

-- ### Numbers  to track
Num=obj"Num"
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
Sym=obj"Sym"
function Sym.new(at,txt) 
  return isa(Sym,{at=at or 0, txt=txt or "",n=0,has={}}) end

function Sym:add(v) 
  self.n = self.n+1
  self.has[v] = 1 + (self.has[v] or 0) end

-- ### Store rows, tracking the column values.
Sample=obj"Sample"
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

function Sample:better(row1,row2,      a,b,what1,what2,n)
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

Syms=obj"Syms"
function Syms.new(t,    self) 
  self= isa(Syms,{has={},n=0,mode="?",most=0}) 
  for x,n in pairs(t or {}) do self:add(x,n) end
  return self end 
function Syms:add(x,inc)  
  inc = inc or 1
  self.n = self.n + inc 
  self.has[x] = inc + (self.has[x] or 0)
  if self.has[x] > self.most then self.most,self.mode=self.has[x],x end  end
function Syms:any()
  local r=math.random(self.n)
  for x,n1 in pairs(self.has) do r=r-n1; if r <=0 then return x end end  
  return self.most end

Nums=obj"Nums"
function Nums.new(lo,hi,bins) 
  return isa(Nums,{lo=lo or 0, hi=hi or 1, bins=bins or 16, syms=Syms.new()}) end
function Nums:add(x,inc,    y)
  assert(x>=self.lo,"too small")
  assert(x<=self.hi,"too big")
  y = ((x - self.lo)/(self.hi -  self.lo) * self.bins // 1)
  self.syms:add(y,inc)  end
function Nums:any(      bin)
  bin=self.syms:any()
  return self.lo + (bin + math.random())*(self.hi - self.lo)/self.bins end

-----------------------------------------------
--  Short-cuts
ee   = math.exp(1)
abs  = math.abs
cat  = table.concat
fmt  = string.format
push = table.insert
sort = function(t,f) table.sort(t,f); return t end
isa  = function(mt,t) return setmetatable(t, mt) end

--  Lists
function map(t,f,  u) 
  u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 
function keys(t,   k) 
  k={}; for x,_ in pairs(t) do 
    if tostring(x):sub(1,1)~="_" then push(k,x) end end ; return sort(k) end

-- ## Printing
function shout(t) print(out(t)) end
function out(t,    u,f1,f2)
  if type(t) ~= "table" then return tostring(t) end
  function f1(_,x) return fmt(":%s %s",x,out(t[x])) end
  function f2(_,x) return out(x) end
  u=#t==0 and map(keys(t),f1) or map(t,f2)
  return (t._is or"").."{"..cat(u,", ").."}" end


--  Files
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

local  n=Nums.new(0,10,10)
tmp={}
for i=1,100000 do push(tmp, 10*(math.random()^.5)//1) end
--for _,x in pairs(tmp) do print(x) end
for _,x in pairs(tmp) do n:add(x) end
for i=1,100000 do x=n:any()//1 end

-- b=Syms.new{bananas=10,apples=20,oranges=40}
-- for _ = 1,1000 do print(b:any()) end
--
-- ## Start-up
for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v)) end end 
