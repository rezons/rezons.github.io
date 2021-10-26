local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local fu = require"fun"
local flag, obj, isa= fu.flag,fu.obj,fu.isa
local push, map     = fu.push,fu.map

--  Settings, CLI
local the = {
  bins= flag("-b", 12),
  data= flag("-d", "../data/auto93.csv"),
  seed= flag("-S", 937162211),
  wild= flag("-W", false) }

-- ### Things to Skip
local Skip=obj"Skip"
function Skip.new(at,txt) return isa(Skip,{at=at or 0, txt=txt or ""}) end
function Skip:add(v) return v end

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
  return fu.abs(self.lo-self.hi)<1E-16 and 0 or (v-self.lo)/(self.hi-self.lo) end

-- ### Symbols  to track
local Sym=obj"Sym"
function Sym.new(at,txt) 
  return isa(Sym,{at=at or 0,txt=txt or "",n=0,has={}}) end

function Sym:add(v) 
  self.n = self.n+1
  self.has[v] = 1 + (self.has[v] or 0) end

-- ### Store rows, tracking the column values.
local Sample=obj"Sample"
function Sample.new(inits,    self) 
  self = isa(Sample,{_rows={}, names={},cols={},goals={}}) 
  if type(inits)=="string" then for   x in fu.csv(inits)  do self:add(x) end end
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
  return fu.sort(self._rows, function(x,y) return self:better(x,y) end) end

function Sample:ys(t) return map(self.goals, function(_,c) return t[c.at] end) end

local Syms=obj"Syms"
function Syms.new(t,    self) 
  self= isa(Syms,{has={},n=0,mode="?",most=0}) 
  for x,n in pairs(t or {}) do self:add(x,n) end
  return self end 

function Syms:add(x,inc)  
  inc = inc or 1
  self.n = self.n + inc 
  self.has[x] = inc + (self.has[x] or 0)
  if self.has[x] > self.most then self.most,self.mode=self.has[x],x end  end

function Syms:any(     r)
  r = self.n * fu.rand()
  for x,n1 in pairs(self.has) do r=r-n1; if r <=0 then return x end end  
  return self.most end

-- 1 
-- 2 10
-- 3
-- 4 30
-- 5 20
-- 6
-- 7 40
-- 8

local Nums=obj"Nums"
function Nums.new(lo,hi,bins) 
  return isa(Nums,{lo=lo or 0, hi=hi or 1, bins=bins or 16, syms=Syms.new()}) end

function Nums:add(x,inc)
  self.syms:add(self:key(x),inc)  end

function Nums:key(x)
  assert(x>=self.lo, "too small")
  assert(x<=self.hi, "too big")
  return ((x - self.lo)/(self.hi -  self.lo) * self.bins // 1) end

function Num:guess()
  guess = {}
  t = out.syms.has
  noop = function(_,_) return noop end
  back = function(n,s) for i=1,n-1 do t[i] = s end; return noop end 
  keys = keys(t)
  k0=keys[#keys]; v0=t[k0]; for k=k0+1, self.bins do guess[k] = v0 end
  k0=keys[1]    ; v0=t[k0]; for k=1,    k0-1      do guess[k] = v0 end
  for _,k1 in pairs(keys) do
    if k1 > k0+1 then 
       interpolate(v0, t[k1], XXXX
  for i=1,self.bins do 
    t[i] = t[i] or 0
    if t[i] > 0 then last=t[i]; back=back(i,last) end
    j= i end
  for k = j,bins do t[k] = last end
  has  = self.syms.has
  keys = keys(has)
  inc  = (self.hi - self.lo)/self.bins
  j    = self.lo + inc/2
  b4   = nil
  while j< self.hi do
     push({b4=b4, 
    j = j + inc end end


function Nums:any(      bin)
  bin=self.syms:any()
  return self.lo + (bin + math.random())*(self.hi - self.lo)/self.bins end

local n=Nums.new(0,10,10)
local tmp={}
for i=1,10000 do push(tmp, 10*(math.random()^.5)//1) end
--for _,x in pairs(tmp) do print(x) end
for _,x in pairs(tmp) do n:add(x) end
for i=1,10000 do print(n:any()//1) end
--
-- b=Syms.new{bananas=10,apples=20,oranges=40}
-- for _ = 1,1000 do print(b:any()) end
--
-- ## Start-up
for k,v in pairs(_ENV) do if not b4[k] then print("? ",k,type(v)) end end 
