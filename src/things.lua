local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
require"fun"
print("ee",ee)
local the
local Sym,Num,Sample, Nums, Syms,Skip,Skips

local function options() return { 
  {"bins", "-b", 12,                   "number of bins"},
  {"data", "-d", "../data/auto93.csv", "disk-based data"},
  {"some", "-s", 6,                    "sample size"},
  {"seed", "-S", 937162211,            "random number seed"},
  {"todo", "-t", "help",               "start-up action"},
  {"wild", "-W", false,                "run  in  wild mode"}} end

-- ### Things to Skip
Skip=obj"Skip"
function Skip.new(at,txt) return isa(Skip,{at=at or 0, txt=txt or ""}) end
function Skip:add(v) return v end
function Skip:counter() return Skips.new() end

-- ### Numbers  to track
Num=obj"Num"
function Num.new(at,txt,     w)
  txt= txt or ""
  w=   txt:find"-" and -1 or 1
  return isa(Num,{n=0,w=w,at=at or 0,txt=txt,mu=0,lo=1E32,hi=-1E32}) end

function Num:counter() return Nums.new() end

function Num:add(v,    d) 
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
  return isa(Sym,{at=at or 0,txt=txt or "",n=0,has={}}) end

function Sym:add(v) 
  self.n = self.n+1
  self.has[v] = 1 + (self.has[v] or 0) end

function Sym:counter() return Syms.new() end

-- ### Store rows, tracking the column values.
Sample=obj"Sample"
function Sample.new(inits,    self) 
  self = isa(Sample,{_rows={}, names={},cols={},goals={}}) 
  if type(inits)=="string" then for   x in csv(inits)  do self:add(x) end end
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

function Sample:better(row1,row2,      a,b)
  local s1, s2, n = 0, 0, #self.goals
  for _,col in pairs(self.goals) do
    a     = col:norm(row1[col.at])
    b     = col:norm(row2[col.at])
    s1 = s1 - ee^(col.w * (a - b) / n)
    s2 = s2 - ee^(col.w * (b - a) / n) end
  return s1 / n < s2 / n end

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

function Syms:any(    r)
  r = self.n * rand()
  for x,n1 in pairs(self.has) do r=r-n1; if r <=0 then return x end end  
  return self.most end

Nums=obj"Nums"
function Nums.new(lo,hi,bins) 
  return isa(Nums,{lo=lo or 0, hi=hi or 1, bins=bins or 16, syms=Syms.new()}) end

function Nums:add(x,inc)
  self.syms:add(self:key(x),inc)  end

function Nums:key(x)
  assert(x>=self.lo, "too small")
  assert(x<=self.hi, "too big")
  return ((x - self.lo)/(self.hi -  self.lo) * self.bins // 1) end

function Nums:any(      bin)
  bin=self.syms:any()
  return self.lo + (bin + rand())*(self.hi - self.lo)/self.bins end

Skips=obj"Skips"
function Skips.new(...) return isa(Skip,{}) end
function Skips:add(...) return 1 end

local function guess(t,max,  u,ks,d1,d2,hi,lo)
  u = {}
  ks= keys(t)
  lo,hi = ks[1], ks[#ks]
  for i = 1,  lo-1 do u[i] = t[lo] end
  for i = hi+1,max do u[i] = t[hi] end
  lo    = ks[1]
  for _,hi in pairs(ks) do
    u[hi] = t[hi]
    for i= lo+1,hi-1 do
      d1, d2 = i-lo, hi-i 
      u[i]   = (t[lo]/d1 + t[hi]/d2)/(1/d1 + 1/d2) end
    lo = hi end
  return u end

local function main(     s,on,score,some,keep)
  s=Sample.new(the.data)
  some = s:betters(top(the.some, shuffle(s._rows)))
  keep = map(s.cols, function(_,v) return v:counter() end)
  for n,row in pairs(keep) do 
    for k,v in pairs(row) do 
      print(n,k,v) end end
  -- for  i,one in paris(some) do
  --   local score = (#some +1 - i)/(#some)
  --   for col,some in pairs(keep) do some:add(one[col.at],score) end
  -- end
end

-----------------
local Eg={}
function run(k,  ok,msg,fun)
  the = cli(options())
  k = k or the.todo
  Seed = the.seed
  fun = Eg[k][2]
  if the.wild then return fun() end
  ok,msg = pcall(fun)
  if ok 
  then print(green("✔ "..k)) 
  else print(red("✘ "..k), msg) end end

Eg.all={"all",function(    t) 
  for _,k in pairs(keys(Eg)) do if k~="all" then run(k) end end end}

Eg.fail={"oops",function()  assert(fail,"ooops") end}

Eg.main={"main function",main}

Eg.sample={"read data from disk",function(    t) 
  shout(Sample.new(the.data).cols) end }

Eg.guess={"fil in the table",function(    t)
  t = {[3]=10,[5]=20,[6]=15,[10]=10,[11]=10,[16]=5}
  for k,v in pairs(guess(t,20)) do print(k,t[k] or 0, v) end 
  print("")
  t = {[3]=10,[4]=10,[5]=10,[15]=20}
  for k,v in pairs(guess(t,20)) do print(k,t[k] or 0, v) end 
  end}

Eg.show={"show options",function()  shout(the) end}

Eg.help={"show help",function() 
  help("lua notbad.lua",options())
  print(gray("\nACTIONS:"))
  map(keys(Eg),function(_,k) print(fmt("  -t  %-20s %s",blue(k),Eg[k][1]))end) end}

Eg.num={"reproduce a distribtion", function(r,n,tmp,sym1,sym2)
  n=Nums.new(0,10,10)
  tmp={}
  r=10^5
  for i=1,r do push(tmp, 10*(rand()^.5)//1) end
  for _,x in pairs(tmp) do n:add(x) end
  sym1=Sym.new()
  for _,x in pairs(tmp) do  sym1:add(x //1) end
  sym2=Sym.new()
  for i=1,r do sym2:add(n:any()//1) end
  for _,k in pairs(keys(sym2.has)) do print(k,sym1.has[k]/ sym2.has[k]) end end}

-- ## Start-up
run()
for k,v in pairs(_ENV) do if not b4[k] then 
  if type(v)~="function" then 
    if k~="Seed" then 
      print("? ",k,type(v)) end end  end end
