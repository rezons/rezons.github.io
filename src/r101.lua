local b4={}; for k,v in pairs(_ENV) do b4[k]=v end

-- # R101: an example reasonable algorithm
-- <img align=right width=300 src="r101.jpg">
-- - Find two remote points.
-- - Divide data samples in two (using distance to these pairs) 
-- - Apply some _reasons_ over the `x` or `y` variables to favor one half. 
-- - Find and print the variable range that selects for best.
-- - Cull the rest.
-- - Repeat.
-- <br clear=all>
local csv,map,isa,obj,add,out,shout,str
local push=table.insert

-- ## Settings, CLI
-- Check if `the` config variables are updated on the command-line interface.
local function cli(flag, b4)
  for n,word in ipairs(arg) do if word==flag then
    return (b4==false) and true or tonumber(arg[n+1]) or arg[n+1]  end end 
  return b4 end

the = {p=    cli("-p",2),
       far=  cli("-f",.9)
      }

-- ## Classes
-- Columns of data either `Num`eric, `Sym`bolic, or things we are going to `Skip` over.
-- `Sample`s hold rows of data, summarized into `Cols` (columns).
function obj(name,   k) k={_name=name,__tostring=out}; k.__index=k; return k end
local Num,Skip,Sym = obj"Num", obj"Skip", obj"Sym"
local Cols,Sample  = obj"Cols", obj"Sample"

-- ## Initialization
function Skip.new(c,s) return isa(Skip,{n=0,txt=s,at=c}) end
function Sym.new(c,s) return isa(Sym,{n=0,txt=s,at=c,has={},most=0,mode="?"}) end
function Cols.new(t) return isa(Cols,{names={},all={}, xs={}, ys={}}):init(t) end
function Sample.new(file) return isa(Sample,{rows={},cols=nil}):init(file) end

function Num.new(c,s) 
  s = s or ""
  return isa(Num,{n=0,s=s,c=c, hi=-1E364,lo=1E64,has={},
                  w=s:find"+" and 1 or s:find"-" and -1 or 0}) end

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
function Cols:init(t,      u,is,goalp,new) 
  function is(s) return s:find":" and Skip or s:match"^[A-Z]" and Num or Sym end
  function goalp(s) return s:find"+" or s:find"-" or s:find"!" end
  self.names = t
  for at,name in pairs(t) do
    new = is(name).new(at,name) 
    push(self.all, new)
    if not name:find":" then
      push(goalp(name) and self.ys or self.ys, new) end end 
  return self end

-- ## Updating
-- Skip any unknown cells. Otherwise, add one to the counter `n` and do the update.
function add(i,x) if x~="?" then i.n = i.n+1; i:add(x) end; return x end

-- Don't bother updating some columns.
function Skip:add(x) return end

-- Track the numerics seen so far, as well as the `lo,hi` values.
function Num:add(x)
  self.has[1+#self.has]=x
  self.lo=math.min(x,self.lo); self.hi=math.max(x,self.hi) end

-- Update the symbol counts and, maybe, the most commonly seen symbol (the `mode`).
function Sym:add(x)
  self.has[x] = 1+(self.has[x] or 0) 
  if self.has[x] > self.most then self.most, self.mode=self.has[x], x end end

-- Row1 creates the column headers. All other rows update the summaries in the column headers.
function Sample:add(t,     adder)
  function adder(c,x) return add(self.cols.all[c],x) end
  if   not self.cols 
  then self.cols=Cols.new(t) 
  else push(self.rows, map(t, adder)) end end

-- ## Distance
function Sym:dist(x,y) 
  return  x==y and 0 or 1 end

function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return math.abs(x-y) end

function Sample:dist(row1,row2,cols)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, the.p
  for _,col in pairs(cols or self.cols.xs) do
    x,y = row1[col.at], row2[col.at]
    inc = x=="?" and y=="?" and 1 or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end

-- ## Clustering
function Sample:dists(row1,    t)
  t={}
  -- map XXX
  for _,row2 in pairs(self.rows) do 
    push(t, {self:dist(row1,row2),row2}) end
  table.sort(t, function (x,y) return x[1] < y[1] end)
  return t end

function Sample:far(row1,    tmp)
  tmp = self:dists(row1)
  return tmp[the.far * #tmp // 1] end

function Sample:seperate(rows,         one,two,c,a,b,mid)
  one  = self:far(any(rows))
  two  = self:far(one)
  c    = self:dist(one,two)
  -- map
  for _,row in pairs(rows) do
    a  = self:dist(one)
    b  = self:dist(two)
    row.projection = (a^2 + c^2 - b^2) / (2*c) -- from task2
  end
  rows = sorted(rows,"projection") -- sort on the "projection" field
  mid  = #rows//2
  return slice(rows,1,mid), slice(rows,mid+1) end -- For Python people: rows[1:mid], rows[mid+1:]

-- ------------------------------
-- ## Lib
-- ### Printing
function shout(t) print(#t>0 and str(t) or out(t)) end

function out(t)
  local function show(k)     k=tostring(k); return k:sub(1,1) ~= "_" end 
  local function pretty(_,v) return string.format(":%s %s", v[1], v[2]) end
  local u={}; for k,v in pairs(t) do if show(k) then u[1+#u] = {k,v} end end
  table.sort(u, function(x,y) return x[1] < y[1] end)
  return (t._name or "")..str(map(u, pretty)) end 

function str(t,      u)
  u={}; for _,v in ipairs(t) do u[1+#u] = tostring(v) end 
  return '{'..table.concat(u, ", ").."}"  end

-- ### Meta
function map(t,f,      u) 
  u={};for k,v in pairs(t) do u[k]=f(k,v) end; return u end

function isa(mt,t) return setmetatable(t, mt) end

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

-- ## Examples
local Eg = {}
function Eg.num1(      n)
  n=Num.new()
  for _,x in pairs{10,20,30,40} do add(n,x) end
  shout(n) end

function Eg.sym(      s)
  local s=Sym.new()
  for _,x in pairs{10,10,10,10,20,20,30} do add(s,x) end
  shout(s.has) end

function Eg.sample(      s)
  local s=Sample.new()
  shout(s)
  local s=Sample.new("../data/auto93.csv")
  shout(s.cols.all[3]) end

-- ## Fin.
-- Report any rogue globals
for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v))  end end 
-- Return.
return {the=the,sample=Sample,egs=Egs}

