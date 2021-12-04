local b4={}; for k,v in pairs(_ENV) do b4[k]=v end; --[[
   __  __     __     __   __     ______  
  /\ \_\ \   /\ \   /\ "-.\ \   /\__  _\ 
  \ \  __ \  \ \ \  \ \ \-.  \  \/_/\ \/ 
   \ \_\ \_\  \ \_\  \ \_\\"\_\    \ \_\ 
    \/_/\/_/   \/_/   \/_/ \/_/     \/_/   --]] local options = {

what = "Small sample multi-objective optimizer.",
usage = "(c) 2021 Tim Menzies <timm@ieee.org> unlicense.org",
about = [[
N examples are sorted on multi-goals using just a handful of
"hints"; i.e.

(a) evaluate, then rank,  a few randomly selected
    examples (on their y-values);
(b) sort the remaining examples by their x-value
    distance  to the ranked ones;
(c) recursing on the better half (so we sample more and more
    from the better half, then quarter, then eighth...).

A recursive descent CART-style regression tree is then applied to
the sorted examples (ranked left to right, worst to best).
By finding branches that reduce the variance of the index
of those examples, the regression tree reports what
attribute ranges select for the better (or worse) examples.
]],
how = {{"file",     "-f",  "../../data/auto93.csv",  "read data from file"},
       {"help",     "-h",  false  ,"show help"                  },
       {"hints",    "-H",  4      ,"hints per generation"       },
       {"p",        "-p",  2      ,"exponent on distance calc"  },
       {"small",    "-s",  .5     ,"div list t into t^small"    },
       {"seed",     "-S",  10019  ,"random number seed"         },
       {"train",    "-t",  .5     ,"train set size"             },
       {"trivial",  "-T",  .35    ,"small delta = trivial*sd"   }}}

local fmt = string.format

local function help(opt)
  print(fmt("lua %s [ARGS]\n%s\n%s\n\nARGS:",arg[0],opt.usage,opt.what))
    for _,t in pairs(opt.how) do print(fmt("%6s %-11s: %s %s",
      t[2],
      t[3] and t[1] or"",
      t[4],
      t[3] and fmt("(%s=%s)",t[1],t[3]) or"")) end end 

local function cli(opt,   u) 
  u={}
  for _,t in pairs(opt.how) do
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do if word==t[2] then
      u[t[1]] = t[3] and (tonumber(arg[n+1]) or arg[n+1]) or true end end end
  if u.help then help(opt) end
  math.randomseed(u.seed or 100019)
  return u end

local the = cli(options)

------------------------------------------------------------------------------
-- maths tricks
local abs,norm,per,sd,xpect,mergeable,sum
abs = math.abs

function norm(x,lo,hi)
  if x=="?" then return x end
  return abs(hi - o) < 1E32 and 0 or (x - lo)/(hi - lo) end

-- Nums class for sorted numbers
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
-- doscretization tricks
local splits={}
function splits.best(sample,    best,tmp,xpect,out)
  best = maths.huge
  for _,x in pairs(sample.xs) do
    tmp, xpect = splits.whatif(x.at,self)
    if   xpect < best 
    then out,best = tmp,xpect end end
  return out end
   
function splits.whatif(col,sample,     out)
  out = map(splits.spans(col,sample), function(_,bin) bin.col=col end)
  return out, sum(out, function(x) return #x.has*sd(x.has) end)/#sample.egs end

function splits.spans(col,sample,      xs,xys, symbolic,x)
  xys,xs,  symbolic ={},{}, sample.nums[col]
  for rank,eg in pairs(sample.egs) do
    x = eg[col]
    if x ~= "?" then 
      push(xs,x)
      if   symbolic
      then -- in symbolic columns, xys are the indexes seen with each symbol
           xys[x] = xys[x] or {}
           push(xys[x], rank) 
      else -- in numeric columns, xys are each number paired with its eg id
           push(xys,    {x=x,y=rank}) end end 
  end
  if   symbolic 
  then return map(xys, function(x,t) return {lo=x, hi=x, has=sort(t)} end)
  else return splits.merge(
                 splits.div(xys, #xs^the.small, sd(sort(xs))*the.trivial)) end end

-- Generate a new range when     
-- 1. there is enough left for at least one more range; and     
-- 2. the lo,hi delta in current range is not boringly small; and    
-- 3. there are enough x values in this range; and   
-- 4. there is natural split here
-- Fuse adjacent ranges when:
-- 5. the combined class distribution of two adjacent ranges 
--    is just as simple as the parts.
function splits.div(xys, tiny, dull,           now,out,x,y)
  xys = sort(xys, function(a,b) return a.x < b.x end)
  now = {lo=xys[1].x, hi=xys[1].x, has={}}
  out = {now}
  for j,xy in pairs(xys) do
    x, y = xy.x, xy.y
    if   j<#xys-tiny and x~=xys[j+1].x and #now.has>tiny and now.hi-now.lo>dull 
    then now = {o=x, hi=x, has={}}
         push(out, now) end 
    now.hi = x 
    push(now.has, y) end
  return map(out, function(_,one) table.sort(one.has) end) end 

function splits.merge(b4,       j,tmp,a,n,hasnew) 
  j, n, tmp = 0, #b4, {}
  while j<n do
    j = j + 1
    a = b4[j]
    if j < n-1 then
      better = mergeable(a.has, b4[j+1].has)
      if better then 
        j = j + 1 
        a = {lo=a.lo, hi= b4[j+1].hi, has=better} end end
    push(tmp,a) end 
  return #tmp==#b4 and b4 or merge(tmp) end


-------------------------------------------------------------------------------
-- Samples store examples. Samples know about 
-- (a) lo,hi ranges on the numerics
-- and (b) what  are independent `x` or dependent `y` columns.
local Sample=obj"Sample"
function Sample.new(     src,self)
  self = has(Sample,{names=nil, nums={}, ys={}, xs={}, egs={}})  
  if src then
    src = type(src)=="string" and lines(src) or src
    for _,x in pairs(src) do self:add(x) end end
  return self end

function Sample:clone(      inits,out) 
  out = Sample.new():add(self.names) 
  for _,eg in pairs(inits or {}) do out:add(eg) end
  return out end

function Sample:add(eg,     name,datum)
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
  then self.names = eg
       map(eg, function(col,x) name(col,x) end) 
  else push(self.egs, eg)
       map(eg, function(col,x) datum(col,x) end) end 
  return self end

-- bins his
-- bins sorts
 
function Sample:tree(min,      node,min,sub)
  node = {node=self, kids={}}
  min = min  or (#self.egs)^the.small
  if #self.egs >= 2*min then 
    --- here
    for _,span in pairs(splits.best(sample)) do
      sub = self:clone()
      for _,at in pairs(span.has) do sub:add(self.egs[at]) end 
      push(node.kids, span) 
      span.has = sub:tree(min) end end 
  return node end

-- at node
function Sample:where(tree,eg,    max,x,default)
  if #kid.has==0 then return tree end
  max = 0
  for _,kid in pairs(tree.node) do
    if #kid.has > max then default,max = kid,#kid.has end
    x = eg[kid.col]
    if x ~= "?" then
      if x <= kid.hi and x >= kid.lo then 
        return self:where(kid.has.eg) end end end
  return self:where(default, eg) end

-- ordered object
-- per sd add sort here. mergabe

-------------------------------------------------------------------------------
-- geometry tricks
-- y column rankings
local dist, better,betters
function dist(eg1,eg2,sample,     a,b,d,n,inc,dist1)
  function dist1(num,a,b)
    if not num then return a==b and 0 or 1 end
    if     a=="?" then b=norm(b, num.lo, num,hi); a = b>.5 and 0 or 1
    elseif b=="?" then a=norm(a, num.lo, num.hi); b = a>.5 and 0 or 1
    else   a,b = norm(a, num.lo, num.hi), norm(b, num.lo, num.hi)
    end
    return abs(a-b) 
  end -------------------------
  d,n=0,0
  for col,_ in pairs(sample.xs) do
    a,b = eg1[col], eg2[col]
    inc = a=="?" and b=="?" and 1 or dist1(sample.nums[col],a,b)
    d   = d + inc^the.p
    n   = n + 1 end
  return (d/n)^(1/the.p) end

function betters(egs,sample) 
  return sort(egs,function(a,b) return better(a,b,sample) end) end

function better(eg1,eg2,sample,     e,n,a,b,s1,s2)
  n,s1,s2,e = #sample.ys, 0, 0, 2.71828
  for _,num in pairs(sample.ys) do
    a  = norm(eg1[num.col], num.lo, num.hi)
    b  = norm(eg2[num.col], num.lo, num.hi)
    s1 = s1 - e^(num.w * (a-b)/n) 
    s2 = s2 - e^(num.w * (b-a)/n) end
  return s1/n < s2/n end 

-------------------------------------------------------------------------------
-- sample sample sorting
local hints={}
function hints.default(eg) return eg end

function hints.sort(score,     sample,train,test,tree)
  sample = Sample.new(the.file)
  train,test = {}, {}
  for i,eg in pairs(shuffle(sample.egs)) do
     push(i<= the.train*#sample.egs and train or test, eg) end
  train = hints.recurse(sample, train,
                        score or hints.default, {}, (#train)^the.small)
  tree  = sample:clone(train):tree() 
  test  = betters(test, sample)
end

function hints.recurse(sample, egs, scorefun, out, small)
  if #egs < small then 
    for i=1, #egs do push(out, pop(egs)) end 
    return out 
  end
  local scoreds = {}   
  function worker(_,eg) return hint.locate(scoreds,eg,sample) end
  for j=1,the.hints do push(scoreds, scorefun(pop(egs))) end
  scoreds = betters(scoreds, sample)
  egs     = map(sort(map(egs, worker),firsts),second)
  for i=1,#egs//2 do push(out, pop(egs)) end
  return hints.recurse(sample, egs, scorefun, out, small)  end

function hint.locate(scoreds,eg,sample,        closest,rank,tmp)
  closest, rank, tmp = 1E32, 1E32, nil
  for rank0, scored in pairs(scoreds) do
    tmp = self:dist(eg,scored,sample)
    if tmp < closest then closest,rank = tmp,rank0 end end
  return {rank+closest/10^6, eg}
end 

-------------------------------------------------------------------------------
-- trick for checking for rogues.
for k,v in pairs(_ENV) do if not b4[k] then print("? ",k,type(v)) end end
