local inquire= require"_about"
local randi  = inquire"rands randi"
local push   = inquire"funs push"

local firsts,map,keys,shuffle,copy,sum,bchop,top,any 

-- return  any item
function any(t) return t[randi(1,#t)] end

-- binary chop (assumes sorted lists)
function bchop(t,val,lt,      lo,hi,mid)
  lt = lt or function(x,y) return x < y end
  lo,hi = 1,#t
  while lo <= hi do
    mid =(lo+hi) // 2
    if lt(t[mid],val) then lo=mid+1 else hi= mid-1 end end
  return math.min(lo,#t)  end

-- Shallow copy
function copy(t) return map(t, function(_,x) return x end) end

-- `firsts` is used for sorting {{score,x}, {score,y},...}
function firsts(x,y) return x[1] < y[1] end

-- Sorted table keys
function keys(t,  u)
  u={};for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then push(u,k) end end
  return sort(u) end

-- Call `f(key,value)` on all items  in list.
function map(t,f,  u) u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end

-- Percentile item
function per(a,p)
  function here(x) x=x*#a//1; return x < 1 and 1 or x>#a and #a or x end
  return #a <2 and  a[1] or a[ here(p or .5) ] end

-- Randomly sort in-place a list
function shuffle(t,    j)
  for i = #t,2,-1 do j=randi(1,i); t[i],t[j] = t[j],t[i] end
  return t end

-- Sum items in a list, optionally filtered via  `f`.
function sum(t,f,    n)
  n,f = 0,f or same
 for _,x in pairs(t) do n=n+f(x) end; return n end

-- top `n` items
function top(n,t,   u)
  u={}; for i,x in pairs(t) do u[#u+1]=x; if i>=n then break end end
  return u end

return {firsts=firsts,map=map,keys=keys,shuffle=shuffle,
        copy=copy,sum=sum,bchop=bchop,top=top,any=any}
