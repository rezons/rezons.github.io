local the, help = {}, [[
lua bchop.lua [OPTIONS]

A small sample multi-objective optimizer / data miner.
(c)2021 Tim Menzies <timm@ieee.org> unlicense.org

OPTIONS:
  -best     X   Best examples are in 1..best*size(all)    = .05
  -debug    X   run one test, show stackdumps on fail     = none
  -file     X   Where to read data                        = ../../data/auto93.csv
  -h            Show help                                 = false
  -max      X   max sample size                           = 256
  -seed     X   Random number seed;                       = 10019
  -stop     X   Create subtrees while at least 2*stop egs =  4
  -tiny     X   Min range size = size(egs)^tiny           = .5
  -todo     X   Pass/fail tests to run at start time      = nome
                If "all" then run all.
  -top      X   top range                                 = 20
  -trivial  X   ignore differences under trivial*stdev    = .35  ]]

local b4={};for k,v in pairs(_ENV) do b4[k]=k end
local function rogues() 
  for k,v in pairs(_ENV) do if not b4[k] then print("?: ",k) end end end

-------------------------------------------------------------------------------
local randi,rand,Seed -- remember to set seed before using this
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647
  return lo + (hi-lo) * Seed / 2147483647 end

local norm,shuffle,push,pop
pop = function(t) return table.remove(t) end
push= function(t,x) table.insert(t,x); return x end
norm= function(lo,hi,x) return math.abs(lo-hi)<1E-32 and 0 or (x-lo)/(hi-lo) end

function shuffle(t,   j)
  for i=#t,2,-1 do j=lib.randi(1,i); t[i],t[j]=t[j],t[i] end; return t end
-------------------------------------------------------------------------------
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
  function datum(n,x)
    if x ~= "?" then
      if i.lo[n] then 
        i.lo[n] = math.min(i.lo[n],x)
        i.hi[n] = math.max(i.hi[n],x) end end
    return x end
  if #i.heads==0 then i.heads=map(eg,head) else push(i.egs,map(eg,datum)) end 
  i.n = i.n + 1
  return i end

function ordered(i,egs)
  local function left_is_best(left,right,     a,b,lefts,rights)
    lefts,rights=0,0
    for n,_ in pairs(i.ys) do
      a  = norm(i.lo[n], i.hi[n], left[n])
      b  = norm(i.lo[n], i.hi[n], right[n])
      lefts  = lefts  - 2.71828^(i.w[n] * (a-b)/i.nys) 
      rights = rights - 2.71828^(i.w[n] * (b-a)/i.nys) end
    return lefts/i.nys < rights/i.nys end 
  return sort(egs or i.egs, left_is_best) end

function dist(i,eg1,eg2)
  function dist1(lo,hi,a,b)
    if lo then 
      if     a=="?" then b=norm(lo,hi,b); a = b>.5 and 0 or 1
      elseif b=="?" then a=norm(lo,hi,a); b = a>.5 and 0 or 1
      else   a,b = norm(lo,hi,a), norm(lo,hi,b) end
      return abs(a-b) 
    else 
      return a==b and 0 or 1 end end
  d,n = 0,0
  for col,_ in pairs(i.xs) do
    a,b = eg1[col], eg2[col]
    inc = a=="?" and b=="?" and 1 or dist1(i.lo[col],i.hi[col],a,b)
    d   = d + inc^it.P
    n   = n + 1 end
  return (d/n)^(1/it.P) end

function hint(i,egs,rest,min)
  local function nearest(eg) 
    return sort(map(scoreds,function(rank,scored) 
             return {rank+dist(i,eg,scored)/10^6,eg} end),firsts)[1] end
  rest= rest or {}
  egs = egs or shuffle(i.egs)
  min = min or (#egs)^0.5
  if #egs <= 2*min then
    return egs,rest
  else
    scoreds={} -- the.hints=4
    for i=1,the.hints do push(scoreds, pop(egs)) end -- grab four things
    scroreds = ordered(i,scroreds) -- sorting them on y
    for pos,rank_eg in pairs(sort(map(egs,nearest,firsts))) do
      if pos <#scored/2 then push(best, rank_eg[2]) else push(rest, rank_eg[2]) end end
    hint(i,best,rest,min) end end 
  
  
function pick(i)
  local r   = rand()
  for j=#i.egs, #i.egs-the.top, -1  do
    r  = r - (the.top + 1 - j)/(the.top*(the.top + 1)/2)
    if r <=0 then return i.egs[j] end end 
  return i.egs[#i.egs] end
 
function generate(i) 
  local out,a,b,c = {}, pick(i), pick(i), pick(i) 
  for n,_ in pairs(i.xs) do
    out[n] = a[n]
    if rand() < the.cf then
      if   i.lo[n] 
      then out[n] = out[n] + the.f*(b[n] - c[n])
      else out[n] = rand()<0.5 and b[n] or c[n] end end end
  return out end

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
--
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
function go.none() return true end

-- Run demos, each time resetting random seed and the global config options.
-- Return to the operating system then number of failing demos.
local function main(it) 
  local fails, defaults, reset = 0, copy(the)
  function reset(x) Seed=the.seed or 10019; the= copy(defaults) end
  reset()
  go[ the.wild ]()
  for _,it in pairs(the.todo=="all" and keys(go) or {the.todo}) do
    if type( go[it] ) ~= "function" then return print("UNKNOWN:",it) end
    reset()
    ok,msg = pcall( go[it] )
    if ok 
    then print(color(32,"PASS"),it) 
    else fails=fails+1; print(color(31,"FAIL"),it,msg) end end 
  for k,v in pairs(_ENV) do if not b4[k] then print("?rogue: ",k) end end 
  os.exit(fails) end

  -- local s=discretize(ordered(slurp()))
  -- for col,divs in pairs(s.divs) do
  --    print("")
  --    for _,div in pairs(divs) do
  --      print(col,out(div)) end end end

-------------------------------------------------------------------------------
-- Make 'the' options array from help string and any updates from command line.
(help or ""):gsub("^.*OPTIONS:",""):gsub("\n%s*-([^%s]+)[^\n]*%s([^%s]+)",
   function(flag,x) 
     for n,word in ipairs(arg) do if word==("-"..flag) then 
       x = x=="false" and "true" or tonumber(arg[n+1]) or arg[n+1] end end 
     if x=="false" then x=false elseif x=="true" then x=true end
     the[flag]=x end)

if the.h then print(help) else main() end
