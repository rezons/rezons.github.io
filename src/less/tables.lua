local the = require"the"
local r   = the.get"maths r"
local push,sort,per,firsts,map,keys,shuffle,copy,sum
local bchop,top,any,first,last,second,cat,pop,sort
local ntimes

-- defined in metas, but if defining again here
-- avoids a cyclic dependancy
local same = function (x) return x end

-- table position shortcuts
first = function(t) return t[1] end
second= function(t) return t[2] end
last  = function(t) return t[#t] end
any   = function(t) return t[r(#t)] end

-- general table shortcuts
cat   = table.concat
pop   = table.remove
push  = table.insert
sort  = function(t,f) table.sort(t,f); return t end
firsts= function(x,y) return x[1] < y[1] end

-- binary chop (assumes sorted lists)
function bchop(t,val,lt,lo,hi,     mid)
  lt = lt or function(x,y) return x < y end
  lo,hi = lo or 1, hi or #t
  while lo <= hi do
    mid =(lo+hi) // 2
    if lt(t[mid],val) then lo=mid+1 else hi= mid-1 end end
  return math.min(lo,#t)  end

-- Shallow copy
function copy(t) return map(t, function(_,x) return x end) end

-- Sorted table keys
function keys(t,  u)
  u={};for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then push(u,k) end end
  return sort(u) end

-- Call `f(key,value)` on all items  in list.
function map(t,f,  u) u={}; for k,v in pairs(t) do u[k]=f(k,v) end; return u end

-- Loop over n items
function ntimes(m,n,f,  u) 
  if not f then return ntimes(1,m,n) end
  u={}; for i=1,n do u[i]=f(i) end; return u end

-- Percentile item
function per(a,p,    here)
  function here(x) x=x*#a//1; return x < 1 and 1 or x>#a and #a or x end
  return #a <2 and  a[1] or a[ here(p or .5) ] end

-- Randomly sort in-place a list
function shuffle(t,    j)
  for i = #t,2,-1 do j=r(1,i); t[i],t[j] = t[j],t[i] end
  return t end

-- Sum items in a list, optionally filtered via  `f`.
function sum(t,f,    n)
  n,f = 0,f or same
 for _,x in pairs(t) do n=n+f(x) end; return n end

-- top `n` items
function top(n,t,   u)
  u={}; for i,x in pairs(t) do u[#u+1]=x; if i>=n then break end end
  return u end

return {ntimes=ntimes,firsts=firsts,map=map,keys=keys,shuffle=shuffle,per=per,
        first=first,last=last,second=second,cat=cat,pop=pop,push=push,
        sort=sort,copy=copy,sum=sum,bchop=bchop,top=top,any=any}
