#!/usr/bin/env lua
-- Using just a few hints, learn what examples  in the data are better than most other examples.
-- 1. Given many unevaluated examples, find the mid-point of few evaluated examples.
-- 2. Prune everything below the mid.
-- 3. Repeat.
-- 4. Return the surviving best examples.
--
-- At start up, use the `todo` value to select, then run, one of the  `Todo` actions
-- (listed at end of file).
local the -- Global config. Built via `the = updateFromCommandLine(about.how)`
local about={
  what = "HINTS v1: semi-supervised multi-objective optimizer",
  when = "(c) 2021, Tim Menzies, unlicense.org",
  how  = {
    {"cohen", "-c", .2,                   "min stdev delta to be different"},
    {"enough","-e", .5,                   "stopping criteria"},
    {"few",   "-F", 64,                   "when clustering, how many examples define the topology"},
    {"file",  "-f", "../data/auto93.csv", "data file to load"},
    {"help",  "-h", false,                "show help"},
    {"more",  "-m", 3,                    "when learner, size(rest)=more*size(best)"},
    {"rank",  "-r", "plan",               "how to  score a range"},
    {"far",   "-R", .85,                  "max dist for samples"},
    {"some",  "-s", 4,                    "samples per generation"},
    {"seed",  "-S", 937162211,            "random number seed"},
    {"tactic","-t", "random",             "search tactic: random or sway"},
    {"todo",  "-do", "help",              "start-up action"},
    {"xways", "-x",  2,                   "train on one, test on x-1 "}
    }}

-- ## Functions

-- `b4` is  used at end-of-file to find rogue globals.
local b4={}; for k,v in pairs(_ENV) do b4[k]=v end 

-- ### Useful short cuts
local abs,log,cat,fmt,pop,push,sort,same --------------------------------------
abs  = math.abs
cat  = table.concat
fmt  = string.format
log  = math.log 
pop  = table.remove
push = table.insert
same = function(x,...) return x  end
sort = function(t,f) table.sort(t,f); return t end

-- ### Randoms
local Seed, randi, rand -------------------------------------------------------
Seed=937162211
-- Random ints
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
-- Random floats (defaults  0..1)
function rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 

-- ### Arrays
local firsts,map,keys,shuffle,copy,sum,bchop,top,any ----------------------------------

-- return  any item
function any(t) return t[randi(1,#t)] end

-- binary chop (assumes sorted lists)
function bchop(t,val,lt,      lo,hi,mid) 
  lt = lt or function(x,y) return x < y end
  lo,hi = 1,#t
  while lo <= hi do
    mid =(lo+hi) // 2
    if lt(t[mid],val) then lo=mid+1 else hi= mid-1 end end
  return math.min(lo,#t)  end

-- Shallow copy
function copy(t) return map(t, function(_,x) return x end) end

-- `firsts` is used for sorting {{score1,x1}, {score2,x2},...}
function firsts(x,y) return x[1] < y[1] end

-- Sorted table keys
function keys(t,  u) 
  u={};for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then push(u,k) end end
  return sort(u) end

-- Call `f(key,value)` on all items  in list.
function map(t,f,  u) u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 

-- Randomly sort in-place a list
function shuffle(t,    j)
  for i = #t,2,-1 do j=randi(1,i); t[i],t[j] = t[j],t[i] end
  return t end

-- Sum items in a list, optionally filtered via  `f`.
function sum(t,f,    n)
  n,f = 0,f or same
  for _,x in pairs(t) do n=n+f(x) end; return n end

-- top `n` items
function top(n,t,   u)
  u={}; for i,x in pairs(t) do u[#u+1]=x; if i>=n then break end end
  return u end

-- ### Command-line
-- At start-up, `the`  settings will come from `the = cli(about.how)`.
local function updateFromCommandLine(options,   u) ----------------------------
  u={}
  for _,t in pairs(options) do
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do if word==t[2] then
      u[t[1]] = (t[3]==false) and true or tonumber(arg[n+1]) or arg[n+1] end end end
  return u end

--  ### Printing
local shout,out,red,green,yellow,blue

-- Generate  a pretty-print string from a table (recursively).
function out(t,    u,f1,f2)
  function f1(_,x) return fmt(":%s %s",yellow(x),out(t[x])) end
  function f2(_,x) return out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u = #t==0 and map(keys(t),f1) or map(t,f2)
  return blue(t._is or"")..blue("{")..cat(u," ")..blue("}") end

-- Print a pretty-print string.
function shout(x) print(out(x)) end

function red(s)    return "\27[1m\27[31m"..s.."\27[0m" end
function green(s)  return "\27[1m\27[32m"..s.."\27[0m" end
function yellow(s) return "\27[1m\27[33m"..s.."\27[0m" end
function blue(s)   return "\27[1m\27[36m"..s.."\27[0m" end

-- ### CSV reading
local function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do push(t,y) end
      tmp = io.read()
      if  #t > 0 then return map(t, function(_,x) return tonumber(x) or x end) end
    else io.close(stream) end end end

-- ### Meta
local has,obj
-- Instance  creation
function has(mt,x) return setmetatable(x,mt) end
-- Object creation.
function obj(s, o) o={_is=s, __tostring=out}; o.__index=o; return o end

-- ## Classes
  
local Sym,Num,Skip,Cols,Sample,Score

Score={}
function Score.score(b,r,B,R) return Score[the.rank](b,r,B,R) end
function Score.plan(b,r,B,R) 
  n=1E-32; b,r = b/(n+B),r/(n+R); return b<r and 0 or b^2/(b+r) end
function Score.monitor(b,r,B,R) 
  n=1E-32; b,r = b/(n+B),r/(n+R); return r<b and 0 or r^2/(b+r) end
function Score.novel(b,r,B,R) 
  n=1E-32; b,r = b/(n+B),r/(n+R); return 1/(b+r) end

-- ###  Cols
-- `Cols` is a factory for turning  column names into their
-- rightful columns. Those names contain certain magic symbols.
local klassp,skipp,goalp,nump,ako,weight
function goalp(v)  return klassp(v)  or v:find"+" or v:find"-" end
function klassp(v) return v:find"!" end
function nump(v)   return v:match("^[A-Z]") end
function skipp(v)  return v:find":" end
function weight(v) return v:find"-" and -1 or v:find"+" and 1 or 0 end

-- New columns are either `Skip`s or `Num`s or `Sym`s.
-- New columns are always stored in `all` and
-- independent/dependent columns (that we are not `skipp`ing)
-- are stored  in `xs` or `ys` respectively.
Cols= obj"Cols" ---------------------------------------------------------------
function Cols.new(lst,       self,now,what)
  self = has(Cols, {header=lst,all={},xs={},ys={},klass=nil}) 
  for k,v in pairs(lst) do
    what = (skipp(v) and Skip) or (nump(v) and Num) or Sym 
    now = what.new(k,v)
    push(self.all, now)
    if not skipp(v) then 
      if klassp(v) then self.klass=now end
      push(goalp(v) and self.ys or self.xs, now) end end
  return self end

-- ### Sym
-- Columns for summarizing `Sym`bols.
-- Columns have a similar set of methods:   
-- 1. `add(x)` increments `self` with `x`;
-- 2. `dist(x,y)` between two items `x` and `y`;
-- 3. `mid()` returns the central tendency;
-- 4. `spread()` returns the variability around the `mid`.
Sym = obj"Sym" ----------------------------------------------------------------
function Sym.new(i,s) return has(Sym, {at=i,txt=s,n=0,seen={},mode=nil,most=0}) end
function Sym:add(x, inc)    
  if x=="?" then return x end; 
  inc = inc or 1
  self.n = self.n + inc
  self.seen[x] = inc + (self.seen[x] or 0) 
  if self.seen[x] > self.most then 
     self.most,self.mode = self.seen[x],x end end

function Sym:dist(x,y) return  x==y and 0 or 1 end
function Sym:fuse(other,   tmp)
  tmp = Sym.new()
  for x,inc in pairs(self.seen)  do tmp:add(x,inc) end
  for x,inc in pairs(other.seen) do tmp:add(x,inc) end
  return tmp end

-- return a fused `Sym` if  that combination is simpler than
-- its parts (i.e. if the expected value of the spread reduces).
function Sym:fused(other,  a,b,c)
  a,b,c = self, other, self:fuse(other)
  if c:spread() <= (a:spread()*a.n + b:spread()*b.n)/c.n then return c end end

function Sym:mid()     return self.mode end
function Sym:spread()  -- entropy
  return sum(self.seen, 
             function(n) return n<-0 and 0 or -n/self.n*log(n/self.n,2) end) end

function Sym:ranges(other,out,   r,B,R)
  B, R = self.n, other.n
  for x,b in pairs(self.seen) do
    r =  other.seen[x] or 0
    push(out, {col=self, lo=x, hi=x, val=Score.score(b,r,B,R)}) end end 

-- ### Num
-- Columns for sumamrizing numbers.
Num = obj"Num" ----------------------------------------------------------------
function Num.new(i,s) 
  return has(Num,{
    at=i,txt=s, n=0,_contents={}, lo=1E32,hi=-1E32, ok=false,w=weight(s)}) end

function Num:add(x) 
  if x=="?" then return x end
  self.n = self.n + 1
  if x>self.hi then self.hi=x end
  if x<self.lo then self.lo=x end
  push(self._contents, x)
  self.ok = false end -- note: the updated contents are no longer sorted

-- Ensure the contents are shorted; them return those concents.
function Num:all(x)
  if not self.ok then self.ok=true; table.sort(self._contents) end
  return self._contents end

-- If either of `x,y` is unknown, guess a value that maximizes the distance.
function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return abs(x-y) end

function Num:mid(    a) a=self:all(); return a[#a//2] end
function Num:norm(x,     lo,hi)
  lo,hi = self.lo,self.hi
  return abs(lo - hi)< 1E-16 and 0 or (x - lo)/(hi-lo) end

-- The standard deviation of a list of sorted numbers  is the
-- 90th - 10th percentile, divided by 2.56. Why? It is widely
-- know that &plusmn; 1 to 2 standard deviations is 66 to 95% 
-- of the probability. Well, it is also true that
-- &plusmn; is 1.28 is 90% of the mass which, to say that 
-- another way, one standard deviation is 2\*1.28 of &plusmn; 90%.
function Num:spread(   a,here) 
  a = self:all() 
  if #a < 2 then return 0 end
  function here(x) x=x*#a//1; return x < 1 and 1 or x>#a and #a or x end
  return (a[here(.9)] - a[here(.1)])/2.56 end

local bins
function Num:ranges(other,out,    xys,sd,b,r,B,R,lo,hi)
  xys,B,R = {}, self.n, other.n
  for _,x in pairs(self._contents)  do push(xys, {x,true})  end
  for _,x in pairs(other._contents) do push(xys, {x,false}) end
  sd = (self:spread() * self.n + other:spread() * other.n) / (self.n+other.n)
  lo = -math.huge
  for _,xy in pairs(bins(xys, (#xys)^the.enough, sd*the.cohen)) do
    b = xy.syms.seen(true)  or 0
    r = xy.syms.seen(false) or 0
    push(out, {col=self, lo=lo, hi=xy.hi, val=Score.score(b,r,B,R)}) 
    lo = xy.hi
  end 
  out[#out].hi = math.huge
end

-- Generate a new range when     
-- 1. there is enough left for at least one more range; and     
-- 2. the lo,hi delta in current range is not tiny; and    
-- 3. there are enough x values in this range; and   
-- 4. there is natural split here
-- Fuse adjacent ranges when:
-- 5. the combined class distribution of two adjacent ranges 
--    is just as simple as the parts.
function bins(xys, width, tiny)
  local now,out,x,y,prune
  function fuse(b4) --fuse adjacent ranges that don't change class distribution
    local j,tmp,n,a,b,fused
    j, n, tmp = 0, #b4, {}
    while j<n do
      j = j + 1
      a = b4[j]
      if j < n-1 then
        b = b4[j+1]
        fused = a.syms:fuse(b.syms)
        if fused then -- (5)
          j = j + 1 -- next time around, skip over b (and go on after that)
          a = {lo=a.lo, hi= b.hi, syms=fused} end end
      push(tmp,a)
    end
    return #tmp==#b4 and b4 or fuse(tmp) --if any fused, recurse to find more
  end 
  while width <4 and width<#xys/2 do width=1.2*width end --grow small widths
  x=xy[1][1]
  now = {lo=x, hi=x, syms=Sym.new()} 
  out = {now}
  for j,xy in sort(xys,firsts) do
    x,y = xy[1],xy[2]
    if j < #xys - enough then -- (1)
      if x ~= xys[j+1][1] then -- (2)
        if now.syms.n > width then -- (3)
          if now.hi - now.lo > tiny then -- (4)
            now = {lo=x, hi=x, syms=Sym.new()}
            push(out, now) end end end end
    now.hi = x 
    now.syms.add(y) end
  return fuse(out) end

-- ### Skip
-- Columns for data we are skipping over
Skip= obj"Skip" ---------------------------------------------------------------
function Skip.new(i,s) return has(Skip,{at=i,txt=s}) end
function Skip:add(x)   return x end
function Skip:mid()    return "?" end
function Skip:spread() return "?" end

-- ### Sample
-- A `Sample` of data stores `rows`, summarized into `Col`umns.
-- If `src` is provided, the use it for initialization.
Sample= obj"Sample" -----------------------------------------------------
function Sample.new(src,   self) 
  self = has(Sample, {rows={}, cols=nil}) 
  if type(src)=="string" then for   row in csv(src)   do self:add(row) end end
  if type(src)=="table"  then for _,row in pairs(src) do self:add(row) end end
  return self end 

-- If `self.cols` is missing, then `lst` is the row of column names.
-- Else, update the columns using the  data in `lst`.
function Sample:add(lst,   add)
  function add(k,v) self.cols.all[k]:add(v); return v; end  
  if   not self.cols -- then  `lst` is  the  header row
  then self.cols = Cols.new(lst) 
  else push(self.rows, map(lst,add)) end 
  return self end

-- The Zitler domination predicate. `Row1` is better
-- than `row2` if the average loss less moving from `row1` to `row2`
-- is less than the other way around. To see the loss to full effect,
-- raise any delta to some exponential power.
function Sample:better(row1,row2,cols)
  local n,a,b,s1,s2,e
  cols = cols or self.cols.ys
  e=2.71828
  s1, s2, n = 0, 0, #cols
  for _,col in pairs(cols) do
    a  = col:norm(row1[col.at]) --normalize to avoid explosion in exponentiation
    b  = col:norm(row2[col.at])
    s1 = s1 - e^(col.w * (a - b) / n)
    s2 = s2 - e^(col.w * (b - a) / n) end
  return s1 / n < s2 / n end

-- Sort on y-values (best ones come first).
function Sample:betters(rows) 
  return sort(rows or self.rows,function(x,y) return self:better(x,y) end) end

function Sample:bicluster(rows)
  local project,_,one,two,c,ones,twos,some
  function project(_,row,    a,b) 
    a,b = self:dist(row,one),self:dist(row,two)
    return {(a^2+c^2-b^2)/(2*c),row} 
  end ----
  some = top(the.few, shuffle(rows))
  _,one = self:far(any(rows), some) 
  c,two = self:far(one,         some)
  ones,twos = {},{}
  for i,tmp in pairs(sort(map(rows,project),firsts)) do 
    push(i<=#rows//2 and ones or twos, tmp[2]) end
  return one, two, ones, twos end

-- Return a new `Sample` with the same structure as this one.
function Sample:clone(inits,   tmp)
  tmp = Sample.new():add( self.cols.header )
  map(inits or {}, function(_,row) tmp:add(row) end)
  return tmp end

function Sample:clusters(           go,leaves,_)
  function go(rows,    ones,twos)
    if   #rows < 2*(#self.rows)^the.enough
    then push(leaves,rows)
    else _,_,ones,twos = self:bicluster(rows)
         go(ones)
         go(twos) end end
  leaves={}
  go(self.rows)
  return leaves end

function Sample:diff(row1,row2, xy,     col2,sd)
  xy = xy or "ys"
  for i,col in pairs(self.cols[xy]) do
    if abs(row1[col.at] - row2[col.at]) >= col:spread()*the.cohen then
      return true end end
  return false end

-- Distance.
function Sample:dist(row1,row2)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, 2
  for _,col in pairs(self.cols.xs) do
    x,y = row1[col.at], row2[col.at]
    inc = (x=="?" and y=="?" and 1) or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end

-- And finally, we can do the inference.
function Sample:div()
  local function want(somes,row)
    local closest,rowRank,tmp = 1E32,1E32,nil
    for someRank,some1 in pairs(somes) do
       tmp = self:dist(row,some1)
       if tmp < closest then closest,rowRank = tmp,someRank end end
    return {rowRank,row} 
  end ------------------------------------
  local function go(rows,evals,rest,      somes)
    if #rows < 2*(#self.rows)^the.enough or #rows < 2*the.some then 
      return evals,self:clone(rows):betters(rows),rest end
    somes={}
    for i = 1,the.some do 
      evals = evals+1
      push(somes,pop(rows)) end
    local best,somes = {}, self:betters(somes)
    rows = sort(map(rows, function(_,row) return want(somes,row) end), 
                firsts )
    for k,v in pairs(rows) do 
      if k <= #rows/2 then push(best, v[2]) else push(rest,v[2]) end end
    return go(best, evals,rest) 
  end
  return go(shuffle(copy(self.rows)),0,{}) end

-- return something `far` from `row`.
function Sample:far(row,rows,     all,one)
  all = self:neighbors(row, rows) 
  one = all[the.far * #all // 1]
  return one[1], one[2] end

-- The central tendency of a `Sample`'s dependent variables.
function Sample:goals() return self:mid(self.cols.ys) end

-- The central tendency of a `Sample` comes fro its columns.
function Sample:mid(  cols) 
  return map(cols or self.cols.all, function(k,x)  return x:mid() end) end

-- Distance to everything around `row1`.
function Sample:neighbors(row1,rows,       dist)
  function dist(_,row2) return {self:dist(row1,row2),row2} end
  return sort(map(rows or self.rows, dist), firsts) end

-- Recursively throw away worse half of data.
function Sample:optimize(    go,bests,rests)
  function go(rows, worsts,       one,two,ones,twos)
    for _,rest in pairs(worsts) do push(rests,rest) end
    if   #rows < 2*(#self.rows)^the.enough
    then return rows
    else one,two,ones,twos = self:bicluster(rows) 
         evals = evals + 2
         return self:better(one,two) and go(ones,twos) or go(twos,ones) end end 
  evals, rests = 0,{}
  bests = go(self.rows,{}) --at start, 2nd arg empty (nothing is worsts, yet)
  return evals, bests, top(the.more*#bests, shuffle(rests)) end-- all of best, some of rest

-- The spread of a `sample` comes fro its columns.
function Sample:spread(   cols) 
  return map(cols or self.cols.all, function(_,x) return x:spread() end) end

-- ## Rules
local function rules(structure,lst,     best,rest,ranges)
  best = structure:clone()
  rest = structure:clone()
  for i,one in pairs(lst) do (i<=10 and best or rest):add(one) end
  ranges = {}
  for i,col0 in pairs(best.cols.xs) do
    col1 = rest.cols.xs[i]
    col0:ranges(col1,ranges) end
  for _,row in pairs(sort(ranges,
                          function(x,y) return x.score < y.score end)) do
    shout(row) end end

-- ## Main
local Main={}
Main.worker={}

function Main.worker.sway(s) return s:optimize() end
function Main.worker.random(s) return s:div() end
function Main.runs(file,n,     x) 
  for i=1,(n or 20) do x=Main.run(file,the.tactic) end 
  shout(x) end

function Main.run(file,fun)
  local rows,evals,s,train,test,testrows,rest
  local lt=function(x,y) return s:better(x,y) end
  s = Sample.new(the.file)
  train,test= s:clone(), s:clone()
  for i,row in pairs(shuffle(s.rows)) do
    if i % the.xways == 0  then train:add(row) else test:add(row) end end
  local evals,suggestions,_ = Main.worker[fun](train)
  --rules(s,suggestions)
  local report = {train=#train.rows, xways=the.xways, test=#test.rows, evals=evals}
  testrows=test:betters()
  local tmp={}
  for i=1,#suggestions do
    if  i==1 or i==5 or i==10 or i==20 or i==40 or i==#suggestions or i==(#suggestions)//2 then
      local suggestion = suggestions[i]
      local rank=bchop(testrows,suggestion,lt); 
      push(tmp, fmt(" %6.2f ",100*rank/#testrows ))   end end
  print(out(tmp),out(report))
  return map({1,5,10,20,40,#suggestions//2,#suggestions},
            function(_,x) return fmt(" %6s ",x) end)
  end

-- ## Stuff `Todo` at Start-up
local Todo={} ------------------------------------------------------------------
Todo.optimize={"optimize", function(      s,best,rest)
  the.file="../data/auto93.csv"
  s = Sample.new(the.file)
  best, rest = s:optimize() 
  shout(s:clone(best):goals())
  shout(s:clone(rest):goals())
  end }

Todo.cluster={"clustering", function (s)
  the.file="../data/auto93.csv"
  s = Sample.new(the.file)
  for _,rows in pairs(s:clusters()) do
    shout(s:clone(rows):goals()) end end}
  
Todo.help={"print help", 
  function ()
    print(fmt("lua hints.lua [%s] -do [%s]\n",red("OPTIONS"),red("ACTION")))
    print(yellow(about.what))
    print(yellow(about.when),red("\n\nOPTIONS:"));
    for _,t in pairs(about.how) do if t[1] ~= "todo" then
      print(fmt("  %-4s%-20s %s",
                t[2], t[3]==false and "" or t[3], t[4])) end end
    print(red("\nACTIONS:"))
    for _,k in pairs(keys(Todo)) do
      print(fmt("  -do %-21s%s",k, Todo[k][1])) end end}

Todo.search ={"runs",  function(x) Main.runs() end}

Todo.rules={"run rules",function()
  end}

Todo.auto93={"run auto93", function(     s,t,u)
  function stats(n,s,      show)
    function show(n,t) 
      return map(t,function(_,x) return fmt(" %8.3f ",x*n) end)  end 
    print(n, #s.rows, 
             out(show(1,s:mid(s.cols.ys))), 
             out(show(the.cohen, s:spread(s.cols.ys)))) 
  end -----
  the.file="../data/auto93.csv"
  s = Sample.new(the.file)
  stats(0,s)
  shout(s.cols)
  for _=1,20 do
    t = Sample.new(the.file)
    local evals,rows = t:div()
    u = t:clone( rows )  
    stats(evals,t:clone(rows)) end end}


the  = updateFromCommandLine(about.how)
Seed = the.seed
Todo[the.todo][2]()

-- Check for rogue globals.
for k,v in pairs(_ENV) do if not b4[k] then print("? ",k,type(v)) end end
