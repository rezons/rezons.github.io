local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local the = {stop=.5, some=8}

-- shorties
local cat,fmt,pop,push,sort,same
cat  = table.concat
fmt  = string.format
pop  = table.remove
push = table.insert
sort = function(t,f) table.sort(t,f); return t end
same = function(x,...) return x  end

-- Random
local Seed, randi, rand
Seed=937162211
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 

-- lists
local map,pick,keys,shuffle,copy,kopy
function map(t,f,  u) 
  u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 

function keys(t,  u) 
  u={};for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then push(u,k) end end
  return sort(u) end

function shuffle(t,n,    j)
  for i = #t,2,-1 do j=randi(1,i); t[i],t[j] = t[j],t[i] end
  return t end

function copy(t) return map(t, function(_,x) return x end) end

function kopy(obj,seen,    s,out)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj]   then return seen[obj] end
  s,out = seen or {},{}
  s[obj] = out
  for k, v in pairs(obj) do out[kopy(k, s)] = kopy(v, s) end
  return setmetatable(out, getmetatable(obj)) end

-- Meta
local isa,obj
function isa(mt,x) return setmetatable(x,mt) end
function obj(s, o) o={_is=s, __tostring=out}; o.__index=o; return o end

--  Printing
local shout,out
function shout(t) print(out(t)) end

function out(t,    u,f1,f2)
  function f1(_,x) return fmt(":%s %s",x,out(t[x])) end
  function f2(_,x) return out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u=#t==0 and map(keys(t),f1) or map(t,f2)
  return (t._is or"").."{"..cat(u,", ").."}" end

-- CSV reading
local csv
function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if   tmp 
    then t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
         for y in string.gmatch(tmp, "([^,]+)") do push(t,y) end
         tmp = io.read()
         if  #t > 0
         then for j,x in pairs(t) do t[j] = tonumber(x) or  x end
              return t end
    else io.close(stream) end end end

-- Cols
local Sym,Num,Skip,Cols,Sample
local klassp,skipp,goalp,nump,ako
function klassp(v) return v:find"!" end
function skipp(v)  return v:find":" end
function nump(v)   return v:match("^[A-Z]") end
function goalp(v)  return klassp(v)  or v:find"+" or v:find"-" end
function ako(v)    return (skipp(v) and Skip) or (nump(v) and Num) or Sym end

Cols= obj"Cols"
function Cols.new(lst,       self,now) 
  self = isa(Cols, {header=lst,all={},xs={},ys={},klass=nil}) 
  for k,v in pairs(lst) do
    now = ako(v).new(k,v)
    push(self.all, now)
    if not skipp(v) then 
      if klassp(v) then self.klass=now end
      push(klassp(v) and self.ys or self.xs, now) end end
  return self end

-- Sym
Sym = obj"Sym"
function Sym.new(i,s)  return isa(Sym, {at=i,txt=s,n=0,has={},mode=nil,most=0}) end
function Sym:dist(x,y) return  x==y and 0 or 1 end
function Sym:mid()     return self.mode end

function Sym:spread() 
  return sum(self.has, function(n) 
    if n>0 then return n/self.n*math.log(n/self.n,2) end end) end

function Sym:add(x)    
  if x=="?" then return x end; 
  self.n = self.n + 1
  self.has[x] = 1+(self.has[x] or 0) 
  if self.has[x] > self.most then 
     self.most,self.mode = self.has[x],x end end

-- Num
Num = obj"Num"
function Num.new(i,s) 
  return isa(Num, {at=i, txt=s, n=0, _all={}, ok=false, hi=-1E32, lo=1E32,
                   w =s:find"-" and -1 or 1}) end

function Num:add(x) 
  if x=="?" then return x end
  self.n = self.n + 1
  push(self._all, x)
  self.ok = true
  self.lo = math.min(x, self.lo) 
  self.hi = math.max(x, self.hi)  end

function Num:mid(    a) a=self:all(); return a[#a//2] end
function Num:spread( a) a=self:all(); return (a[.9*#a//1] - a[.1*#a//1])/2.56 end

function Num:all(x)
  if not self.ok then table.sort(self._all); self.ok=true; end
  return self._all end

function Num:norm(x,     lo,hi)
  lo,hi = self.lo,self.hi
  return math.abs(hi-lo)< 1E-16 and 0 or (x-lo)/(hi-lo) end

function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return math.abs(x-y) end

-- Skip
Skip= obj"Skip"
function Skip.new(i,s) return isa(Skip,{at=i,txt=s}) end
function Skip:add(x)   return x end
function Skip:mid()    return "?" end
function Skip:spread() return "?" end

-- Cols
-- Sample
local Sample= obj"Sample"
function Sample.new(src,   self) 
  self = isa(Sample, {rows={}, cols=nil}) 
  if type(src)=="string" then for   row in csv(src)   do self:add(row) end end
  if type(src)=="table"  then for _,row in pairs(src) do self:add(row) end end
  return self end 

function Sample:clone(inits,   now)
  now = Sample.new()
  now:add(self.header)
  map(inits or {}, function(_,row) print("rows",out(row)); now:add(row) print(100); end)
  return now end

function  Sample:add(lst,   add)
  function add(k,v) self.cols.all[k]:add(v); return v; end  
  print("add",out(lst))
  if   not self.cols 
  then self.cols = Cols.new(lst) 
  else push(self.rows, map(lst,add)) end end

function Sample:dist(row1,row2)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, 2
  for _,col in pairs(self.cols.xs) do
    x,y = row1[col.at], row2[col.at]
    inc = (x=="?" and y=="?" and 1) or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end

function Sample:mid(  cols) 
  return map(cols or self.cols.all, 
     function(k,x) print("!!",k,x); return x:mid() end) end

function Sample:spread(   cols) 
  return map(cols or self.cols.all, function(_,x) return x:spread() end) end

function Sample:better(row1,row2,cols)
  local n,a,b,s1,s2
  cols = cols or self.cols.ys
  s1, s2, n = 0, 0, #cols
  for _,col in pairs(cols) do
    a  = col:norm(row1[col.at])
    b  = col:norm(row2[col.at])
    s1 = s1 - 2.71828^(col.w * (a - b) / n)
    s2 = s2 - 2.71828^(col.w * (b - a) / n) end
  return s1 / n < s2 / n end

function Sample:div()
  local better,want,go
  function better(x,y) return self:better(x,y) end
  function want(row,somes)
    local closest,rowRank,tmp = 1E32,1E32,nil
    for someRank,some1 in pairs(somes) do
       tmp = self:dist(row,some1)
       if tmp < closest then closest,rowRank = tmp,someRank end end
    return rowRank <= the.some//2 
  end ------------------
  function go(stop,rows,     best,somes)
    print(#rows,stop)
    if #rows < 2*stop or #rows < 2*the.some then return rows end
    best,somes = {},{}
    for i = 1,the.some do push(somes,pop(rows)) end
    somes = sort(somes, better)
    for _,row in pairs(rows) do
      if want(row,somes) then push(best,row) end  end
    return go(stop, best) 
  end ---------------------------------------------------
  return go((#self.rows)^the.stop, shuffle(copy(self.rows))) end

-- Main
local function main(file,     s,t)
  s = Sample.new(file)
  shout(s.cols.all[1])
  print(#s.rows)
  t=s:clone(s.rows)
  print(#t.rows)
  -- shout(s.cols.ys)
  -- t=s:clone(s:div())
  -- shout(t.cols.ys)
  -- shout(t:mid(t.cols.ys))
end

main("../data/auto93.csv")

for k,v in pairs(_ENV) do if not b4[k] then print("? ",k,type(v)) end end
--for row in csv("../data/auto93.csv") do shout(row) end
