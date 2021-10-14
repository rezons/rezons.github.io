local b4={}; for k,v in pairs(_ENV) do b4[k]=v end

local csv,map,isa,obj,add,out,shout,str
local push=table.insert

-- ## Settings, CLI
local function cli(flag, b4)
 for n,word in ipairs(arg) do if word==flag then
   return (b4==false) and true or tonumber(arg[n+1]) or arg[n+1]  end end 
 return b4 end

the = {p=    cli("-p",2),
       some= cli("-s",256),
       far=  cli("-f",.9)
      }

-- ## Classes
function obj(name,   k) k={_name=name,__tostring=out}; k.__index=k; return k end
local Num,Skip,Sym = obj"Num", obj"Skip", obj"Sym"
local Cols,Sample  = obj"Cols", obj"Sample"

-- ## Initialization

function Skip.new(at,txt) return isa(Skip,{n=0,txt=txt,at=at}) end
function Sym.new(at,txt)  return isa(Sym,{n=0,txt=txt,at=at,has={},most=0,mode="?"}) end
function Cols.new(t)      return isa(Cols,{names={},all={}, xs={}, ys={}}):init(t) end
function Sample.new(file) return isa(Sample,{rows={},cols=nil}):init(file) end

function Num.new(at,txt) 
  txt = txt or ""
  return isa(Num,{n=0,txt=txt,at=at, hi=-1E21,lo=1E31,has={},
                  w=txt:find"+" and 1 or txt:find"-" and -1 or 0}) end

-- ## Initialization Support
function Sample:init(file) 
  if file then for row in csv(file) do self:add(row) end end
  return self end

function Cols:init(t,      u,is,goalp) 
  function is(s) return s:find":" and Skip or s:match"^[A-Z]" and Num or Sym end
  function goalp(s) return s:find"+" or s:find"-" or s:find"!" end
  self.names = t
  for at,name in pairs(t) do
    local new = is(name).new(at,name) 
    push(self.all, new)
    if not name:find":" then
      push(goalp(name) and self.ys or self.ys, new) end end 
  return self end

-- ## Updating
function add(i,x) if x~="?" then i.n = i.n+1; i:add(x) end; return x end

function Skip:add(x) return end

function Num:add(x)
  self.has[1+#self.has]=x
  self.lo=math.min(x,self.lo); self.hi=math.max(x,self.hi) end

function Sym:add(x)
  self.has[x] = 1+(self.has[x] or 0) 
  if self.has[x] > self.most then self.most, self.mode=self.has[x], x end end

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
function Sample:dists(row1,rows,cols,    t)
  rows = rows or top(the.some, shuffle(self.rows))
  t={}
  for _,row2 in pairs(rows) do 
    push(t, {self:dist(row1,row2,cols),row2}) end
  table.sort(t, function (x,y) return x[1] < y[1] end)
  return t end

function Sample:far(row1,rows,cols,    tmp)
  tmp = self:neighbors(row1,rows,cols)
  return tmp[the.far * #tmp // 1] end

-- ------------------------------
-- Misc
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

function map(t,f,      u) 
  u={};for k,v in pairs(t) do u[k]=f(k,v) end; return u end

function isa(mt,t) return setmetatable(t, mt) end

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

local n=Num.new()
for _,x in pairs{10,20,30,40} do add(n,x) end
shout(n)

local s=Sym.new()
for _,x in pairs{10,10,10,10,20,20,30} do add(s,x) end
shout(s.has)

local s=Sample.new()
shout(s)
local s=Sample.new("../data/auto93.csv")
shout(s.cols.all[3])

for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v))  end end 
