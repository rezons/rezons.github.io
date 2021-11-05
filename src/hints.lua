-- Seek hints in the data about  what is better than what.    
-- 1. Given many unevaluated things, find the mid-point of few evaluated things.
-- 2. Prune everything below the mid.
-- 3. Repeat.
-- 4. Return the surviving best things.
local the -- Global config. Built via `the = updateFromCommandLine(about.how)`
local about={
  what = "Semi-supervised multi-objective optimizer",
  when = "(c) 2021, Tim Menzies, unlicense.org",
  how  = {
    {"cohen", "-c", .35,                  "min stdev delta to be different"},
    {"enough","-e", .5,                   "stopping criteria"},
    {"file",  "-f", "../data/auto93.csv", "data file to load"},
    {"some",  "-s", 4,                    "samples per generation"},
    {"seed",  "-S", 937162211,            "random number seed"},
    {"todo",  "-do", "help",              "start-up action"}}}

-- ## Functions

-- `b4` is  used at end-of-file to find rogue globals.
local b4={}; for k,v in pairs(_ENV) do b4[k]=v end 

-- ### Useful short cuts
local abs,log,cat,fmt,pop,push,sort,same
abs  = math.abs
cat  = table.concat
fmt  = string.format
log  = math.log 
pop  = table.remove
push = table.insert
same = function(x,...) return x  end
sort = function(t,f) table.sort(t,f); return t end

-- ### Randoms
local Seed, randi, rand
Seed=937162211
-- Random ints
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
-- Random floats (defaults  0..1)
function rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 

-- ### Arrays
local firsts,map,keys,shuffle,copy,sum
-- Shallow copy
function copy(t) return map(t, function(_,x) return x end) end

-- `firsts` is used for sorting {{score1,x1}, {score2,x2},...}
function firsts(x,y) return x[1] < y[1] end

-- Sorted table keys
function keys(t,  u) 
  u={};for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then push(u,k) end end
  return sort(u) end

-- Call `f(key,value)` on all items  in list.
function map(t,f,  u) 
  u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 

-- Randomly sort in-place a list
function shuffle(t,n,    j)
  for i = #t,2,-1 do j=randi(1,i); t[i],t[j] = t[j],t[i] end
  return t end

-- Sum items in a list, optionally filtered via  `f`.
function sum(t,f,    n)
  n,f = 0,f or same
  for _,x in pairs(t) do n=n+f(x) end; return n end

-- ### Command-line
-- At start-up, `the`  settings will come from `the = cli(about.how)`.
local function updateFromCommandLine(options,   u)
  u={}
  for _,t in pairs(options) do
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do if word==t[2] then
      u[t[1]] = (t[3]==false) and true or tonumber(arg[n+1]) or arg[n+1] end end end
  return u end

--  ### Printing
local shout,out

-- Generate  a pretty-print string from a table (recursively).
function out(t,    u,f1,f2)
  function f1(_,x) return fmt(":%s %s",x,out(t[x])) end
  function f2(_,x) return out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u = #t==0 and map(keys(t),f1) or map(t,f2)
  return (t._is or"").."{"..cat(u," ").."}" end

-- Print a pretty-print string.
function shout(x) print(out(x)) end

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
  
local Sym,Num,Skip,Cols,Sample

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
function Sym:add(x)    
  if x=="?" then return x end; 
  self.n = self.n + 1
  self.seen[x] = 1+(self.seen[x] or 0) 
  if self.seen[x] > self.most then 
     self.most,self.mode = self.seen[x],x end end

function Sym:dist(x,y) return  x==y and 0 or 1 end
function Sym:mid()     return self.mode end
function Sym:spread()  -- entropy
  return sum(self.seen, 
             function(n) return n<-0 and 0 or -n/self.n*log(n/self.n,2) end) end

-- ### Num
-- Columns for sumamrizing numbers.
Num = obj"Num" ----------------------------------------------------------------
function Num.new(i,s) 
  return has(Num,{at=i,txt=s, n=0,_contents={}, ok=false,w=weight(s)}) end

function Num:add(x) 
  if x=="?" then return x end
  self.n = self.n + 1
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
function Num:norm(x,     a)
  a=self:all()
  return abs(a[#a]-a[1])< 1E-16 and 0 or (x - a[1])/(a[#a] - a[1]) end

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
function  Sample:add(lst,   add)
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
  local n,a,b,s1,s2
  cols = cols or self.cols.ys
  s1, s2, n = 0, 0, #cols
  for _,col in pairs(cols) do
    a  = col:norm(row1[col.at]) --normalize to avoid explosion in exponentiation
    b  = col:norm(row2[col.at])
    s1 = s1 - 10^(col.w * (a - b) / n)
    s2 = s2 - 10^(col.w * (b - a) / n) end
  return s1 / n < s2 / n end

-- Return a new `Sample` with the same structure as this one.
function Sample:clone(inits,   tmp)
  tmp = Sample.new():add( self.cols.header )
  map(inits or {}, function(_,row) tmp:add(row) end)
  return tmp end

-- Two samples are different if any of their goals are more than
-- (say) .35\* the standard devation of that goal.
function Sample:diff(other,xy,     col2,sd)
  xy = xy or "ys"
  for i,col1 in pairs(self.cols[xy]) do
    col2 = other.cols[xy][i]
    sd = (col1:spread()*col1.n + col2:spread()*col2.n) / (col1.n + col2.n)
    if abs(col2:mid()  - col1:mid()) >= sd*the.cohen then
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
function Sample:div(   somes)
  somes = {}
  local function want(_,row)
    local closest,rowRank,tmp = 1E32,1E32,nil
    for someRank,some1 in pairs(somes) do
       tmp = self:dist(row,some1)
       if tmp < closest then closest,rowRank = tmp,someRank end end
    return {rowRank,row} 
  end ------------------------------------
  local function go(rows,evals)
    if #rows < 2*(#self.rows)^the.enough or #rows < 2*the.some then 
      return evals,rows end
    for i = 1,the.some do push(somes,pop(rows)) end
    somes = sort(somes, function(x,y) return self:better(x,y) end)
    local best = {}
    for k,v in pairs(sort(map(rows,want), firsts)) do 
      if k <= #rows/2 then push(best, v[2]) else break end end
    return go(best, evals+the.some) 
  end
  return go(shuffle(copy(self.rows)),0) end

-- The central tendency of a `sample` comes fro its columns.
function Sample:mid(  cols) 
  return map(cols or self.cols.all, function(k,x)  return x:mid() end) end

-- The spread of a `sample` comes fro its columns.
function Sample:spread(   cols) 
  return map(cols or self.cols.all, function(_,x) return x:spread() end) end

-- ## Stuff `Todo` at Start-up
local Todo={} ------------------------------------------------------------------
Todo.help={"print help", 
  function ()
    print("lua hints.lua [OPTIONS] -do ACTION\n")
    print(about.what)
    print(about.when,"\n\nOPTIONS:");
    for _,t in pairs(about.how) do if t[1] ~= "todo" then
      print(fmt("  %-4s%-20s %s",
                t[2], t[3]==false and "" or t[3], t[4])) end end
    print("\nACTIONS:")
    for _,k in pairs(keys(Todo)) do
      print(fmt("  -do %-21s%s",k, Todo[k][1])) end end}

Todo.demo1={"main demo", function(     s,t,u)
  local function stats(n,s)
    print(n, #s.rows, 
             out(s:mid(s.cols.ys)), 
             out(map(s:spread(s.cols.ys), 
                    function(_,x) return fmt("%6.2f",x*the.cohen) end))) 
  end ---------------------
  s = Sample.new(the.file)
  stats(0,s)
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
