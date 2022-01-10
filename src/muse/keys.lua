-- Keys is a ["DUO" algorithm](https://arxiv.org/abs/1812.01550)
-- (data mining using/used by optimizers) that seeks to learn the
-- most it can about some  model `y=f(x)`, while at the same time, asking the fewest
-- questions about `x` or `y`.  
--  
-- Keys assumes the presence of ["keys"](http://menzies.us/pdf/07strange.pdf)
-- in the data;
-- i.e. a small set of variables which, if set, greatly reduces the variance of
-- the rest of the system. For such systems, inference and explanation and control
-- is a simple matter of (a) random sampling; (b) then focusing on a few variables that
-- are most different in the sample,
--  
-- In Keys, examples are divided in two (on their `x` value) then
-- discretion seeks the attribute range that best distinguishes that division. Data is split
-- on that range and the process repeats recursively to return a binary decision tree that
-- queries one attribute range per split.  If called with the `-best` flag, Keys evaluates
-- two distant examples per split, pruning the split with the worst example (so N examples
-- can be pruned after a small (log(N)) number of examples.
-- 
-- Keys divides its data using recursive [FASTMAP random
-- projections](https://dl.acm.org/doi/10.1145/568271.223812).  Different to most classifiers
-- or regression algorithms, Keys allows ranks examples on a multi-objective criteria using
-- [Zitler's IBEA](https://www.simonkuenzli.ch/docs/ZK04.pdf) predicate (which is known to be
-- effective for 
-- [multi- to many- goals](https://fada.birzeit.edu/bitstream/20.500.11889/4528/1/dcb6eddbdac1c26b605ce3dff62e27167848.pdf).
-- Also, except for the handful of `y` queries used by the optional  `-best` flag, this is an
-- [unsupervised algorithm](https://raw.githubusercontent.com/nzjohng/publications/master/papers/jss2020.pdf).
-- Keys can be used  when example labels are suspect since, even if called with `-best`,
-- humans only have to check a very small number of labels (in this way, Keys is like a
-- semi-supervised learner that takes most advantage of a very small number of labels).
-- 
-- Other applications of Keys include [explaining](https://arxiv.org/pdf/2006.00093.pdf)
-- complex models (in a succinct manner). Unlike other explanation that discuss the impact of
-- single variables on a class, Keys offers explanations for combinations of multiple
-- factors that influence multiple goals.  Keys can also optimize any simulation process
-- here is to expensive to evaluate too many examples. Further,for [interactive search-based
-- software engineering](https://arxiv.org/pdf/2110.02922.pdf), Keys lets a human work with
-- an AI, without the human being overwhelmed by too many questions.
--   
local MINE={b4={}, help=[[

lua keys.lua  [OPTIONS]
keys v4β Optimizes N items using just O(log(N)) evaluations.
(c)2022, Tim Menzies <timm@ieee.org>, unlicense.org

OPTIONS:
  -best      Recurse on just best half      : false
  -Debug     on error, dump stack and exit  : false
  -dull   F  small effect= stdev*dull       : .35
  -Far    F  where to find far things       : .9
  -file   S  read data from file : ../../data/auto93.csv
  -goal   S  smile,frown,xplor,doubt,div    : smile
  -h         show help                      : false
  -p      I  distance coefficient           : 2
  -Rest   F  size of rest set is Rest*best  : 4
  -round  I  round floats to round places : 2
  -seed   I  random number seed             : 10019
  -Small  F  splits at #t^Small             : .5
  -todo   S  start-up action                : pass
             -todo ALL = run all
             -todo LS  = list all
  -verbose   show details                   : false
]]}  
for k,_ in pairs(_ENV) do MINE.b4[k]=k end
-- ## Namespace

-- ### Classes
-- Our class print themselves with the `o` function, 
-- and delegate methods to `klass` and 
-- set the creation method `XX(..)` to be `XX.new(...)`.
local function klass(s, klass)
  klass = {_is=s, __tostring=o}; 
  klass.__index = klass
  return setmetatable(klass,{__call=function(_,...) return klass.new(...) end}) end

-- A `SAMPLE` holds many `EG`s.
local EG, SAMPLE = klass"EG", klass"SAMPLE"
-- RANGEs highlight the difference between to SAMPLEs
local RANGE = klass"RANGE"
-- Example columns are either  `NUM`eric or  `SYM`bolic  or black holes (for data we want to `SKIP`).
local NUM, SYM, SKIP  = klass"NUM", klass"SYM", klass"SKIP"

-- ### Globals
-- Internal options (not controlled by command-line).
MINE.go    = {} -- where to store demos/tests
MINE.nogo  = {} -- where to store disabled demos/tests
MINE.oid   = 0  -- object id counter
MINE.fails = 0  -- counter for runtime errors

-- Config options, set from `MY` help string via   
-- `YOUR = options(MINE.help)`
local YOUR = {}  
-- ### Misc functions
local coerce, options                     -- make config options
local push,firsts,sort,map,slots,copy     -- table stuff
local csv,green,yellow,rnd,rnds,fmt,say,o -- Print Stuff
local rand,randi,any,many,shuffle         -- Random stuff
local xpect                               -- Misc stuff
local ako, new                            -- OO stuff
local main, azzert                        -- Start-up and main stuff

-- ## RANGE
-- **RANGE.new(col:NUM|SYM, lo:num, hi?:num, has:SYM)**  
-- Create a new range. If called without `hi` then `lo` is set to `hi`
-- (which is useful if this is a `range` for some discrete variables).
function RANGE.new(col,lo,hi,has)
  return new(RANGE,{col=col, lo=lo, hi=hi or col, has=has or SYM()}) end

-- ## SAMPLE
-- SAMPLEs are tools that:
-- (a) know the structure of the examples  (e.g.. which columns
-- are numbers, which are discrete, which are dependent
-- (the `ys` columns), and which are independent (the `xs` columns);     
-- (b) store examples;       
-- (c) summarize the columns of those examples;     
-- (d) cluster the examples into two groups;    
-- (e) contrast the two halves as a set of ranges on all the columns.
--     
-- These contrasts are modeled as `ranges`; i.e. tuples
-- that ranges from `lo` to `hi;
-- For discrete data, the `lo` is the same as `hi` while for
-- numeric data, those boundaries are numeric.
-- SAMPLEs recursively cluster the data by finding the best range
-- that distinguishes the two clusters. All the data that matches
-- that range becomes one branch, and everything else goes into the
-- other branch.

-- ### Creation

-- **SAMPLE.new(inits? :str|list) :SAMPLE**    
-- When creating a new SAMPLE, if `inits` is a string, then read
-- its contents from that file name. Else, if `inits` is a list,
-- the read the rows from that list.
function SAMPLE.new(inits,   i) 
  i= new(SAMPLE, {head=nil,egs={},all={},xs={},ys={}}) 
  if type(inits)=="table"  then for _,eg in pairs(inits) do i:add(eg) end end
  if type(inits)=="string" then for eg in csv(inits)   do i:add(eg) end end 
  return i end

-- **SAMPLE:clone(inits? :str|list) :SAMPLE**    
-- Return a SAMPLE with the same structure, perhaps 
-- initialized with data rows from `inits`.
function SAMPLE.clone(i,inits,    j)
  j= SAMPLE():add(i.head)
  for _,x in pairs(inits or {}) do  j:add(x) end
  return j end

-- ### Cluster and Contrast
-- When we recurse, each sub-cluster will become its own SAMPLE.
-- As we recurse, we will be looking at examples that are 
-- become increasingly close and hence increasingly indistinguishable.  
-- So if ever we do something to test for termination, we do not
-- use the local SAMPLE (since there is little there to show differences).
-- Instead, we use the `top` most SAMPLE.
--

-- **i:SAMPLE:cluster()**  
-- Divide the examples by 
-- projecting all examples onto a line drawn between two
-- distant examples, called `one` and `two` (which are separated by distance `c`).
-- For an example with  distance `a,b` to `one,two`,
-- this is projected to some distance `x=(a^2+c^2-b^2)/2c` 
-- between `one` and `two`. This code   
-- [1] find the `one,two` distant points;
-- [2] projects everyone else onto a line between those points
-- [3] sorts everyone according to that distance;
-- [4] divides at the median point.
-- [5] return data, divided in two.   
function SAMPLE.cluster(i)
  local zero,one,two,ones,twos,both,a,b,c 
  zero  = any(i.egs)
  one   = i:far(zero, i.egs) -- [1] pick "any" then "one" is far from "any"
  two,c = i:far(one,  i.egs) -- [1] "two" is far from "one"
  ones,twos = {},{}  -- "ones","twos" are things closest to "one","two"
  both = {}          -- "both" is a list of pairs {"x","eg"}
  for _,eg in pairs(i.egs) do
    a    = eg:dist(one,i)
    b    = eg:dist(two,i)
    push(both, {(a^2 + c^2 - b^2) / (2*c),  -- [2] first: the "x" distance
                eg}                         --     second: the actual example
        ) end
  for n,pair in pairs(sort(both, firsts)) do         -- [3]
    push(n <= #both//2 and ones or twos, pair[2]) end-- [4] node: uses pair[2] 
  return ones, twos end                              -- [5]

-- **SAMPLE:far(eg1: EG, egs: list of EG) :EG,num**      
function SAMPLE.far(i,eg1,egs,    gap,tmp)
  gap = function(eg2) return {eg2, eg1:dist(eg2,i)} end
  tmp = sort(map(egs, gap), function(a,b) return a[2] < b[2] end)
  return table.unpack(tmp[#tmp*YOUR.Far//1] ) end

-- **SAMPLE:contrast()**    
-- Find two clusters then, using the columns from each cluster, find
-- the ranges that most distinguish them. Recurse  on each half. If `-best` is
-- set, only recurse on the best half. 
-- To handle the "increasingly close" issue (described above), when 
-- splitting the data, use the `top` SAMPLE.
function SAMPLE.contrast(i,     top,lvl,pre)
  lvl, top = lvl or 0, top or i
  if #i.egs < 2*(#top.egs)^YOUR.Small then return i end
  local best, rest = top:cluster(i.egs)
  best, rest = i:clone(best), i:clone(rest)
  local ranges = {}
  for n,bestx in pairs(best.xs) do 
    push(ranges, bestx:ranges(rest.xs[n])) end
  ranges = sort(ranges,first)[1]
  print(fmt("%s %-20s%4s : %s", 
                        o(rnds(i:stats(i.ys),0 )),
                        string.rep("|.. ",lvl), 
                        #i.egs, pre or ""))
  pre = range.lo == range.hi and fmt("%s",range.lo) or fmt("(%s..%s)",range.lo,range.hi)
  pre = fmt("%s = %s", range.col.txt, pre)
  local left, right = i:clone(), i:clone()
  for _,eg in pairs(i.egs) do
     local x = eg.has[ range.col.at ]
     if     x=="?"                 then left:add(eg); right:add(eg) 
     elseif range.lo<=x and x<range.hi then left:add(eg) 
     else                               right:add(eg) end end 
  if #left.egs  < #i.egs then left:contrast( top, lvl+1,"if ".. pre) end
  if #right.egs < #i.egs then right:contrast(top, lvl+1,"if not "..pre) end
  end

-- ### Update 

-- The first row of data has names that can take on various roles.

-- **SAMPLE:add(eg): SAMPLE**   
-- If this is row1, there is not `head`, so create the column types.
-- All the columns are stored in `all` and all the ones we are not
-- ignoring are in `xs` (for the independent columns) and `ys` (for the
-- dependent columns).
function SAMPLE.add(i,eg,    now,skip,nump,goalp)
  skip  = function(x) return x:find":" end              
  nump  = function(x) return x:find"^[A-Z]" end        
  goalp = function(x) return x:find"-" or x:find"+" end
  eg = eg.has and eg.has or eg    -- If data is buried inside, the expose it.
  if not i.head then              -- First row. Create the right columns
    i.head = eg
    for n,s in pairs(eg) do 
      now = (skip(s) and SKIP or nump(s) and NUM or SYM)(n,s)
      push(i.all, now)
      if not skip(s) then 
        push(goalp(s) and i.ys or i.xs, now) end end 
  else                            -- ever non-first row
    push(i.egs, EG(eg))           -- add a new example
    for n,one in pairs(i.all) do  
      one:add(eg[one.at]) end end -- update the columns with the eg data
  return i end


-- **:stats(cols: list): list**  
-- Return expected value of `cols` (defaults to `i.all`).
function SAMPLE.stats(i, cols) 
  return map(cols or i.all, function(x) return x:mid() end) end
  
-- ## EG
-- SAMPLEs store individual EGs (examples).
function EG.new(t) return new(EG, {klass=0,has=t}) end

function EG.cols(i,cols) return map(cols, function(x) return i.has[x.at] end) end
function EG.dist(i,j,smpl,   a,b,d,n,inc,dist1)
  d,n = 0,1E-31
  for _,col in pairs(smpl.xs) do
    n   = n+1
    a,b = i.has[col.at], j.has[col.at]
    inc = a=="?" and b=="?" and 1 or col:dist(a,b)
    d   = d + inc^YOUR.p end
  return (d/n)^(1/YOUR.p) end

function EG.better(eg1,eg2,smpl,    e,n,a,b,s1,s2)
  s1,s2,e,n = 0,0,10,#smpl.ys
  for _,col in pairs(smpl.ys) do
    a   = col:norm(eg1.has[col.at])
    b   = col:norm(eg2.has[col.at])
    s1  = s1 - e^(col.w * (a-b)/n) 
    s2  = s2 - e^(col.w * (b-a)/n) end
  return s1/n < s2/n end 


-- ## Columns
-- 
-- ### Columns to `SKIP`
function SKIP.new(n,s)  return new(SKIP, {txt=s or"", at=n or 0}) end
function SKIP.add(i,x)  return x end
function SKIP.mid()     return "?" end
function SKIP.ranges(...) return {math.huge,{}} end

-- ### `NUM`eric columns
-- **NUM(n?:posint, s?:string) : NUM**    
-- Creates a new number in column `n` with name `s`.   
-- Stores on the seen values in `_has`.  
-- If the name `s` contains "-", then that is a goal to be minimized
-- with weight `w=-1` (else the weight defaults to `w=1`).
function NUM.new(n,s)  
  return new(NUM, {txt=s or"", at=n or 0,lo=math.huge, hi=-math.huge,
                   _has={},
                   n=0,mu=0,m2=0,w=(s or ""):find"-" and -1 or 1}) end

function NUM.dist(i,a,b)
  if     a=="?" then b= i:norm(b); a=b>.5 and 0 or 1
  elseif b=="?" then a= i:norm(a); b=a>.5 and 0 or 1
  else   a,b = i:norm(a), i:norm(b) end
  return math.abs(a-b) end

local _ranges, _xpects
function NUM.ranges(i,j,         x,xys,ranges,xpect,n)
  xys = {}
  for _,x in pairs(i._has) do push(xys, {x=x, y="best"}) end
  for _,x in pairs(j._has) do push(xys, {x=x, y="rest"}) end
  return _xpects(#xys, 
                 _ranges(xys, xpect(i,j)*YOUR.dull, (#xys)^YOUR.Small, i, SYM)) end

function _xpects(n,ranges)
  xpect = 0
  for _,r in pairs(ranges) do xpect = xpect + r.has.n/n * r.has:div()  end
  return {xpect,ranges} end

function _ranges(xys,dull,small,col,yklass,      range,ranges,merge,span,spans)
  function merge(b4,    j,tmp,maybe,now,after) 
    j, tmp = 0, {}
    while j < #b4 do
      j = j + 1
      now, after = b4[j], b4[j+1]
      if after then 
        maybe = now.has:merge(after.has)
        if maybe:div()*1.01 <= xpect(now.has, after.has) then 
           now = {col=col, lo=now.lo, hi= after.hi, has=maybe} 
           j = j + 1 end end
      push(tmp,now) end 
    return #tmp==#b4 and b4 or merge(tmp) end

  range  = {col=col, lo=xys[1].x, hi=xys[1].x, has=yklass()}
  ranges = {range}
  for j,xy in pairs(sort(xys, function(a,b) return a.x < b.x end)) do
    if   j < #xys - small   and   -- enough items remaining after split
         xy.x ~= xys[j+1].x  and  -- next item is different (so can split here)
         range.has.n > small and   -- range has enough items
         range.hi - range.lo > dull -- range is not trivially small  
    then range = push(ranges, {col=col, lo=range.hi, hi=xy.x, has=yklass()}) end  
    range.hi = xy.x 
    range.has:add(xy.y) end 
  ranges[1].lo     = -math.huge
  ranges[#ranges].hi =  math.huge
  return merge(ranges) end 
function NUM.mid(i)   return i.mu end
function NUM.div(i) return i.n<2 and 0 or (i.m2/(i.n-1))^0.5 end 

function NUM.add(i,x,    d)  
  if x ~= "?" then 
    push(i._has,x)
    i.n = i.n+1; d=x-i.mu; i.mu=i.mu+d/i.n; i.m2=i.m2+d*(x-i.mu) 
    i.hi= math.max(i.hi,x)
    i.lo= math.min(i.lo,x) end 
  return x end

function NUM.norm(i,x) 
  return math.abs(i.lo - i.hi) < 1E-32 and 0 or (x - i.lo) / (i.hi - i.lo) end

function NUM.merge(i,j,    k)
  k=NUM(i.at, i.txt)
  for _,x in pairs(j._has) do k:add(x) end
  return k end

-- ### `SYM`bolic Columns
function SYM.new(n,s) 
  return new(SYM, {n=0,has={},txt=s or"", at=n or 0,mode=nil,most=0}) end
function SYM.add(i,x,n) 
  if x ~= "?" then 
    n        = n or 1
    i.n      = i.n+  n 
    i.has[x] = n+(i.has[x] or 0) 
    if i.has[x] > i.most then i.most, i.mode = i.has[x], x end end
  return x end

function SYM.mid(i) 
  return i.mode end

function SYM.div(i,   e)  
  e=0; for _,n in pairs(i.has) do e = e - n/i.n*math.log(n/i.n,2) end; return e end

function SYM.dist(i,a,b)
  return a==b and 0 or 1 end

function SYM.merge(i,j,    k) 
  k = SYM(i.at,i.txt)
  for x,n in pairs(i.has) do k:add(x,n) end
  for x,n in pairs(j.has) do k:add(x,n) end
  return k end

-- **i:SYM:ranges(j:SYM) :num**   
function SYM.ranges(i,j,        ranges,t,n,xpect)
  t,ranges = {},{}
  for x,n in pairs(i.has) do  t[x] = t[x] or SYM(); t[x]:add("best",n) end
  for x,n in pairs(j.has) do  t[x] = t[x] or SYM(); t[x]:add("rest",n) end
  for x,stats in pairs(t) do
    push(ranges, {col=i, lo=x, hi=x, has=stats}) end
  return _xpects(i.has.n + j.has.n, ranges) end

-- **:score(i:SYM, goal:string): num**   
-- Assess a distribution where one of the slots 
-- is `goal` and everything else is undesirable.
function SYM.score(i,goal)
  local div = function(p) return -p*math.log(p,2) + 1E-31 end
  local goals={}
  function goals.div(b,r)   return 1/(1- (b^2+r^2)) end
  function goals.smile(b,r) return r>b and 0 or b*b/(b+r +1E-31) end
  function goals.frown(b,r) return b<r and 0 or r*r/(b+r +1E-31) end
  function goals.xplor(b,r) return 1/(b+r                +1E-31) end
  function goals.doubt(b,r) return 1/(math.abs(b-r)      +1E-31) end
  local best, rest = 0, 0
  for x,n in pairs(i.has) do 
    if x==goal then best = best+n/i.n else rest = rest+n/i.n end end
  return best + rest < 0.01 and 0 or goals[YOUR.goal](best,rest) end

-- ## Tricks

-- ### Meta Stuff
-- **same(x:any, ...): x**   
function same(x,...) return x end

-- ### Table Stuff

-- **push(t:list, x:any) : any**   
-- Insert `x` at the end of `t`, the return `x`. 
function push(t,x)    
  table.insert(t,x); return x end
-- **firsts(t1:list, t2:list) : bool**    
-- Used in sorting: returns true if the first of `a` is less than the first of `b`.
function firsts(a,b)  
  return a[1] < b[1] end
-- **sort(t:list, f?:fun) : list**    
-- Sort a list, in-place. Return the sorted list. `fun` defaults to   
-- `function (x,y) return x < y end`.
function sort(t,f)    
  table.sort(t,f);   return t end
-- **map(t:list, f?:fun) : list**    
-- Return a list, all items filtered through `f`.
function map(t,f,  u) 
  f= f or same
  u={};for k,v in pairs(t) do push(u,f(v)) end; return u end

-- **sum(t:list, f?:fun) : list**    
-- Return a list, all items filtered through `f`.
function sum(t,f,  n) 
  f=f or same
  n=0; for _,x in pairs(t) do n=n + f(x) end; return n end

-- **slots(t: list): list**  
-- Returns the slot names of `t`, sorted. Ignores any "private" slots;
-- i.e. those starting with "_".
function slots(t,   u) 
  u={}
  for k,_ in pairs(t) do if tostring(k):sub(1,1) ~= "_" then push(u,k) end end
  return sort(u) end

-- **copy(t: list): list**  
-- Return a shallow copy of `t`.
function copy(t,u) 
  u={}
  for k,v in pairs(t) do u[k]=v end; return setmetatable(u, getmetatable(t)) end

-- ### File Stuff

-- Iterator **csv(file:str) : list**  
-- After pruning whitespace, for any non-empty rows divided on comma,
-- with any number strings coerced to numbers.
function csv(file,   x,row)
  function row(x,  t)
     for y in x:gsub("%s+",""):gmatch"([^,]+)" do push(t,coerce(y)) end; return t end
   file = io.input(file) 
   return function() x=io.read()
                     if x then return row(x,{}) else io.close(file) end end end

-- ### String stuff

-- **coerce(x:str) : any**   
-- Convert a string `x` to its correct type.
function coerce(x)
  if x=="true" then return true end
  if x=="false" then return false end
  return tonumber(x) or x end

-- **options(help: str): list**    
-- Generate a table of values from a help string.    
-- [1] For all lines starring with "  -":   
-- [2] The first and last word are is a flag and a default.   
-- [3] Update that flag from any command line info.     
-- For shorthand convenience:    
-- [4a] allow abbreviations for flags     
-- [4b] Boolean flags get toggled.     
-- [5] Return a table with all the flags and values.
function options(help_string)
  local t,update_from_cli  
  function update_from_cli(flag,x)           -- [2]
    for n,txt in ipairs(arg) do              -- [3]        
      if   flag:match("^"..txt:sub(2)..".*") -- [4a]
      then x = x=="false" and"true" or x=="true" and"false" or arg[n+1] end end -- [4b]
    t[flag] = coerce(x) end

  t={}
  help_string:gsub("\n  [-]([^%s]+)[^\n]*%s([^%s]+)", update_from_cli)  -- [1]
  return t end   -- [5]
-- **green(s:str): str**  
-- **yellow(s:str): str**  
-- Return `s` wrapped in color codes.
function green(s)  return #s>0 and "\027[32m"..s.."\027[0m" or "" end
function yellow(s)  return #s>0 and "\027[33m"..s.."\027[0m" or "" end

-- **rnd(x:any, d?:int) : list**    
-- If `x` is not a string, just return it.
-- Else, round the number `x` to `d` decimal places (default= `YOUR.round`).
function rnd(x,d,  n) 
  if type(x)=="number" then n=10^(d or YOUR.round); x= math.floor(x*n+0.5)/n end
  return x end

-- **rnds(t:list, d?:int) : list**    
-- Round a list of things to `d` decimal places (default= `YOUR.round`).
function rnds(t,d) 
  return map(t,function(x) return  rnd(x,d) end) end

-- ### Printing stuff

-- **fmt(...): str**    
-- Short hand for `string.format`.
fmt = string.format

-- **say(...) : nil**  
-- If `YOUR.verbose` is set, then call `fmt` on the args, then print it.
function say(...) 
  if YOUR.verbose then print(fmt(...)) end end

-- **o(t:list) : str**  
-- Convert a nested tree to a string. If `t` is a simple numeric list,
-- show each item without its slot name. Else, print each
-- `:slot value`, sorted alphabetically on slot name.
function o(t,   u,key)
  function key(k) return fmt(":%s %s", yellow(k), o(t[k])) end
  if type(t) ~= "table" then return tostring(t) end
  u = #t>0 and map(t,o) or map(slots(t),key)
  return green((t._is or "")).."{"..table.concat(u, " ").."}" end 

-- ### Random Stuff

-- **randi(lo: num, hi:num): num**   
-- Return a random float between `lo` and '`hi` (inclusive).
-- To generate the same sequence of rands, reset `YOUR.seed`.
function rand(lo,hi)
  YOUR.seed = (16807 * YOUR.seed) % 2147483647
  return (lo or 0) + ((hi or 1) - (lo or 0)) * YOUR.seed / 2147483647 end

-- **randi(lo: int, hi:int): int**   
-- Return a random integer between `lo` and '`hi` (inclusive).
function randi(lo,hi) 
  return math.floor(0.5 + rand(lo,hi)) end

-- **any(t: list, n?:int) : (any | list)**    
-- If called with one argument, return any item picked at random.
-- If called with two arguements, reutrn that maany `any`.
function any(t,  n) 
  if n then u={};for j=1,n do push(u,any(t)) end; return u 
       else return t[randi(1,#t)] end end

-- **shuffle(t: list) : list**    
-- Random shuffles top-level of `t`. 
function shuffle(t,   j)
  for i=#t,2,-1 do j=randi(1,i); t[i],t[j]=t[j],t[i] end; return t end

--- ### Maths stuff

-- **xpect(a=NUM|SYM, b=NUM|SYM) : num**   
-- Sum of diversities, weighted by population size.
function xpect(a,b) 
  return (a.n*a:div()+ b.n*b:div())/(a.n+b.n) end

-- ### OO stuff

-- **ako(x:klass) : klass**   
-- To test for class type, use e.g. `ako(X)==NUM`.
function ako(x) 
  return getmetatable(x) end
-- Instance creation; e.g. `new(NUM,{n=0})`.
function new(mt,x) 
  MINE.oid=MINE.oid+1; x._oid=MINE.oid -- Everyone gets a unique id.
  return setmetatable(x,mt) end        -- Methods now delegate to `mt`.

-- ## Demos

-- `go,nogo` are places to store demos (and disables demos).
-- Anything with a lower case name is
-- "public" and should be executed as part of the `-todo ALL` command.
local go, nogo = MINE.go, MINE.nogo

-- Show config options.
function go.the(s)    say(o(YOUR)) end -- to disable, change "go" to "nogo"

-- Testing if tests work
function go.pass(s)   azzert(true,  "can you handle success?")  end

-- Test we can handle failing tests.
function nogo.fail(s) azzert(false,"can you handle failure?") end 

-- Can we read data from a disk file.
function go.sample(s,  egs) 
  s=SAMPLE(YOUR.file)
  azzert(398==#s.egs, "got enough rows?")
  azzert(s.ys[1].w==-1,"minimizing goals are -1?") end

-- Generate a new table, with the same structure.
function go.clone(s,  t,s1,s2) 
  s=SAMPLE(YOUR.file)
  s1=o(s.ys)
  t=s:clone(s.egs) 
  s2=o(t.ys) 
  azzert(s1==s2, "cloning works?") end

-- Numbers demi
function go.num( m,n)
  m=NUM()
  for i=1,10 do m:add(i) end
  n = copy(m)
  for i=1,10 do n:add(i) end
  azzert(2.95 == rnd(n:div()),"sd ok?") end

-- Checking we can sort on multiple goals.
function go.dominate(s,  egs) 
  s=SAMPLE(YOUR.file)
  egs = sort(s.egs, function(a,b) return a:better(b,s) end)
  for i=1,5 do say(o(egs[i]:cols(s.ys))) end; say("")
  for i=#egs-5,#egs do say(o(egs[i]:cols(s.ys))) end
  azzert(egs[1]:better(egs[#egs],s), "y-sort working?") end

-- Checking if distances stuff.
function go.distance(   s,eg1,dist,tmp,j1,j2,d1,d2,d3,one)
  s=SAMPLE(YOUR.file)
  eg1=s.egs[1]
  dist = function(eg2) return {eg2,eg1:dist(eg2,s)} end
  tmp  = sort(map(s.egs, dist), function(a,b) return a[2] < b[2] end)
  one = tmp[1][1]
  for j=1,30 do
    j1=randi(1,#tmp)
    j2=randi(1,#tmp)
    if j1>j2 then j1,j2=j2,j1 end
    d1 = tmp[j1][1]:dist(one,s)
    d2 = tmp[j2][1]:dist(one,s)
    azzert(d1 <= d2,"distance ?") end end

-- Demo of main functionality.
function go.contrast(   s,x)
  s = SAMPLE(YOUR.file)
  s:contrast()
  end

-- ## Start up

-- List the "public" tests (those with lower case names), 
function go.LS() 
  for _,k in pairs(slots(go)) do 
    if k:match"^[a-z]" then  print("  -t "..k) end end end

-- Run the "public" tests (those with lower case names), 
function go.ALL() 
  for _,k in pairs(slots(go)) do 
    if k:match"^[a-z]" then 
      YOUR = options(MINE.help)  
      print("\n"..k)
      go[k]() end end end

-- Initialize failure count
MINE.fails=0
-- **azzert(test:bool, msg:str) : nil**    
-- Wrapper around the assert function.    
-- [1] Updates the failure counts.    
-- [2] Only call the real `assert` if `-debug" on cli.
function azzert(test,msg) 
  msg=msg or ""
  if test then print("  PASS : "..msg) 
          else MINE.fails = MINE.fails+1                       -- [1]
               print("  FAIL : "..msg)
               if YOUR.Debug then assert(test,msg) end end end -- [2]

-- **main(help:txt) : nil**    
-- [1] Build `YOUR` from the help string.  
-- [2] Maybe print the help text.   
-- [3] Run the `todo` function.    
-- [4] Hunt for any stray globals.    
-- [5] Return the number of fails generated.
function main(help)  
  YOUR = options(MINE.help)                                  -- [1] 
  if YOUR.h then print(MINE.help); os.exit() end             -- [2]
  if YOUR.todo and go[YOUR.todo] then go[YOUR.todo]() end    -- [3]
  for k,v in pairs(_ENV) do                                  -- [4]
    if not MINE.b4[k] then print("Rogue?",k,type(v)) end end 
  os.exit(MINE.fails) end                                    -- [5]

-- Let's go.
main(MINE.help)
