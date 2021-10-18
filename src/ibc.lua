-- vim: ft=lua ts=2 sw=2 et:
--[[
    __                           ___                        
 __/\ \                         /\_ \                       
/\_\ \ \____    ___             \//\ \    __  __     __     
\/\ \ \ '__`\  /'___\             \ \ \  /\ \/\ \  /'__`\   
 \ \ \ \ \L\ \/\ \__/       __     \_\ \_\ \ \_\ \/\ \L\.\_ 
  \ \_\ \_,__/\ \____\     /\_\    /\____\\ \____/\ \__/.\_\
   \/_/\/___/  \/____/     \/_/    \/____/ \/___/  \/__/\/_/
--]]
local b4={}; for k,v in pairs(_ENV) do b4[k]=v end

-- # IBC: iterative bi-clustering
-- (c) Tim Menzies 2021, unlicense.org
-- - Find a pair of two faraway points.
-- - Divide data samples in two (using distance to these pairs) 
-- - Apply some _reasons_ over the `x` or `y` variables to favor one half. 
-- - Find and print the variable range that selects for best.
-- - Cull the rest.
-- - Repeat.
local the, csv,map,isa,obj,add,out,shout,str,keys,xpect,goods,sort,any,first,fmt
local push=table.insert

-- ## Settings, CLI
-- Check if `the` config variables are updated on the command-line interface.
local function cli(flag, b4)
  for n,word in ipairs(arg) do if word==flag then
    return (b4==false) and true or tonumber(arg[n+1]) or arg[n+1]  end end 
  return b4 end

local function about() return {
  bw=    cli("-B",  false),
  bins=  cli("-b", .5),
  cohen= cli("-c", .35),
  far=   cli("-f", .9),
  p=     cli("-p" , 2),
  seed=  cli("-S",  937162211),
  todo=  cli("-t",  "ls"),
  wild=  cli("-W",  false) } end

-- ## Classes
-- Columns of data either `Num`eric, `Sym`bolic, or things we are going to `Skip` over.
-- `Sample`s hold rows of data, summarized into `Cols` (columns).
function obj(name,   k) 
  k={_is=name,__tostring=function(x) return out(x) end}; k.__index=k
  return k end
local Num,Skip,Sym = obj"Num", obj"Skip", obj"Sym"
local Cols,Sample  = obj"Cols", obj"Sample"
local Range = obj"Range"

-- ## Initialization
function Cols.new(t)      return isa(Cols,{names={},all={}, xs={}, ys={}}):init(t) end
function Sample.new(file) return isa(Sample,{rows={},cols=nil}):init(file) end
function Skip.new(c,s)    return isa(Skip,{n=0,txt=s,at=c or 1}) end
function Sym.new(c,s)  
  return isa(Sym,{n=0,txt=s,at=c or 1,has={},most=0,mode="?"}) end

function Num.new(c,s) 
  s = s or ""
  return isa(Num,{n=0,txt=s,at=c or 1, hi=-1E364,lo=1E64,has={},
                  w=s:find"+" and 1 or s:find"-" and -1 or 0}) end

function Sample:clone(inits)
  s=Sample.new({self.cols.names})
  for _,row in pairs(inits or {}) do s:add(row) end
  return s end

-- ## Initialization Support
-- Samples can be initialized from csv files
function Sample:init(file) 
  if file then for row in csv(file) do self:add(row) end end
  return self end

-- `Cols` are initialized from the names in row1. e.g. Upper case
-- names are numeric, anything with `:` is skipped over (and all other columns
-- are symbolic. Columns have roles. 
-- - Some columns are goals to be minimized or maximized (those marked with a `+`,`-`);
-- - Some columns are goals to be predicted (marked with `!`);
-- - All the goals are dependent `y` variables;
-- - Anything that is not a goal is a dependent `x` variable.
function ignore(s) return name:find":" end
function goalp(s) return s:find"+" or s:find"-" or s:find"!" end
function nump(s) return s:match"^[A-Z]" end
function is(s) return ignore(s) and Skip or nump(s) and Num or Sym end

function Cols:init(t,      u,new) 
  self.names = t
  for at,name in pairs(t) do
    new = is(name).new(at,name) 
    push(self.all, new)
    if not ignore(name) then
      push(goalp(name) and self.ys or self.ys, new) end end 
  return self end

-- ## Updating
-- Skip any unknown cells. Otherwise, add one to the counter `n` and do the update.
function add(i,x,n) 
  n = n or 1
  if x~="?" then i.n = i.n + n; i:add(x,n) end; return x end

-- Don't bother updating some columns.
function Skip:add(x,n) return end

-- Track the numerics seen so far, as well as the `lo,hi` values.
function Num:add(x,n)
  for _ = 1,n do self.has[1+#self.has] = x end
  self.lo = math.min(x,self.lo); self.hi = math.max(x,self.hi) end

-- Update the symbol counts and, maybe, the most commonly seen symbol (the `mode`).
function Sym:add(x,n)
  n = n or 1
  self.has[x] = 1+(self.has[x] or 0) 
  if self.has[x] > self.most then self.most, self.mode=self.has[x], x end end

-- Row1 creates the column headers. All other rows update the summaries in the column headers.
function Sample:add(t,     adder)
  function adder(c,x) return add(self.cols.all[c],x) end
  if   not self.cols 
  then self.cols=Cols.new(t) 
  else push(self.rows, map(t, adder)) end end

-- ## Query
function Sym:br(other,     goal)
  local b,r, B, R = 0, 0, 1E-31, 1E32
  goal = goal == nil and true or goal
  for _,counts in pairs{self.has, other.has} do
    for k,v in pairs(counts) do if k==goal then B=B+v else R=R+v end end end
  for k,v in pairs(self.has) do if k==goal then b=b+v else r=r+v end end
  return b/B, r/R end  

function Sym:novel(other) b,r=self:br(other); return 1/(b+r) end
function Sym:good(other)  b,r=self:br(other); return b<=r and 0 or b^2/(b+r) end
function Sym:bad(other)   b,r=self:br(other); return r<=b and 0 or r^2/(b+r) end
  
-- Standard deviation.
function Sym:spread(   sum1,sum2,mu)
  sum1=0; for _,x in pairs(self.has) do sum1 = sum1 + x end
  mu = sum1/#self.has
  sum2=0; for _,x in pairs(self.has) do sum2 = sum2 + (x-mu)^2 end 
  return math.sqrt(sum2 / (#self.has - 1)) end 

-- Entropy.
function Num:spread(t,    e)
  e = 0
  for _,v in pairs(self.has) do 
    if v>0 then e = e - v/self.n * math.log(v/self.n,2) end end
  return e end

-- ## Ranges
function halve(s, rows0, rows1, out)
  function xys0(at)
    local t, all = {}, Sym.new()
    for _,x in pairs(rows0) do 
      if x[at]~="?" then all:add(x[at]); push(t,{x[at],true}) end end
    for _,x in pairs(rows1) do 
      if x[at]~="?" then all:add(x[at]); push(t,{x[at],false}) end end
    return t, all 
  end -----------------------------
  for _,col in pairs(s.cols.all) do
    if not ignore(col.txt) and not goalp(col.txt) then
      out = out or {-1,col.at,"="}
      xys, all = xyz0(at)
      if   nump(col.txt) 
      then chopNum(sort(xys,first), Eg[fun], all, out) 
      else chopSym(xys,             Eg[fun], all, out) end end end end 

-- {{a,true}, {a, true},  {b, false}, {c, false}}
function chopSym(xys, fun, all, out)
  local t,x,y,old,val
  t = {}
  for _,xy in pairs(xys) do 
    x,y = xy[1], xy[2]
    old = t[x] or Sym.new()
    old:add(y) end
  for x,one in pair(t) do
    val = fun(one,all)
    if val > out[1] then out = {val,out.at,"=",x} end end
  return out end

function chopNum(xys, fun, rhs, out)
  local start, stop = xys[1][1], xys[#xys][1]
  local enough      = (#xy)^the.bins 
  local left, right = what.new(), what.new()
  for i,xy in pairs(xys) do
    x,y = xy[1], xy[2]
    lo:add(x)
    hi:add(y,-1)
    if i > enough and #xys - i > enough then
      los = fun(lhs, rhs)
      his = fun(rhs, lhs)
      if los>his and los>out[1] then out={los,out.at,"<", x} end
      if his>los and his>out[1] then out={his,out.at,">",x} end end end 
  return out end
    
-- ------------------------------
-- ## Lib
-- ### Meta
function map(t,f,      u) 
  u={};for k,v in pairs(t) do u[k]=f(k,v) end; return u end

function keys(t,   ks)
  ks={}; for k,_ in pairs(t) do ks[1+#ks]=k end; return sort(ks) end
 
function isa(mt,t) return setmetatable(t, mt) end

-- ### Lists
-- Return the first item in a list.
function first(t,u) return t[1] < u[1]  end
-- Return any item from a lost
function any(t)   return t[1 + #t*math.random()//1] end
-- Sort a list using a function `f`.
function sort(t,f) table.sort(t,f); return t end

-- ### Expected value
function xpect(one,two)
  return (one.n*one:var() + two.n*two:var()) / (one.n + two.n) end

-- ### Printing
-- handy short cut
fmt = string.format

-- colored strings
function red(s)    return the.bw and s or "\27[1m\27[31m"..s.."\27[0m" end
function green(s)  return the.bw and s or "\27[1m\27[32m"..s.."\27[0m" end
function yellow(s) return the.bw and s or "\27[1m\27[33m"..s.."\27[0m" end
function blue(s)   return the.bw and s or "\27[1m\27[36m"..s.."\27[0m" end

-- Print a generated string
function shout(x) print(out(x)) end
-- Generate a string, showing sorted keys, hiding secretes (keys starting with "_")

function out(t,         u,secret,brace,out1,show)
  function secret(s) return tostring(s):sub(1,1)~= "_" end
  function brace(t)  return "{"..table.concat(t,", ").."}" end
  function out1(_,v) return out(v) end
  function show(_,v) return fmt(":%s %s", blue(v[1]), out(v[2])) end
  if     type(t)=="function" then return "#`()"
  elseif type(t)~="table" then return tostring(t) 
  elseif #t>0 then return brace(map(t, out1),", ") 
  else   u={}
         for k,v in pairs(t) do if not secret(k) then u[1+#u] = {k,v} end end
         return yellow(t._is or "")..brace(map(sort(u,first), show)) end 

-- ### Files
function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if  #t > 0
      then for j,x in pairs(t) do t[j] = tonumber(x) or x end
           return t end
    else io.close(stream) end end end

-- ### Unit tests
local Eg, fails = {}, 0
local function go(x,     ok,msg) 
  the = about()
  math.randomseed(the.seed) 
  if the.wild then return Eg[x][2]() end
  ok, msg = pcall(Eg[x][2])
  if   ok 
  then print(green("PASS: "),x) 
  else print(red("FAIL: "),x,msg); fails=fails+1 end end

-- ## Examples
Eg.ls={"list all examples", function () 
  map(keys(Eg), function (_,k) 
  print(fmt("lua ibc.lua -t %-10s : %s",k,Eg[k][1])) end) end}

Eg.all={"run all examples", function() 
  map(Eg,function(k,_) return k ~= "all" and go(k) end) end}

Eg.config={"show options", function () shout(the) end}

Eg.num={"demo Nums", function (    n)
  n=Num.new()
  for _,x in pairs{10,20,30,40} do add(n,x) end
  print(n) end}

Eg.sym={"demo syms", function(      s)
  local s=Sym.new()
  for _,x in pairs{"a","a","a","a","b","b","c"} do add(s,x) end
  print(s) end}

Eg.sample={"demo sample", function(     s)
  local s=Sample.new()
  shout(s)
  local s=Sample.new("../data/auto93.csv")
  shout(s.cols.all[3]) end}

-- ## Start-up
go(about().todo) 
for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v)) end end 
os.exit(fails) 
