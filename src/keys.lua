local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local function cli(flag,b4)
  for n,word in ipairs(arg) do if word==flag then return
    (b4==false and true) or tonumber(arg[n+1]) or arg[n+1] end end
  return b4 end 

-- ## Settings, CLI
local the = {
    data= cli("-d", "../data/auto93.csv"),
    help= cli("-h", false),
    seed= cli("-S", 937162211),
    todo= cli("-t", "ls"),
    wild= cli("-W", false) }

-- ## Short-cuts
local cat,fmt,push,sort
cat  = table.concat
fmt  = string.format
push = table.insert
sort = function(t,f) table.sort(t,f); return t end

-- ## Lists
local keys,map
function map(t,f,  u) u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 
function keys(t,   k) 
  k={}; for x,_ in pairs(t) do 
    if tostring(x):sub(1,1)~="_" then push(k,x) end end ; return sort(k) end

local out,shout
function shout(t) print(out(t)) end
function out(t,    u,f1,f2)
  if type(t) ~= "table" then return tostring(t) end
  function f1(_,x) return fmt(":%s %s",x,out(t[x])) end
  function f2(_,x) return out(x) end
  return (t._is or"").."{"..cat(#t==0 and map(keys(t),f1) or map(t,f2),", ").."}" end

-- ## Object
local isa,obj
function isa(mt,t)    return setmetatable(t, mt) end
function obj(is,   o) o={_is=is,__tostring=out}; o.__index=o; return o end

-- ## Files
local csv
function csv(file,      n,split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  n      = 0
  return function(       t)
    if   tmp 
    then t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
         for y in string.gmatch(tmp, "([^,]+)") do push(t,y) end
         tmp = io.read()
         if  #t > 0
         then for j,x in pairs(t) do t[j] = tonumber(x) or x end
              n=n+1
              return n,t end
    else io.close(stream) end end  end

local Sample=obj"Sample"
function Sample.new(file,    self) 
  self = isa(Sample,{_rows={}, sym={},hi={},lo={},weight={}}) 
  if file then for n,row in csv(file) do self:add(n,row) end end
  return self end

function Sample:header(k,v)
  if v:find"+" then self.weight[k]=  1 end
  if v:find"-" then self.weight[k]= -1 end end

function Sample:syms(k,v) 
  self.sym[k] = self.sym[k] or {}
  self.sym[k][v] = (self.sym[k][v] or 0) + 1 end

function Sample:hilos(k,v) 
  if not self.hi[k] then self.hi[k],self.lo[k]=v,v end
  if v > self.hi[k] then self.hi[k] = v end
  if v < self.lo[k] then self.lo[k] = v end end

function Sample:keep(k,v)
  if v=="?" then return v end
  if type(v)=="number" then self:hilos(k,v) else self:syms(k,v) end
  return v end

function Sample:add(n,row)
  if   n==1 
  then map(row,                 function(k,v) return self:header(k,v) end) 
  else push(self._rows, map(row, function(k,v) return self:keep(k,v)   end)) 
  end
end

function Sample:norm(col,x)
  local lo,hi = self.lo[col], self.hi[col]
  return math.abs(lo - hi) < 1E-32 and 0 or (x-lo)/(hi-lo) end

function Sample:better(row1,row2)
  local e,w,s1,s2,n,a,b,what1,what2
  local cols = self.weight
  what1, what2, n, e = 0, 0, #cols, math.exp(1)
  for at,w in pairs(cols) do
    a     = self:norm(at, row1[at])
    b     = self:norm(at, row2[at])
    what1 = what1 - e^(w * (a - b) / n)
    what2 = what2 - e^(w * (b - a) / n) end
  return what1 / n < what2 / n end

function Sample:betters()
  return sort(self._rows, function(x,y) return self:better(x,y) end) end

local s=Sample.new(the.data)
for _,row in pairs(s:betters()) do shout(row) end

-- ## Start-up
for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v)) end end 
