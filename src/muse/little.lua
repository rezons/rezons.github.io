local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local all,any,firsts,fmt,new,many,map,o,push
local rows,seconds,slots,sort,thing,things
local EGS, NUM, SYM = {},{},{}
-- ----------------------------------------------------------------------------
function NUM.new(class,at,s) 
  return new(class,{at=at,txt=s,w=s:find"-" and -1 or 1,_has={},
                    ok=false, lo=math.huge, hi=-math.huge}) end

function NUM.add(i,x) 
  if x ~= "?" then
    i.ok = false 
    push(i._has, x)
    if x < i.lo then i.lo = x end
    if x > i.hi then i.hi = x end end 
  return x end

function NUM.dist(i,a,b)
  if     a=="?" and  b=="?" then a,b=1,0
  elseif a=="?" then b   = i:norm(b); a=b>.5 and 0 or 1
  elseif b=="?" then a   = i:norm(a); b=a>.5 and 0 or 1
  else               a, b= i:norm(a), i:norm(b) end
  return math.abs(a-b) end

function NUM.norm(i,x)
  return i.hi - i.lo<1E-9 and 0 or (x - i.lo)/(i.hi - i.lo) end
-- ----------------------------------------------------------------------------
function SYM.new(class,at,s) 
  return new(class,{at=at,txt=s,_has={}}) end

function SYM.add(i,x) 
  if x ~= "?" then i._has[x] = 1+(i._has[x] or 0) end 
  return x end

function SYM.has(i) 
  if not i.ok then sort(i._has); i.ok=true end; return i._has end

function SYM.dist(i,a,b)
  return  a=="?" and b=="?" and 1 or a==b and 0 or 1 end
-- ----------------------------------------------------------------------------
function EGS.new(class) 
  return new(class,{_rows={}, cols=nil, x={},  y={}}) end

function EGS.add(i,t)
  local add,now,where = function(col) return col:add(t[col.at]) end
  if   i.cols 
  then push(i._rows, map(i.cols, add)) 
  else i.cols = {}
       for n,x in pairs(t) do 
         now = (x:find"^[A-Z]" and NUM or SYM):new(n,x)
         push(i.cols, now)
         if not x:find":" then 
           where = (x:find"+" or x:find"-") and i.y or i.x
           push(where, now) end end end end

function EGS.clone(i,inits,    j)
  j = EGS:new()
  j:add(map(i.cols, function(col) return col.txt end))
  for _,row in pairs(inits or {}) do j = j:add(row) end 
  return j end

function EGS.cluster(i,top,lvl,         tmp1,tmp2,left,right)
  top = top or i
  lvl = lvl or 0
  print(fmt("%s%s", string.rep(".",lvl),#i._rows))
  if #i._rows >= 2*(#top._rows)^.5 then
    tmp1, tmp2 = top:half(i._rows)
    if #tmp1._rows < #i._rows then left  = tmp1:cluster(top,lvl+1) end
    if #tmp2._rows < #i._rows then right = tmp2:cluster(top,lvl+1) end 
  end
  return {here=i, left=left, right=right} end

function EGS.dist(i,r1,r2)
  local d,n,inc = 0, (#i.x)+1E-31
  for _,col in pairs(i.x) do
    inc = col:dist(r1[col.at], r2[col.at])
    d   = d + inc^2 end
  return (d/n)^.5 end

function EGS.far(i,r1,rows,        fun,tmp)
  fun = function(r2) return {r2, i:dist(r1,r2)} end
  tmp = sort(map(rows,fun), seconds)
  return table.unpack(tmp[#tmp*.9//1] ) end
    
function EGS.half(i,rows)
  local some,left,right,c,cosine,lefts,rights
  some    = #rows > 512 and many(rows,512) or rows
  left    = i:far(any(rows), some)
  right,c = i:far(left,      some)
  function cosine(r,     a,b)
    a, b = i:dist(r,left), i:dist(r,right); return {(a^2+c^2-b^2)/(2*c),r} end
  lefts,rights = i:clone(), i:clone() 
  for n,pair in pairs(sort(map(rows,cosine), firsts)) do         
    (n <= #rows/2 and lefts or rights):add( pair[2] ) end
  --print(#rows, #lefts._rows, #rights._rows)
  return lefts,rights,left,right,c end                              
-- ----------------------------------------------------------------------------
function any(t) return t[math.random(#t)] end 

function firsts(a,b)  return a[1] < b[1] end

fmt = string.format

function many(t,n, u) u={};for j=1,n do t[1+#t]=any(t) end; return u end

function map(t,f,u)  u={};for _,v in pairs(t) do u[1+#u]=f(v) end; return u end

function new(k,t) k.__index=k; return setmetatable(t,k) end

function o(t,   u)
  if type(t)~="table" then return tostring(t) end
  local key=function(k) return string.format(":%s %s",k,o(t[k])) end
  u = #t>0 and map(t,o) or map(sort(slots(t)),key) 
  return '{'..table.concat(u," ").."}" end 

function push(t,x) table.insert(t,x); return x end

function rows(file,      x)
  file = io.input(file)
  return function() 
    x=io.read(); if x then return things(x) else io.close(file) end end end

function seconds(a,b) return a[2] < b[2] end

function slots(t, u) 
  u={}
  for k,_ in pairs(t) do k=tostring(k); if k:sub(1,1)~="_" then u[1+#u]=k end end
  return u end 

function sort(t,f)   table.sort(t,f); return t end

function thing(x)   
  x = x:match"^%s*(.-)%s*$" 
  if x=="true" then return true elseif x=="false" then return false end
  return tonumber(x) or x end

function things(x,sep,  t)
  t={};for y in x:gmatch(sep or"([^,]+)") do push(t,thing(y)) end; return t end
-- ----------------------------------------------------------------------------
--for row in rows("../../data/auto93.csv") do print(o(row)) end
local n,i=0,EGS:new()
for row in rows("../../data/auto93.csv") do n=n+1; i:add(row)  end 
i:cluster()
for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end
