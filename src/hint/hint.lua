local b4={}; for k,v in pairs(_ENV) do b4[k]=v end; --[[

   __  __     __     __   __     ______  
  /\ \_\ \   /\ \   /\ "-.\ \   /\__  _\ 
  \ \  __ \  \ \ \  \ \ \-.  \  \/_/\ \/ 
   \ \_\ \_\  \ \_\  \ \_\\"\_\    \ \_\ 
    \/_/\/_/   \/_/   \/_/ \/_/     \/_/   --]] local options = {

what  = "Small sample multi-objective optimizer.",
usage = "(c) 2021 Tim Menzies <timm@ieee.org> unlicense.org",

how = {{"file",     "-f",  "../../data/auto93.csv",  "read data from file"},
       {"help",     "-h",  false  ,"show help"                  },
       {"hints",    "-H",  4      ,"hints per generation"       },
       {"p",        "-p",  2      ,"exponent on distance calc"  },
       {"small",    "-s",  .5     ,"div list t into t^small"    },
       {"seed",     "-S",  10019  ,"random number seed"         },
       {"train",    "-t",  .5     ,"train set size"             },
       {"trivial",  "-T",  .35    ,"small delta = trivial*sd"   }}}

local fmt = string.format
local function cli(opt,   u) 
  u={}
  for _,t in pairs(opt.how) do
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do if word==t[2] then
      u[t[1]] = t[3] and (tonumber(arg[n+1]) or arg[n+1]) or true end end end
  if u.help then 
    print(fmt("lua %s [ARGS]\n%s\n%s\n\nARGS:",arg[0],opt.usage,opt.what))
    for _,t in pairs(opt.how) do print(fmt("%6s %-11s: %s %s",
      t[2],
      t[3] and t[1] or"",
      t[4],
      t[3] and fmt("(%s=%s)",t[1],t[3]) or"")) end end 
  math.randomseed(u.seed)
  return u end

local the = cli(options)

------------------------------------------------------------------------------
-- maths tricks
local abs,norm,per,sd,xpect,mergeable,sum
abs = math.abs

function norm(x,lo,hi)
  if x=="?" then return x end
  return abs(hi - o) < 1E32 and 0 or (x - lo)/(hi - lo) end

function per(t,p,    here)
  function here(x) x=x*#t//1; return x < 1 and 1 or x>#t and #t or x end
  return #t <2 and  t[1] or t[ here(p or .5) ] end

function sd(t) return (per(t,.9) - per(t,.1))/ 2.56 end

function xpect(t1,t2) return (#t1*sd(t1) + #t2*sd(t2)) / (#t1 + #t2) end

function mergeable(t1,t2,    t3)  
  t3 = {}
  for _,x in pairs(t1) do push(t3,x) end
  for _,x in pairs(t2) do push(t3,x) end
  t3 = sort(t3) 
  if xpect(t1,t2) >= sd(t3) then return t3 end end

function sum(t,f)
  f= f or function(x) return x end
  out=0; for _,x in pairs(f) do out = out + f(x) end; return out end

-------------------------------------------------------------------------------
-- table tricks
local cat,map,copy,pop,push,sort,firsts,first,second,shuffle,bchop
cat     = table.concat
sort    = function(t,f) table.sort(t,f); return t end
push    = table.insert
push    = table.remove
first   = function(t) return t[1] end
second  = function(t) return t[2] end
firsts  = function(a,b) return first(a) < first(b) end

function copy(t) return map(t, function(_,x) return x end) end

function shuffle(t,   j)
  for i=#t,2,-1 do j=math.random(1,i); t[i],t[j]=t[j],t[i] end; return t end

function map(t,f,     u) 
  u={}; for x,y in pairs(t) do 
    x,y = f(x,y) 
    if x ~= nil then
      if y then u[x]=y else u[1+#u]=x end end end 
  return u end

function bchop(t,val,lt,      lo,hi,mid)
  lt = lt or function(x,y) return x < y end
  lo, hi = 1, #t
  while lo <= hi do
    mid =(lo+hi) // 2
    if lt(t[mid],val) then lo=mid+1 else hi= mid-1 end end
  return math.min(lo,#t)  end

-------------------------------------------------------------------------------
-- printing tricks
local out,shout
shout= function(x) print(out(x)) end

function out(t,    u,key,keys,value,public)
  function key(_,k)   return fmt(":%s %s",k,out(t[k])) end
  function value(_,v) return out(v,seen) end
  function public(k)  return tostring(k):sub(1,1)~="_" end
  function keys(t,u)
    u={}; for k,_ in pairs(t) do if public(k) then push(u,k) end end
    return sort(u) 
  end
  if type(t) == "function" then return "FUN" end
  if type(t) ~= "table"    then return tostring(t) end
  u = #t>0 and map(t, value) or map(keys(t), key) 
  return (t._is or"").."{"..cat(u," ").."}" end 

-------------------------------------------------------------------------------
-- file i/o tricks
local lines
function lines(file,   line,t,out)
  file = io.input(file)
  line = io.read()
  out  = {}
  while line do
    t={}
    for cell in line:gsub("[\t\r ]*",""):gsub("#.*",""):gmatch("([^,]+)") do
      push(t, tonumber(cell) or cell) end 
    if #t>0 then push(out, t) end 
    line = io.read()
  end 
  io.close(file)
  return  out end

-------------------------------------------------------------------------------
-- oo tricks
local has,obj
function has(mt,x) return setmetatable(x,mt) end
function obj(s, o,new)
   o = {_is=s, __tostring=out}
   o.__index = o
   return setmetatable(o,{__call = function(_,...) return o.new(...) end}) end

-------------------------------------------------------------------------------
-- Samples store rows. They know about 
-- (a) lo,hi ranges on the numerics
-- and (b) what  are independent `x` or dependent `y` columns.
local Sample=obj"Sample"
function Sample.new(     src,self)
  self = has(Sample,{names=nil, nums={}, ys={}, xs={}, rows={}})  
  if src then
    src = type(src)=="string" and lines(src) or src
    for _,x in pairs(src) do self:add(x) end end
  return self end

function Sample:clone(      inits,out) 
  out = Sample.new():add(self.names) 
  for _,row in pairs(inits or {}) do out:add(row) end
  return out end

function Sample:add(row,     name,datum)
  function name(col,new,    tmp) 
    if not new:find":" then return end
    if not (new:find("+") or new:find("-")) then self.xs[col]=col end 
    if new:match("^[A-Z]") then 
      tmp = {col=col, w=0, lo=1E32, hi=-1E22} 
      self.nums[col] = tmp
      if new:find"-" then tmp.w=-1; self.ys[col] = tmp end
      if new:find"+" then tmp.w= 1; self.ys[col] = tmp end end 
  end -----------------
  function datum(col,new)
    if self.nums[col] and new ~= "?" then
      self.nums[col].lo = math.min(new, self.nums[col].lo)
      self.nums[col].hi = math.max(new, self.nums[col].hi) end  
  end -----------------
  if   not self.names
  then self.names = row
       map(row, function(col,x) name(col,x) end) 
  else push(self.rows, row)
       map(row, function(col,x) datum(col,x) end) end 
  return self end

-- bins his
-- bins sorts
 
function Sample:tree(min,      node,xpect1,bins1,xpect0,bins0,sub,x)
  node = {node=self, kids={}}
  min = min  or self.rows^the.small
  if #self.rows >= 2*min then 
    xpect1 = math.huge 
    for _,x in pairs(sample.xs) do
      bins0, xpect0 = bins(x.at,self)
      if   xpect0 < xpect1 
      then x,xpect1, bins1 = x.at, xpect0, bins0 end end
   -- {col=col, lo=x, hi=x, has=sort(t)} end   
   for _,bin in pairs(bins1) do
      sub = self:clone()
      for _,at in pairs(bin.has) do sub:add(self.rows[at]) end 
      push(node.kids, bin) 
      bin.has = sub:tree(min) end end 
  return node end

-- at node

function Sample:where(tree,row,    max,default)
  if #kid.has==0 then return tree end
  max = 0
  for _,kid in pairs(tree.node) do
    if #kid.has > max then default,max = kid,#kid.has end
    x = row[kid.col]
    if x ~= "?" then
      if x <= kid.hi and x >= kid.lo then 
        return self:where(kid.has.row) end end end
  return self:where(default, row) end

-------------------------------------------------------------------------------
-- doscretization tricks
local bins,bins1,merge,discretize
function bins(col,sample,     out)
  out = bins1(col,sample)
  return out, sum(out, function(x) return #x.has*sd(x.has) end)/#sample.rows end

function bins1(col,sample,      xs,xys, x,y,tmp,out,n,xpect)
  xys,xs, seen, symbolic ={},{}, {}, sample.nums[col]
  for rank,row in pairs(sample.rows) do
    x,y = row[col], rank
    if x ~= "?" then 
      if   symbolic
      then seen[x] = seen[x] or {}
           push(seen[x], y) 
      else push(xs,x)
           push(xys,{x=x,y=y}) end end 
  end
  if   symbolic 
  then return map(seen, function(x,t) return {col=col, lo=x, hi=x, has=sort(t)} end)
  else return discretize(col,sort(xys, function(a,b) return a.x < b.x end),
                             #xs^the.small,  sd(sort(xs)) * the.trivial)  end end

-- Generate a new range when     
-- 1. there is enough left for at least one more range; and     
-- 2. the lo,hi delta in current range is not boringly small; and    
-- 3. there are enough x values in this range; and   
-- 4. there is natural split here
-- Fuse adjacent ranges when:
-- 5. the combined class distribution of two adjacent ranges 
--    is just as simple as the parts.
function discretize(col, xys, tiny, dull,           now,out,x,y)
  now = {col=col, lo=xys[1].x, hi=xys[1].x, has={}}
  out = {now}
  for j,xy in pairs(xys) do
    x, y = xy.x, xy.y
    if   j<#xys-tiny and x~=xys[j+1].x and #now.has>tiny and now.hi-now.lo>dull 
    then now = {col=col, lo=x, hi=x, has={}}
         push(out, now) end 
    now.hi = x 
    push(now.has, y) end
  return merge(col, map(out, function(_,one) table.sort(one.has) end)) end 

function merge(col, b4,       j,tmp,a,n,hasnew) 
  j, n, tmp = 0, #b4, {}
  while j<n do
    j = j + 1
    a = b4[j]
    if j < n-1 then
      better = mergeable(a.has, b4[j+1].has)
      if better then 
        j = j + 1 
        a = {col=col, lo=a.lo, hi= b4[j+1].hi, has=better} end end
    push(tmp,a) end 
  return #tmp==#b4 and b4 or merge(col,tmp) end

-------------------------------------------------------------------------------
-- geometry tricks
-- y column rankings
local dist, better,betters
function dist(row1,row2,sample,     a,b,d,n,inc,dist1)
  function dist1(num)
    if not num then return a==b and 0 or 1 end
    if     a=="?" then b=norm(b, num.lo, num,hi); a = b>.5 and 0 or 1
    elseif b=="?" then a=norm(a, num.lo, num.hi); b = a>.5 and 0 or 1
    else   a,b = norm(a, num.lo, num.hi), norm(b, num.lo, num.hi)
    end
    return abs(a-b) 
  end -------------------------
  d,n=0,0
  for col,_ in pairs(sample.xs) do
    a,b = row1[col], row2[col]
    inc = a=="?" and b=="?" and 1 or dist1(sample.nums[col])
    d   = d + inc^the.p
    n   = n + 1 end
  return (d/n)^(1/the.p) end

function betters(rows,sample) 
  return sort(rows,function(a,b) return better(a,b,sample) end) end

function better(row1,row2,sample,     e,n,a,b,s1,s2)
  n,s1,s2,e = #sample.ys, 0, 0, 2.71828
  for _,num in pairs(sample.ys) do
    a  = norm(row1[num.col], num.lo, num.hi)
    b  = norm(row2[num.col], num.lo, num.hi)
    s1 = s1 - e^(num.w * (a-b)/n) 
    s2 = s2 - e^(num.w * (b-a)/n) end
  return s1/n < s2/n end 

-------------------------------------------------------------------------------
-- sample sample sorting
local hint,score,hints1,hints
function score(row) return row end

function hints(     sample,train,test,tree)
  sample = Sample.new(the.file)
  train,test = {}, {}
  for i,rows in pairs(shuffle(sample.rows)) do
     push(i<= the.train*#rows and trains or test, row) end
  train = hints(score, sample, train, {}, (#train)^the.small)
  tree  = sample:clone(train):tree() 
  test  = betters(test, sample)
end

function hints1(scorefun, sample, rows, out, stop)
  local scoreds = {}   
  function act(_,row) return hint(scoreds,row,sample) end
  if #rows < small then 
    for i=1, #rows do push(out, pop(rows)) end 
  else
    for j=1,the.hints do push(scoreds, scorefun(pop(rows))) end
    scoreds = betters(scoreds, sample)
    rows    = map(sort(map(rows, act),firsts),second)
    for i=1,#rows//2 do push(out, pop(rows)) end
    hints1(scorefun, sample, rows, out, stop) 
  end
  return out end

function hint(scoreds,row,sample,        closest,rank,tmp)
  closest, rank, tmp = 1E32, 1E32, nil
  for rank0, scored in pairs(scoreds) do
    tmp = self:dist(row,scored,sample)
    if tmp < closest then closest,rank = tmp,rank0 end end
  return {rank+closest/10^6, row}
end 


-------------------------------------------------------------------------------
-- trick for checking for rogues.
for k,v in pairs(_ENV) do if not b4[k] then print("? ",k,type(v)) end end
