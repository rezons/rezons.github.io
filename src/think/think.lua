local b4={}; for k,v in pairs(_ENV) do b4[k]=v end

-------------------------------------------------------------------------------
local the={p=2}

-------------------------------------------------------------------------------
local abs
abs = math.abs

-------------------------------------------------------------------------------
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
local has,obj
function has(mt,x) return setmetatable(x,mt) end
function obj(s, o,new)
   o = {_is=s, __tostring=out}
   o.__index = o
   new = function(_,...) return o.new(...) end
   return setmetatable(o,{__call=new}) end

-------------------------------------------------------------------------------
local Sample=obj"Sample"
function Sample.new(      file,self) 
  self= has(Sample,{head=nil, nums={}, ys={}, xs={}, rows={}}) 
  return file and self:load(file) or self end

function Sample:load(file)
  for _,row in pairs(lines(file)) do self:add(row) end 
  return self end

function Sample:add(row,     headers,data)
  function headers(at,head,    tmp) 
    if not head:find":" then
      if head:match("^[A-Z]") then 
        tmp = {at=at, w=0, lo=1E32, hi=-1E22} 
        if head:find"-" then tmp.w=-1; self.ys[at] = tmp end
        if head:find"+" then tmp.w= 1; self.ys[at] = tmp end
        self.nums[at] = tmp end
      if not (head:find("+") or head:find("-")) then self.xs[at]=at end end
    return head 
  end
  function data(at,datum)
    if self.nums[at] and datum ~= "?" then
      self.nums[at].lo = math.min(datum, self.nums[at].lo)
      self.nums[at].hi = math.max(datum,  self.nums[at].hi) end 
    return datum 
  end
  if   self.head
  then push(self.rows, map(row,data)) 
  else self.head = map(row,headers) end end 

function Sample:norm(num,x)
  if x=="?" then return x end
  return abs(num.hi - num.lo) < 1E32 and 0 or (x - num.lo)/(num.hi - num.lo) end

function Sample:better(row1,row2,      e,n,a,b,s1,s2)
  n,s1,s2,e = #self.ys, 0, 0, 2.71828
  for _,num in pairs(self.ys) do
    a  = self:norm(num, row1[num.at])
    b  = self:norm(num, row2[num.at])
    s1 = s1 - e^(num.w * (a-b)/n) 
    s2 = s2 - e^(num.w * (b-a)/n) end
  return s1/n < s2/n end 

function Sample:dist(row1,row2)
  function dist(num)
    if not num then return a==b and 0 or 1 end
    if     a=="?" then b=self:norm(num,b); a = b>.5 and 0 or 1
    elseif b=="?" then a=self:norm(num,a); b = a>.5 and 0 or 1
    else   a,b = self:norm(num,a), self:norm(num,b) 
    end
    return abs(a-b) 
  end -------------------------
  for at,_ in pairs(self.xs) do
    a,b = row1[at], row2[at]
    inc = a=="?" and b=="?" and 1 or dist(self.nums[at])
    d   = d + inc^the.p
    n   = n + 1 end
  return (d/n)^(1/the.p) end

s=Sample.new("../../data/auto93.csv")

for _,row in sort(s.rows, function(a,b) return s:better(a,b) end)  do
   shout(row) end

for k,v in pairs(_ENV) do if not b4[k] then print("? ",k,type(v)) end end
