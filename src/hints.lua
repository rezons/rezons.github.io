-- ██╗  ██╗██╗███╗   ██╗████████╗███████╗
-- ██║  ██║██║████╗  ██║╚══██╔══╝██╔════╝
-- ███████║██║██╔██╗ ██║   ██║   ███████╗
-- ██╔══██║██║██║╚██╗██║   ██║   ╚════██║
-- ██║  ██║██║██║ ╚████║   ██║   ███████║
-- ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
-- Semi-supervised multi-objective optimizer
-- (c) 2021 Tim Menzies, unlicense.org

local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local the
local options = {
  {"enough","-e", .5,                   "stopping criteria"},
  {"file",  "-f", "../data/auto93.csv", "data file to load"},
  {"help",  "-h", false,                "show help"},
  {"some",  "-s", 4,                    "samples per generation"},
  {"seed",  "-S", 937162211,            "random number seed"}
}

-- shorties
local abs,log,cat,fmt,pop,push,sort,same
abs  = math.abs
cat  = table.concat
fmt  = string.format
log  = math.log 
pop  = table.remove
push = table.insert
same = function(x,...) return x  end
sort = function(t,f) table.sort(t,f); return t end

-- Random
local Seed, randi, rand
Seed=937162211
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 

-- lists
local map,keys,shuffle,copy,sum
function copy(t) return map(t, function(_,x) return x end) end

function keys(t,  u) 
  u={};for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then push(u,k) end end
  return sort(u) end

function map(t,f,  u) 
  u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end 

function shuffle(t,n,    j)
  for i = #t,2,-1 do j=randi(1,i); t[i],t[j] = t[j],t[i] end
  return t end

function sum(t,f,    n)
  n,f = 0,f or same
  for _,x in pairs(t) do n=n+f(x) end; return n end

-- Cli
local cli,help
function cli(options,   u)
  u={}
  for _,t in pairs(options) do
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do if word==t[2] then
      u[t[1]] = (t[3]==false) and true or tonumber(arg[n+1]) or arg[n+1] end end end
  return u end

function help(usage, options)
  print(usage .. " [OPTIONS]\n\nOPTIONS:");
  for _,t in pairs(options) do
    print(fmt("  %-4s%-20s %s",t[2], t[3]==false and "" or t[3],  t[4])) end end

-- Meta
local isa,obj
function isa(mt,x) return setmetatable(x,mt) end
function obj(s, o) o={_is=s, __tostring=out}; o.__index=o; return o end

--  Printing
local shout,out
function out(t,    u,f1,f2)
  function f1(_,x) return fmt(":%s %s",x,out(t[x])) end
  function f2(_,x) return out(x) end
  if type(t) ~= "table" then return tostring(t) end
  u=#t==0 and map(keys(t),f1) or map(t,f2)
  return (t._is or"").."{"..cat(u," ").."}" end

function shout(t) print(out(t)) end

-- CSV reading
local function csv(file,      split,stream,tmp)
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
function ako(v)    return (skipp(v) and Skip) or (nump(v) and Num) or Sym end
function goalp(v)  return klassp(v)  or v:find"+" or v:find"-" end
function klassp(v) return v:find"!" end
function nump(v)   return v:match("^[A-Z]") end
function skipp(v)  return v:find":" end

Cols= obj"Cols"
function Cols.new(lst,       self,now) 
  self = isa(Cols, {header=lst,all={},xs={},ys={},klass=nil}) 
  for k,v in pairs(lst) do
    now = ako(v).new(k,v)
    push(self.all, now)
    if not skipp(v) then 
      if klassp(v) then self.klass=now end
      push(goalp(v) and self.ys or self.xs, now) end end
  return self end

-- Sym
Sym = obj"Sym"
function Sym.new(i,s)  return isa(Sym, {at=i,txt=s,n=0,has={},mode=nil,most=0}) end
function Sym:add(x)    
  if x=="?" then return x end; 
  self.n = self.n + 1
  self.has[x] = 1+(self.has[x] or 0) 
  if self.has[x] > self.most then 
     self.most,self.mode = self.has[x],x end end

function Sym:dist(x,y) return  x==y and 0 or 1 end
function Sym:mid()     return self.mode end
function Sym:spread() 
  return sum(self.has, 
             function(n) return n<-0 and 0 or n/self.n*log(n/self.n,2) end) end

-- Num
Num = obj"Num"
function Num.new(i,s) 
  return isa(Num,{at=i,txt=s,n=0,_all={}, ok=false,w =s:find"-" and -1 or 1}) end

function Num:add(x) 
  if x=="?" then return x end
  self.n = self.n + 1
  push(self._all, x)
  self.ok = false end

function Num:all(x)
  if not self.ok then self.ok=true; table.sort(self._all) end
  return self._all end

function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return abs(x-y) end

function Num:mid(    a) a=self:all(); return a[#a//2] end
function Num:norm(x,     a)
  a=self:all()
  return abs(a[#a]-a[1])< 1E-16 and 0 or (x-a[1])/(a[#a]-a[1]) end

function Num:spread(   a,here) 
  a = self:all() 
  if #a < 2 then return 0 end
  function here(x) x=x*#a//1; return x < 1 and 1 or x>#a and #a or x end
  return (a[here(.9)] - a[here(.1)])/2.56 end

-- Skip
Skip= obj"Skip"
function Skip.new(i,s) return isa(Skip,{at=i,txt=s}) end
function Skip:add(x)   return x end
function Skip:mid()    return "?" end
function Skip:spread() return "?" end

-- Sample
local Sample= obj"Sample"
function Sample.new(src,   self) 
  self = isa(Sample, {rows={}, cols=nil}) 
  if type(src)=="string" then for   row in csv(src)   do self:add(row) end end
  if type(src)=="table"  then for _,row in pairs(src) do self:add(row) end end
  return self end 

function  Sample:add(lst,   add)
  function add(k,v) self.cols.all[k]:add(v); return v; end  
  if   not self.cols
  then self.cols = Cols.new(lst) 
  else push(self.rows, map(lst,add)) end end

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

function Sample:clone(inits,   now)
  now = Sample.new()
  now:add(self.cols.header)
  map(inits or {}, function(_,row) now:add(row) end)
  return now end

function Sample:dist(row1,row2)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, 2
  for _,col in pairs(self.cols.xs) do
    x,y = row1[col.at], row2[col.at]
    inc = (x=="?" and y=="?" and 1) or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end

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
  function go(stop,rows,     best,somes,tmp)
    tmp = self:clone(rows)
    print(#rows, out(tmp:mid(tmp.cols.ys)), out(tmp:spread(tmp.cols.ys)))
    if #rows < stop or #rows < the.some then return rows end
    best,somes = {},{}
    for i = 1,the.some do push(somes,pop(rows)) end
    somes = sort(somes, better)
    for _,row in pairs(rows) do
      if want(row,somes) then push(best,row) end  end
    return go(stop, best) 
  end ---------------------------------------------------
  return go((#self.rows)^the.enough, shuffle(copy(self.rows))) end

function Sample:mid(  cols) 
  return map(cols or self.cols.all, function(k,x)  return x:mid() end) end

function Sample:spread(   cols) 
  return map(cols or self.cols.all, function(_,x) return x:spread() end) end

-- Main
local function main(file,     s,t)
  s = Sample.new(file)
  --shout(s.cols.ys)
  --shout(s:mid(s.cols.ys))
  --t=s:clone(s:div())
  --print("")
end

the = cli(options)
Seed= the.seed
if the.help then help("lua ssl.lua",options) else main(the.data) end
for k,v in pairs(_ENV) do if not b4[k] then print("? ",k,type(v)) end end
--for row in csv("../data/auto93.csv") do shout(row) end
