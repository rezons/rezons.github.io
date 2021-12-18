local the =require"tiny0"[[
lua hint.lua [OPTIONS]

A small sample multi-objective optimizer / data miner.
(c)2021 Tim Menzies <timm@ieee.org> unlicense.org

OPTIONS:
  -best     X   Best examples are in 1..best*size(all)    = .05
  -debug    X   run one test, show stackdumps on fail     = ing
  -file     X   Where to read data                        = ../../data/auto93.csv
  -h            Show help                                 = false
  -seed     X   Random number seed;                       = 10019
  -Stop     X   Create subtrees while at least 2*stop egs =  4
  -Tiny     X   Min range size = size(egs)^tiny           = .5
  -todo     X   Pass/fail tests to run at start time      = ing
                If "all" then run all.
  -epsilon  X   ignore differences under epsilon*stdev    = .35  ]]

--------------------------------------------------------------------------------
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

--------------------------
local slurp,sample,ordered,clone
function slurp(out)
  for eg in csv(the.file) do out=sample(eg,out) end
  return out end

function clone(i, inits,     out)
  out = sample(i.heads)
  for _,eg in pairs(inits or {}) do out = sample(eg,out) end
  return out end

function sample(eg,i)
  local numeric,independent,dependent,head,data,datum
  i = i or {n=0,xs={},nys=0,ys={},lo={},hi={},w={},egs={},heads={},divs={}} 
  function head(n,x)
    function numeric()     i.lo[n]= math.huge; i.hi[n]= -i.lo[n] end 
    function independent() i.xs[n]= x end
    function dependent()
      i.w[n]  = x:find"-" and -1 or 1
      i.ys[n] = x
      i.nys   = i.nys+1 end
    if not x:find":" then
      if x:match"^[A-Z]" then numeric() end 
      if x:find"-" or x:find"+" then dependent() else independent() end end
    return x end
  function data(eg) return {raw=eg, cooked=copy(eg)} end
  function datum(n,x)
    if x ~= "?" then
      if i.lo[n] then 
        i.lo[n] = math.min(i.lo[n],x)
        i.hi[n] = math.max(i.hi[n],x) end end
    return x end
  eg = eg.raw and eg.raw or eg 
  if #i.heads==0 then i.heads=map(eg,head) else push(i.egs,data(map(eg,datum))) end 
  i.n = i.n + 1
  return i end

function ordered(i)
  local function better(eg1,eg2,     a,b,s1,s2)
    s1,s2=0,0
    for n,_ in pairs(i.ys) do
      a  = norm(i.lo[n], i.hi[n], eg1.raw[n])
      b  = norm(i.lo[n], i.hi[n], eg2.raw[n])
      s1 = s1 - 2.71828^(i.w[n] * (a-b)/i.nys) 
      s2 = s2 - 2.71828^(i.w[n] * (b-a)/i.nys) end
    return s1/i.nys < s2/i.nys end 
  for j,eg in pairs(sort(i.egs,better)) do 
    if j < the.best*#i.egs then eg.klass="best" else eg.klass="rest" end end
  return i end

local discretize, xys_sd, bin, div
function bin(z,divs) 
  if z=="?" then return "?" end
  for n,x in pairs(divs) do 
    if x.lo<= z and z<= x.hi then return string.char(96+n) end end end 

function discretize(i)       
  for col,_ in pairs(i.xs) do
    if i.lo[col] then
      local xys,sd = xys_sd(col, i.egs)
      i.divs[col]  = div(xys, the.tiny*#xys, the.trivial*sd)
      for _,eg in pairs(i.egs) do 
        eg.cooked[col]= bin(eg.raw[col], i.divs[col]) end end end 
  return i end

function xys_sd(col,egs,    xys,p)
  xys={}
  for _,eg in pairs(egs) do 
    local x=eg.raw[col]
    if x~="?" then push(xys, {x=x,  y=eg.klass}) end end
  xys = sort(xys, function(a,b) return a.x < b.x end) 
  p   = function(z) return xys[z*#xys//10].x end
  return xys, math.abs(p(.9) - p(.1))/2.56 end

function div(xys,tiny,trivial,     one,all,merged,merge)
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
    if   j< #xys-tiny and x~= xys[j+1].x and one.n> tiny and one.hi-one.lo>trivial
    then one = push(all, {lo=one.hi, hi=x, n=0, has={}}) 
    end
    one.n  = 1 + one.n
    one.hi = x
    one.has[y] = 1 + (one.has[y] or 0); end
  return merge(all) end 

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
  if #egs > 2*the.stop then 
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

--------------------------------------------------------------------------------
local go={} 
function go.ordered(  s,n) 
  s = ordered(slurp())
  n = #s.egs
  shout(s.heads)
  for i=1,15 do shout(s.egs[i].raw) end
  print("#")
  for i=n,n-15,-1 do shout(s.egs[i].raw) end end

function go.the() shout(the) end
function go.bad(  s) assert(false) end
function go.ing() return true end

the(go)
