-------------------------------------------------------------------------------
-- options
local the={trivial=.35, small=.5, p=2,b4={}}
for k,v in pairs(_ENV) do the.b4[k]=v end

-------------------------------------------------------------------------------
-- maths tricks
local abs
abs = math.abs

function norm(x,lo,hi)
  if x=="?" then return x end
  return abs(hi - o) < 1E32 and 0 or (x - lo)/(hi - lo) end

function per(t,p,    here)
  function here(x) x=x*#t//1; return x < 1 and 1 or x>#t and #t or x end
  return #t <2 and  t[1] or t[ here(p or .5) ] end

function sd(t) return (per(t,.9) - per(t,.1))/ 2.56 end

function xpect(t1,t2) return (#t1*sd(t1) + #t2*sd(t2)) / (#t1 + #t2) end

function mergeable(t1,t2,    t3)  
  t3 = {}
  for _,x in pairs(t1) do push(t3,x) end
  for _,x in pairs(t2) do push(t3,x) end
  t3 = sort(t3) 
  if xpect(t1,t2) >= sd(t3) then return t3 end end

function sum(t,f)
  f= f or function(x) return x end
  out=0; for _,x in pairs(f) do out = out + f(x) end; return out end

-------------------------------------------------------------------------------
-- table tricks
local cat,map,push,sort,firsts,shuffle
cat     = table.concat
sort    = function(t,f) table.sort(t,f); return t end
push    = table.insert
firsts  = function(a,b) return a[1] < b[1] end
shuffle = function(_,__) return math.random() <= 0.5 end

function map(t,f,     u) 
  u={}; for x,y in pairs(t) do 
    x,y = f(x,y) 
    if x ~= nil then
      if y then u[x]=y else u[1+#u]=x end end end 
  return u end

-------------------------------------------------------------------------------
-- printing tricks
local fmt,out,shout
fmt  = string.format
shout= function(x) print(out(x)) end

function out(t,    u,key,keys,value,public)
  function key(_,k)   return fmt(":%s %s",k,out(t[k])) end
  function value(_,v) return out(v,seen) end
  function public(k)  return tostring(k):sub(1,1)~="_" end
  function keys(t,u)
    u={}; for k,_ in pairs(t) do if public(k) then push(u,k) end end
    return sort(u) 
  end
  if type(t) == "function" then return "FUN" end
  if type(t) ~= "table"    then return tostring(t) end
  u = #t>0 and map(t, value) or map(keys(t), key) 
  return (t._is or"").."{"..cat(u," ").."}" end 

-------------------------------------------------------------------------------
-- file i/o tricks
local lines
function lines(file,fun,    line,t,out)
  fun  = fun or function(x) return(x) end
  file = io.input(file)
  line = io.read()
  out  = {}
  while line do
    t={}
    for cell in line:gsub("[\t\r ]*",""):gsub("#.*",""):gmatch("([^,]+)") do
      push(t, tonumber(cell) or cell) end 
    if #t>0 then push(out, fun(t)) end 
    line = io.read()
  end 
  io.close(file)
  return  out end

-------------------------------------------------------------------------------
-- oo tricks
local has,obj
function has(mt,x) return setmetatable(x,mt) end
function obj(s, o,new)
   o = {_is=s, __tostring=out}
   o.__index = o
   return setmetatable(o,{__call = function(_,...) return o.new(...) end}) end

-------------------------------------------------------------------------------
-- Samples store rows. They know about 
-- (a) lo,hi ranges on the numerics
-- and (b) what  are independent `x` or dependent `y` columns.
local Sample=obj"Sample"
function Sample.new()
  return has(Sample,{names=nil, nums={}, ys={}, xs={}, rows={}})  end

function Sample:add(row,     headers,data)
  function name(col,new,    tmp) 
    if not new:find":" then return end
    if not (new:find("+") or new:find("-")) then self.xs[col]=col end 
    if new:match("^[A-Z]") then 
      tmp = {col=col, w=0, lo=1E32, hi=-1E22} 
      self.nums[col] = tmp
      if new:find"-" then tmp.w=-1; self.ys[col] = tmp end
      if new:find"+" then tmp.w= 1; self.ys[col] = tmp end end 
  end -----------------
  function datum(col,new)
    if self.nums[col] and new ~= "?" then
      self.nums[col].lo = math.min(new, self.nums[col].lo)
      self.nums[col].hi = math.max(new, self.nums[col].hi) end  
  end -----------------
  if   not self.names
  then self.names = row
       map(row, function(col,x) return self:name(col,x) end) 
  else push(self.rows, row)
       map(row, function(col,x) return self:datum(col,x) end) end end

-------------------------------------------------------------------------------
-- geometry tricks
-- y column rankings
local dist, better,betters
function dist(row1,row2,sample,     a,b,d,n,inc,dist1)
  function dist1(num)
    if not num then return a==b and 0 or 1 end
    if     a=="?" then b=norm(b, num.lo, num,hi); a = b>.5 and 0 or 1
    elseif b=="?" then a=norm(a, num.lo, num.hi); b = a>.5 and 0 or 1
    else   a,b = norm(a, num.lo, num.hi), norm(b, num.lo, num.hi)
    end
    return abs(a-b) 
  end -------------------------
  d,n=0,0
  for col,_ in pairs(sample.xs) do
    a,b = row1[col], row2[col]
    inc = a=="?" and b=="?" and 1 or dist1(sample.nums[col])
    d   = d + inc^the.p
    n   = n + 1 end
  return (d/n)^(1/the.p) end

function betters(rows,sample) 
  return sort(rows,function(a,b) return better(a,b,sample) end) end

function better(row1,row2,sample,     e,n,a,b,s1,s2)
  n,s1,s2,e = #sample.ys, 0, 0, 2.71828
  for _,num in pairs(sample.ys) do
    a  = norm(row1[num.col], num.lo, num.hi)
    b  = norm(row2[num.col], num.lo, num.hi)
    s1 = s1 - e^(num.w * (a-b)/n) 
    s2 = s2 - e^(num.w * (b-a)/n) end
  return s1/n < s2/n end 

function bins(col,sample,      xys, x,y,tmp,out,n,xpect)
  xys,all, symbols, symbolic ={},{}, {}, sample.nums[col]
  for rank,row in pairs(sample.rows) do
    x,y = row[col], rank
    if x ~= "?" then 
      if   symbolic
      then symbols[x] = symbols[x] or {}
           push(tmp[x], y) 
      else push(all,x)
           push(xys,{x=x,y=y}) end end end
  if   symbolic 
  then out = map(symbols, function(x,t) return {col=col, lo=x, hi=x, has=sort(t)} end)
  else xys = sort(xys, function(a,b) return a.x < b.x end)
       out = discretize(col,xys, #all^the.small,  sd(sort(all)) * the.trivial) 
  end
  xpect = sum(out, function(one) return #one.has/#all*sd(one.has) end)
  return {xpect, out} end

-- Generate a new range when     
-- 1. there is enough left for at least one more range; and     
-- 2. the lo,hi delta in current range is not tiny; and    
-- 3. there are enough x values in this range; and   
-- 4. there is natural split here
-- Fuse adjacent ranges when:
-- 5. the combined class distribution of two adjacent ranges 
--    is just as simple as the parts.
function discretize(col, xys, tiny, dull,           now,out,x,y)
  now = {col=col, lo=xys[1].x, hi=xys[1].x, has={}}
  out = {now}
  for j,xy in pairs(xys) do
    x, y = xy.x, xy.y
    if   j<#xys-tiny and x~=xys[j+1].x and #now.has>tiny and now.hi-now.lo>dull 
    then now = {col=col, lo=x, hi=x, has={}}
         push(out, now) end 
    now.hi = x 
    push(now.has, y) end
  return merge(col, map(out, function(_,one) table.sort(one.has) end)) end 

function merge(col, b4,       j,tmp,a,n,hasnew) 
  j, n, tmp = 0, #b4, {}
  while j<n do
    j = j + 1
    a = b4[j]
    if j < n-1 then
      better = mergeable(a.has, b4[j+1].has)
      if better then 
        j = j + 1 
        a = {col=col, lo=a.lo, hi= b4[j+1].hi, has=better} end end
    push(tmp,a) end 
  return #tmp==#b4 and b4 or merge(col,tmp) end

s=Sample.new()
for _,row in pairs(lines("../../data/auto93.csv")) do s:add(row) end

for _,row in sort(s.rows, function(a,b) return s:better(a,b) end)  do
   shout(row) end

for k,v in pairs(_ENV) do if not the.b4[k] then print("? ",k,type(v)) end end
