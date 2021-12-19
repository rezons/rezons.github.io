local the =require"tiny0"[[
lua hint.lua [OPTIONS]

A small sample multi-objective optimizer / data miner.
(c)2021 Tim Menzies <timm@ieee.org> unlicense.org

OPTIONS:
  -best     X   Best examples are in 1..best*size(all)    = .05
  -debug    X   run one test, show stackdumps on fail     = ing
  -epsilon  X   ignore differences under epsilon*stdev    = .35  
  -file     X   Where to read data                        = ../../data/auto93.csv
  -h            Show help                                 = false
  -seed     X   Random number seed;                       = 10019
  -Stop     X   Create subtrees while at least 2*stop egs =  4
  -Tiny     X   Min range size = size(egs)^tiny           = .5
  -todo     X   Pass/fail tests to run at start time      = ing
                If "X=all", then run all.
                If "X=ls" then list all. ]]

-- .  .       
-- |\/|* __ _.
-- |  ||_) (_.
local _=require"tinylib"
local say,fmt,color,out,shout= _.say,_.fmt,_.color,_.out,_.shout,_.csv -- strings
local map,copy,keys,push    = _.map,_.copy, _.keys, _.push -- tables
local sort, firsts, seconds = _.sort, _.firsts, _.seconds  -- sorting
local norm, sum             = _.norm,  _sum                -- maths
local randi,rand            = _.randi, _,rand              -- randoms
local same                  = _.same                       -- meta
local csv                   = _.csv -- files

local ent,mode
function ent(t,    n,e)
  n=0; for _,n1 in pairs(t) do n = n + n1 end
  e=0; for _,n1 in pairs(t) do e = e - n1/n*math.log(n1/n,2) end
  return e,n  end

function mode(t,     most,out)
  most = 0
  for x,n in pairs(t) do if n > most then most,out = n,x end end
  return out end

--  __.           .   
-- (__  _.._ _ ._ | _ 
-- .__)(_][ | )[_)|(/,
--             |      
-- [5] Returns a sample, initialized, updated
-- [1] Self initialize (if nil, then create).
-- [2] Read from disc file
-- [3] First item is special (contains names of columns)
-- [4] Other rows are the actual examples. Use these to update column headers
-- [6] Numeric columns have an "num[n]" entry that tracks the
--     "num[n].lo" and "num[n].hi" range for each variable.
-- [7] Columns to be minimized or maximized are dependent (listed in "ys")
-- [8] All other columns are the independent (listed in "xs")
-- [9] Dependent variables are minimized,maximized at weights -1,1 
--     if their name contains "-" or "+". The number of dependents ins "nys"
-- [10]columns contain ":" are ignored
-- [11]Each example will be discretized (later) so each example holds the
--     "raw" values (not discretized) and the "cooked" examples (discretized).
local slurp,sample,ordered,clone
function slurp(out)
  for eg in csv(the.file) do out=sample(eg,out) end --[2] 
  return out end

function clone(i, inits,     out)
  out = sample(i.heads)
  for _,eg in pairs(inits or {}) do out = sample(eg,out) end
  return out end

function sample(eg,i)
  local numeric,independent,dependent,head,data,datum
  i = i or {xs={},nys=0,ys={},num={},egs={},heads={},divs={}}  -- [1]
  function head(n,x)
    function numeric()     i.num[n]= {hi=-math.huge,lo=math.huge} end -- [6]]
    function independent() i.xs[n]= x end  -- [8]
    function dependent()                   -- [7]
      i.num[n].w  = x:find"-" and -1 or 1  -- [9]
      i.ys[n] = x
      i.nys   = i.nys+1 end
    if not x:find":" then  -- [10]
      if x:match"^[A-Z]" then numeric() end 
      if x:find"-" or x:find"+" then dependent() else independent() end end --[7,8]
    return x end
  function data(eg) return {raw=eg, cooked=copy(eg)} end --[11]
  function datum(n,x) -- [4]
    if x ~= "?" then
      local num=i.num[n]
      if num then 
        num.lo = math.min(num.lo,x)          -- [6]
        num.hi = math.max(num.hi,x) end end  -- [6]
    return x end
  eg = eg.raw and eg.raw or eg 
  if #i.heads==0 then i.heads=map(eg,head) else  -- [3]
    push(i.egs,data(map(eg,datum))) end          -- [4]
  return i end -- [5]

-- [14] Returns the sample, examples sorted by their goals.
-- [15] The direction that losses the most points to best example.
--      e.g. a.b=.7,.6 and a-b  s .1 (small loss) and b-a is -.1 
--      (much smaller than a or b) so a is more important than b.
-- [13] Goal differences are amplified by raining them to a power (so normalize
--      the goals first so you that calculation does not explode.
function ordered(i) -- [11]
  local function better(eg1,eg2,     a,b,s1,s2)
    s1,s2=0,0
    for n,_ in pairs(i.ys) do    -- [15]
      local num = i.num[n]
      a  = norm(num.lo, num.hi, eg1.raw[n])         -- [13]
      b  = norm(num.lo, num.hi, eg2.raw[n])         -- [13]
      s1 = s1 - 2.71828^(num.w * (a-b)/i.nys)       -- [12]
      s2 = s2 - 2.71828^(num.w * (b-a)/i.nys) end   -- [12]
    return s1/i.nys < s2/i.nys end                  -- [12]
  for j,eg in pairs(sort(i.egs,better)) do 
    if j < the.best*#i.egs then eg.klass="best" else eg.klass="rest" end end
  return i end  -- [14]

-- .__        
-- [__)*._  __
-- [__)|[ )_) 
local discretize, xys_sd, bin, div
function bin(z,divs) 
  if z=="?" then return "?" end
  for n,x in pairs(divs) do 
    if x.lo<= z and z<= x.hi then return string.char(96+n) end end end 

function discretize(i)       
  function xys_sd(col,egs,    out,p)
    out={}
    for _,eg in pairs(egs) do 
      local x=eg.raw[col]
      if x~="?" then push(out, {x=x,  y=eg.klass}) end end
    out = sort(out, function(a,b) return a.x < b.x end) 
    p   = function(z) return out[z*#out//10].x end
    return out, math.abs(p(.9) - p(.1))/2.56 
  end -----------------------
  for col,_ in pairs(i.xs) do
    if i.num[col] then
      local xys,sd = xys_sd(col, i.egs)
      i.divs[col]  = div(xys, (#xys)^the.Tiny, the.epsilon*sd)
      for _,eg in pairs(i.egs) do 
        eg.cooked[col]= bin(eg.raw[col], i.divs[col]) end end end 
  return i end

function div(xys,tiny,epsilon,     one,all,merged,merge)
  function merged(a,b,an,bn,      c)
    c={}
    for x,v in pairs(a) do c[x] = v end
    for x,v in pairs(b) do c[x] = v + (c[x] or 0) end
    if ent(c)*.99 <= (an*ent(a) + bn*ent(b))/(an+bn) then return c end 
  end ------------------------ 
  function merge(b4)
    local j,tmp = 0,{}
    while j < #b4 do
      j = j + 1
      local now, after = b4[j], b4[j+1]
      if after then
        local simpler = merged(now.has,after.has, now.n,after.n)
        if simpler then   
          now = {lo=now.lo, hi=after.hi, n=now.n+after.n, has=simpler} 
          j = j + 1 end end
      push(tmp,now) end 
    return #tmp==#b4 and b4 or merge(tmp) -- recurse until nothing merged
  end ------------------------ 
  one = {lo=xys[1].x, hi=xys[1].x, n=0, has={}}
  all = {one}
  for j,xy in pairs(xys) do
    local x,y = xy.x, xy.y
    if   j< #xys-tiny and x~= xys[j+1].x and one.n> tiny and one.hi-one.lo>epsilon
    then one = push(all, {lo=one.hi, hi=x, n=0, has={}}) 
    end
    one.n  = 1 + one.n
    one.hi = x
    one.has[y] = 1 + (one.has[y] or 0); end
  return merge(all) end 

-- .___.            
--   |  ._. _  _  __
--   |  [  (/,(/,_) 
local splitter,worth,tree,count,keep,tree 

function count(t,at)  t=t or {}; t[at]=1+(t[at] or 0); return t  end
function keep(t,at,x) t=t or {}; t[at]=t[at] or {}; push(t[at],x); return t  end

function splitter(xs, egs) 
  function worth(at,_,    xy,n,x,xpect)
    xy,n = {}, 0
    for _,eg in pairs(egs) do
      x = eg.cooked[at]
      if x ~= "?" then 
        n=n+1
        xy[x] = count(xy[x] or {}, eg.klass) end end
    return {at, sum(xy, function(t) local e,n1=ent(t); return n1/n* e end)} end
  return sort(map(xs, worth),seconds)[1][1] end

function tree(xs, egs)
  local here,at,splits,counts
  for _,eg in pairs(egs) do counts=count(counts,eg.klass) end
  here = {mode=mode(counts), n=#egs, kids={}}
  if #egs > 2*the.Stop then 
    at = {},splitter(xs,egs)
    for _,eg in pairs(egs) do splits=keep(splits,eg.cooked[at],eg) end
    for val,split in pairs(splits) do 
       if #split < #egs then 
         push(here.kids, {at=at,val=x,sub=tree(xs,split)}) end end end
  return here end

-- function show(tree,pre)
--   pre = pre or ""
--   if tree.sub then
--     say("%s %s ",pre)
--     for _,one in  pairs(tree.sub) do
--       say("%s %s=%s", pre, one.at or "", one.val or "")
--       show(one.sub,pre.."|.. ") end end
--   else x end end

-- .___.       ,    
--   |   _  __-+- __
--   |  (/,_)  | _) 
local go={} 
function go.ls() 
  print("\nlua "..arg[0].." -todo ACTION\n\nACTIONS:")
  for _,k in pairs(keys(go)) do  print("  -todo",k) end end
function go.the() shout(the) end
function go.bad(  s) assert(false) end
function go.ing() return true end
function go.ordered(  s,n) 
  s = ordered(slurp())
  n = #s.egs
  shout(s.heads)
  for i=1,15 do shout(s.egs[i].raw) end
  print("#")
  for i=n,n-15,-1 do shout(s.egs[i].raw) end end

function go.bins(    s)
  s= discretize(ordered(slurp())) 
  for m,div in pairs(s.divs) do 
    print("")
    for n,div1 in pairs(div) do print(m, n,out(div1)) end end 
  shout(s.egs[1])
  end

--  __. ,        ,            
-- (__ -+- _.._.-+- ___ . .._ 
-- .__) | (_][   |      (_|[_)
--                        |  
the(go)
