local the,help = {}, [[
lua 2tree.lua [OPTIONS]

Tree learner (binary splits on numierics
(c)2021 Tim Menzies <timm@ieee.org> unlicense.org

OPTIONS:
  -best     X   Best examples are in 1..best*size(all)    = .2
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

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
-- .  .       
-- |\/|* __ _.
-- |  ||_) (_.
local same
same= function(x,...) return x end
local push,sort
push= function(t,x) table.insert(t,x); return x end
sort= function(t)   table.sort(t);     return t end
ones= function(a,b) return a[1] < b[1] end

local copy,keys,map
copy=function(t,    u) u={};for k,v in pairs(t) do u[k]=v          end; return u       end
keys=function(t,    u) u={};for k,_ in pairs(t) do u[1+#u]=k       end; return sort(u) end
map =function(t,f,  u) u={};for k,v in pairs(t) do u[1+#u] =f(k,v) end; return u       end
sum =function(t,f,  n) n=0 ;for _,v in pairs(t) do n=n+(f or same)(v) end; return n    end

local hue,shout,out
hue  = function(n,s) return string.format("\27[1m\27[%sm%s\27[0m",n,s) end
shout= function(x) print(out(x)) end

function out(t,   u,key,val)
  function key(_,k) return string.format(":%s %s", k, out(t[k])) end
  function val(_,v) return out(v) end
  if type(t) ~= "table" then return tostring(t) end
  u = #t>0 and map(t, val) or map(keys(t), key) 
  return "{"..table.concat(u," ").."}" end 

local coerce,csv
function coerce(x)
  if x=="true"  then return true  end
  if x=="false" then return false end
  return tonumber(x) or x end

function csv(file,   x)
  file = io.input(file)
  return function(   t,tmp)
    x  = io.read()
    if x then
      t={};for y in x:gsub("[\t ]*",""):gmatch"([^,]+)" do push(t,coerce(y)) end
      if #t>0 then return t end 
    else io.close(file) end end end

num= function(i) return {n=0, mu=0, m2=0, lo=math.huge, hi= -math.huge} end
sd = function(i) return i.n<2 and 0 or (i.m2/(i.n-1))^0.5 end 

function sub(i,x,  d) i.n=i.n-1; d=x-i.mu; i.mu=i.mu-d/i.n; i.m2=i.m2-d*(x-i.mu) end
function add(i,x,  d) i.n=i.n+1; d=x-i.mu; i.mu=i.mu+d/i.n; i.m2=i.m2+d*(x-i.mu) 
  i.lo = math.min(x, i.lo)
  i.hi = math.max(x, i.hi) end

--  __.           .   
-- (__  _.._ _ ._ | _ 
-- .__)(_][ | )[_)|(/,
--             |      
-- [5]  Returns a sample, initialized, updated
-- [1]  Self initialize (if nil, then create).
-- [2]  Read from disc file
-- [3]  First item is special (contains names of columns)
-- [4]  Other rows are the actual examples. Use these to update column headers
-- [6]  Numeric columns have an "num[n]" entry that tracks the
--      "num[n].lo" and "num[n].hi" range for each variable.
-- [7]  Columns to be minimized or maximized are dependent (listed in "ys")
-- [8]  All other columns are the independent (listed in "xs")
-- [9]  Dependent variables are minimized,maximized at weights -1,1 
--      if their name contains "-" or "+". The number of dependents ins "nys"
-- [10] Columns contain ":" are ignored
-- [11] Each example will be discretized (later) so each example holds the
--      "raw" values (not discretized) and the "cooked" examples (discretized).
local slurp,sample,ordered
function slurp(out)
  for eg in csv(the.file) do out=sample(eg,out) end --[2] 
  return ordered(out) end

function sample(eg,i)
  local head,datum
  function head(n,x)
    if not x:find":" then  -- [10]
      if x:match"^[A-Z]" then i.num[n]= num() end -- [6]]
      if x:find"-" or x:find"+" 
      then i.ys[n]    = x
           i.nys      = i.nys+1 
           i.num[n].w = x:find"-" and -1 or 1 end -- [9]
      else i.xs[n] = x end 
    return x  end
  function datum(n,x) -- [4]
    local num=i.num[n]
    if num and x ~= "?" then inc(num,x) end 
    return x end 
  --------------
  if   i 
  then push(i.egs, {cells = map(eg,datum)})             -- [4]
  else i = {xs={},nys=0,ys={},num={},egs={},divs={},heads={}}  -- [1] [3]
       i.heads = map(eg,head) end                              -- [3]
  return i end                                               -- [5]

-- [14] Returns the sample, examples sorted by their goals, each example
--      tagged with "eg.klass=best" or "eg.klass=rest" if "eg" is in the top
--     "the.best" in the sort.
-- [12] Sort each example by exploring all goals (dependent variables).
-- [15] The direction that losses the most points to best example.
--      e.g. a.b=.7,.6 and a-b is .1 (small loss) and b-a is -.1 
--      (much smaller than a or b) so a is more important than b.
-- [13] Goal differences are amplified by raining them to a power (so normalize
--      the goals first so you that calculation does not explode.
function ordered(i) 
  local function better(eg1,eg2,     a,b,s1,s2)
    s1,s2=0,0
    for n,_ in pairs(i.ys) do                     -- [12]
      local num = i.num[n]
      a  = norm(num.lo, num.hi, eg1.cells[n])       -- [13]
      b  = norm(num.lo, num.hi, eg2.cells[n])       -- [13]
      s1 = s1 - 2.71828^(num.w * (a-b)/i.nys)     -- [13] [15]
      s2 = s2 - 2.71828^(num.w * (b-a)/i.nys) end -- [13] [15]
    return s1/i.nys < s2/i.nys end                -- [15]
  for j,eg in pairs(sort(i.egs,better)) do eg.klass=j end 
  return i end                                    -- [14]

-- .___.            
--   |  ._. _  _  __
--   |  [  (/,(/,_) 
-- local splitter,worth,tree,count,keep,tree 
--

upto = function(x,y) return y<=x end 
over = function(x,y) return y>x  end
eq   = function(x,y) return x==y end

function syms(at,egs,     xy,n,x)
  xy,n = {},0
  for _,eg in pairs(egs) do
    local x=eg.cell[at]
    if  x ~= "?" then
      n = n + 1
      xy[x] = xy[x] or Num()
      add(xy[x], eg.klass) end  end
  return n,xy end

function nums(at,eps,   xy,n,x)
  xy, num = {}, Num()
  for _,eg in pairs(egs) do 
    x = eg.cell[at]
    if x ~= "?" then 
      inc(num, x)
      push(xy, {x, eg.klass}) end end
  return sort(xy,ones),num end

function binarySplit(i,at,xeps,tiny,    xy,n,x,xpect,cut,min)
  xy,ynum = nums(at,egs)
  xlo  = xy[  1][1]
  xhi  = xy[#xy][1]
  min  = sd(ynum)
  xpect= sd(ynum)
  if ynum.hi - ynum.lo > 2*tiny then
    left, right = Num(), Num()
    for k,z in  pairs(xy) do
      x,y = z[1], z[2]
      add(left,y)
      sub(right,y)
      if   k >= tiny     and k <= #xy - tiny and x ~= xy[k+1][1] and 
           x-xlo >= xeps and xhi-x >= xeps 
      then xpect = left.n/#xy*sd(left) + right.n/#xy*sd(right)
        if xpect < min then 
           cut,min = x,xpect end end end end
  return xpect, cut end

function split1(i, xeps,tiny)
  for at,txt in pairs(i.xs) do
    if i.num[at] then
      n,xy = nums(at,sd(i.num[at])*the.epsilon,(#i.egs)*the.Tiny)
      xpect,cut = binarySplit(i,at,xeps)
      if xpect < min then
        min = xpect
        cuts = {{txt=fmt("%s<=%s",txt,cut), at=at, op=upto, val=cut},
               {txt=fmt("%s>%s",txt,cut),  at=at, op=over, val=cut}} end
    else
      n,xy = syms(at,eps)
      xpect = sum(xy,function(num) return num.n/n*sd(num) end)
      if xpect < min then
        min = xpect
        cuts= map(keys(xy),function(x) return {txt=fmt("%s=%s",txt,x),
                                              at=at,op=eq,val=x} end) end end end
  return cuts end

function tree(xs, egs,lvl)
  local here,at,splits,counts
  for _,eg in pairs(egs) do counts=count(counts,eg.klass) end
  here = {mode=mode(counts), n=#egs, kids={}}
  if #egs > the.Stop then 
    splits,at = {},splitter(xs,egs)
    for _,eg in pairs(egs) do  splits=keep(splits,eg.cooked[at],eg) end
    for val,split in pairs(splits) do 
      if #split < #egs and #split > the.Stop then 
        push(here.kids, {at=at,val=val,
                         sub=tree(xs,split,(lvl or "").."|.. ")}) end end end
  return here end

local function show(i,tree)
  local vals=function(a,b) return a.val < b.val end
  local function show1(tree,pre)
    if #tree.kids==0 then io.write(fmt(" ==>  %s [%s]",tree.mode, tree.n)) end
    for _,kid in pairs(sort(tree.kids,vals))  do
        io.write("\n"..fmt("%s%s",pre, showDiv(i, kid.at, kid.val)))
         show1(kid.sub, pre.."|.. ") end  
  end ------------------------
  show1(tree,""); print("") end

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
  for i=n,n-15,-1 do shout(s.egs[i].raw) end 
  n={}; for _,eg in pairs(s.egs) do n=count(n,eg.klass) end
  shout(n)
end

function go.bins(    s)
  s= discretize(ordered(slurp())) 
  for m,div in pairs(s.divs) do 
    print("")
    for n,div1 in pairs(div) do print(m, n,out(div1)) end end 
  end

function go.tree(  s,t) 
  s = discretize(ordered(slurp()))
  show(s,tree(s.xs, s.egs))
end

--  __. ,        ,            
-- (__ -+- _.._.-+- ___ . .._ 
-- .__) | (_][   |      (_|[_)
--                        |  
help:gsub("^.*OPTIONS:",""):gsub("\n%s*-([^%s]+)[^\n]*%s([^%s]+)", 
  function(flag,x) 
    for n,word in ipairs(arg) do                  -- [2]
      if flag:match("^"..word:sub(2)..".*") then  -- [4]
        x=(x=="false" and "true") or (x=="true" and "false") or arg[n+1] end end
    the[flag] = coerce(x) end)         -- [1]

if the.h     then return print(help) end         -- [2]
if the.debug then go[the.debug]() end          -- [3]

local fails, defaults = 0, copy(the)             -- [1]
for _,todo in pairs(the.todo == "all" and keys(go) or {the.todo}) do
  the = copy(defaults)
  the.seed = the.seed or 10019                   -- [5]
  local ok,msg = pcall( go[todo] )             -- [6]
  if ok then print(hue(32,"PASS ")..todo)         
        else print(hue(31,"FAIL ")..todo,msg)
             fails=fails+1 end end -- [7]

for k,v in pairs(_ENV) do if not b4[k] then print("?:",k,type(v)) end end 
os.exit(fails) -- [8]
