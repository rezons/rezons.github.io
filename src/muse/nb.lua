local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end 
local atom,csv,inc,isa, map,o,obj,NB

isa = setmetatable
function o(t)      return "{".. table.concat(map(t, tostring),", ") .."}" end
function obj()     local t={}; t.__index=t; return t end
function map(t,f)  local u={};for k,v in pairs(t) do u[#u+1]=f(v) end; return u; end
function inc(d,k)  d[k]= 1+(d[k] or 0); return k end
function atom(x)   return tonumber(x) or x end

function csv(file,   n)
  n,file = 0,io.input(file) 
  return function(    t) 
    x=io.read(); 
    if x then 
      t={}; for y in x:gsub("%s+",""):gmatch"([^,]+)" do t[1+#t]=atom(y) end
      n=n+1
      return n,t 
    else io.close(file) end end end 

NB=obj{}
function NB.new() return isa({k=1,m=2,names={}, n, hs=0,h={}, f={}},NB) end

function NB.read(i, file) 
  for n,row in csv(file) do i:add(n,row) end end

function NB.add(i, n,row,          k,klass)
  if n==0 then i.names=row else
    k=#row
    if n > 5 then print(row[k], i:classify(row)) end
    klass=row[k]
    if not i.h[klass] then i.hs=i.hs+1; i.h[klass]=0 end
    inc(i.h,row[k])
    i.n=i.n+1
    for col,x in pairs(row) do
      if col~=k and x~="?" then
        inc(i.f, {col,x,klass}) end end end  end

function NB.classify(i,row,      best)
  best=-1
  for klass,nh in pairs(i.h) do
    local prior = (nh+i.k)/(i.n + i.k*i.hs)
    local tmp   = log(prior)
    for col,x in pairs(row) do
      if col ~= #row and x~="?" then
        tmp = tmp + ((i.f[{col,x,klass}] or 0) +i.m*prior)/(nh+i.m) end end
    if tmp > best then best,out=tmp,klass end end
  return klass end

local i=NB.new()
i:read("../../data/weathernom.csv")
print(o(i.h))
for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end 
