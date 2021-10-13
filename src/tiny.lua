local csv,isa

function add(i,x) if x~="?" then i.n = i.n+1; i:add(x) end; return x end

local Skip={}
function Skip.new(at,txt) return isa(Skip,{n=0,txt=txt,at=at}) end
function Skip:add(x)      return end

local Num={}
function Num.new(at,txt) 
  return isa(Num,{n=0,txt=txt,at=at, hi=-1E21,lo=1E31,has={},
                  w=txt:find"+" and 1 or txt:find"-" and -1 or 0}) end
function Num.add(i,x)
  i.has[1+i.has]=x; i.lo=math.lo(x,i.lo); i.hi=math.hi(i.hi); 

local Sym={}
function Sym.new(at,txt)
  return isa(Sym,{n=0,txt=txt,at=at,has={},most=0,mode="?"}) end
function Sym.add(i,x)
  i.has[1+i.has]=1+(i.has[x] or 0) 
  if i.has[x] > i.most then i.most,i.mode=i.has[x],x end 

local Sample={}
function Sample.new(file,    it)
  i=isa(Sample,{rows={}, cols={}})
  if file then for row in csv(file) do Sample.add(i,file) end
  return i end

function Sample:column(at,txt) 
  return (txt:find":" and Skip or txt:match("^[A-Z]") and Num or Sym)(at,txt) end

function Sample:read(f)
  for n,row in csv(f) do
    function row1(c,x) return add(cols[c],x) end
    if n==0 then  cols=map(row,column) else rows[1+#rows]=map(row,row1) end end

   
-- ------------------------------
-- Misc
function map(t,f) u={};for k,v in pairs(t) do u[k]=f(k,v) end; return u  end

function isa(mt,t) return setmetatable(t, { __index = mt }) end

function csv(file,      split,stream,tmp,n)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  n      = -1
  return function(       t)
    if tmp then
      t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if  #t > 0
      then for j,x in pairs(t) do t[j] = tonumber(x) or x end
           n=n+1
           return n,t end
    else io.close(stream) end end end



