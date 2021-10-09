local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local etc=require"etc"
local about=require"about"
local isa,klass,push,atom= etc.isa,etc.klass,etc.push,etc.atom
local cat,shout,out,go   = etc.cat,etc.shout, etc.out, etc.og
local top,shuffle        = etc.top, etc.shuffle
local main,csv = etc.main, etc.csv

local Sym,Skip,Num,Sample,eg

-- Columns to ignore
Skip=klass"Skip"
function Skip.new(at,txt) return isa(Skip,{at=at,txt=txt}) end
function Skip:add(x) return self end

-- Columns to treat as symbols
Sym=klass"Sym"
function Sym.new(at,txt) 
  return isa(Sym,{at=at,txt=txt,mode=nil,most=1,has={}},Num) end
function Sym:dist(x,y) 
  return  x==y and 0 or 1 end
function Sym:add(x) 
  if x ~= "?" then
    self.has[x]  = 1 + (self.has[x] or 0) 
    if self.has[x] > self.most then
      self.most, self.mode = self.has[x], x end end 
  return self end

-- Columns to treat as numbers
Num=klass"Num"
function Num.new(at,txt) 
  return isa(Num,{at=at,txt=txt,lo=1E32,hi=-1E32},Num) end
function Num:add(x)
  if x~="?" then
    self.lo = math.min(self.lo,x)
    self.hi = math.max(self.hi,x) end 
  return self end
function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return math.abs(x-y) end
function Num:norm(x)
  local lo,hi=self.lo,self.hi
  return (x=="?" and x) or (math.abs(lo-hi)<1E-32 and 0) or (x-lo)/(hi-lo) end  

-- Somewhere to store rows, summarized into columns.
Sample=klass"Sample"
function Sample.new(my, inits,    it) 
  it =  isa(Sample,{my=my,ys={},xs={},xys={},head={},rows={},keep=true}) 
  if type(inits)=="table"  then for _,t in pairs(inits) do it:add(t) end end
  if type(inits)=="string" then for _,t in csv(inits)   do it:add(t) end end
  return it end

function Sample:add(new)
  local isKlass,isGoal,isSkip,isNum,ako,col
  function isKlass(s) return s:find"=" end
  function isGoal(s)  return s:find"+" or s:find"-" or s:find"=" end
  function isSkip(s)  return s:find":" end
  function isNum(s)   return s:match("^[A-Z]") end
  function ako(s)     return isSkip(s) and Skip or (isNum(s) and Num or Sym) end
  if #self.xys>0 then
    for _,col in pairs(self.xys) do col:add(new[col.at]) end
    if self.keep then push(self.rows,new) end
  else
    self.head=new
    for at,txt in pairs(new) do 
      col = ako(txt).new(at,txt)
      push(self.xys, col)
      if not isSkip(txt) then
        if isKlass(txt) then self._klass = col end
        push(isGoal(txt) and self.ys or self.xs, col) end end end end

function Sample:distance(row1,row2,cols)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, self.my.p
  for _,col in pairs(cols or self.xs) do
    x,y = row1[col.at],row2[col.at]
    inc = x=="?" and y=="?" and 1 or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end
    
function Sample:neighbors(row1,rows,cols,    t)
  rows = rows or top(self.my.some, shuffle(self.rows))
  t={}
  for _,row2 in pairs(rows) do 
    push(t, {self:distance(row1,row2,cols),row2}) end
  table.sort(t, function (x,y) return x[1] < y[1] end)
  return t end

function Sample:faraway(row1,rows,cols,    tmp)
  tmp = self:neighbors(row1,rows,cols)
  return tmp[self.my.far * #tmp // 1] end

function Sample:klass(row) return row[self._klass.at] end

local function mode(sample,t)
  local seen=Sym.new()
  for n,x in pairs(t) do 
    seen:add(sample:klass(x[2])) end
  return seen.mode end 

local function triangle(sample,t)
  local seen,n = Sym.new(),0
  for m,_ in pairs(t) do n = n + m end
  for m,x in pairs(t) do
    for _ = 1,(#t-m+1) do 
      seen:add(sample:klass(x[2])) end end 
  return seen.mode end

local function knn(my,  s)
   local function classify(row) 
    for k,x in pairs(s:neighbors(row)) do
      if k>s.my.k then break end
      push(tmp,x) end 
    how= {mode=mode, triangle=triangle}
    return how[my.combine](s, t) 
  end ----------
  s=Sample.new()
  for n,t in csv(my.data) do 
    if n>10 then print(s:klass(t), classify(t)) end
    s:add(t) end end

-- ## Examples
eg={}
-- Default action.
function eg.hello(my) shout(my) end

-- Iterate through a csv file.
function eg.csv(my,   n)
  n=0; for r,row in csv(my.data) do 
  if r>1 then n=n+row[4] end end; print(n) end

-- Use a `Num`.
function eg.num(my,    n)
  n=Num.new()
  n:add(1):add(2):add(3) 
  print(n.hi) end

function eg.german(my,    s)
  my.data = "../data/german.csv"
  s=Sample.new(my, my.data)
  print(#s.rows)
  print(s)
end

-- Load a csv into a `Sample`.
function eg.sample(my,    s)
  s=Sample.new(my, my.data)
  print(s.xys[1].lo, s.xys[1].hi) 
  shout(s.xys[7].has)
  print(#s.rows)
  print(s)
end

-- Check distances
function eg.shuffle(my)
  for i=1,20 do
    print(cat(top(2,shuffle{"a","b","c","d"}),"")) end end

-- Check distances
function eg.dist(my,  s,n,tmp)
  s=Sample.new(my, my.data)
  for _,row1 in pairs(s.rows) do
    tmp = s:neighbors(row1)
    print("")
    print(cat(row1))
    print(cat(tmp[2][2]), tmp[2][1])
    print(cat(tmp[#tmp][2]), tmp[#tmp][1])
    return 
end end

-- Check distances
function eg.gangle(my,  s,n,tmp)
  my.data = "../data/german.csv"
  s = Sample.new(my, my.data)
  for _,row1 in pairs(s.rows) do
    tmp = s:neighbors(row1)
    --prinnt(s:klass(row1),mode(s, top(2,tmp))) 
    print(10)
    print(mode(s, top(3,tmp))) 
    end end

-- Run all `todo`s.
function eg.all(my,   t)
  for v,f in pairs(eg) do if v~="all" then
    print(v); math.randomseed(my.seed); f(my) end end end

-- List all `todo`s.
function eg.ls(my,   t)
  t={};for v,_ in pairs(eg) do push(t,v) end 
  table.sort(t); print("lua ish.lua -t ",cat(t," | ")) end

-- ## Start up
main(eg,about,b4)
