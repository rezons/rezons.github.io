-- vim: ft=lua ts=2 sw=2 et:

-- # Sample = summarize rows into columns
local oo=require"oo"
local Cols=require"Cols"
local Sym=require"Sym"
local Num=require"Num"
local Skip=require"Skip"

-- Create
local Sample=oo.klass"Sample"
function Sample.new(my, inits)
  return oo.isa(Sample,
           {rows={},cols=nil,my=my,keep=true}):adds(inits) end

-- Initialize.
function Sample:adds(inits)
  if type(inits)=="table"  then for _,t in pairs(inits) do it:add(t) end end
  if type(inits)=="string" then for _,t in csv(inits)   do it:add(t) end end
  return it end

-- Update with a new row. If this is the first row, then use it to create our
-- headers.
function Sample:add(t)
  if self.cols then
    for _,col in pairs(self.cols.xys) do col:add(t[col.at]) end
    if self.keep then table.insert(self.rows, t) end
  else
    self.cols = Cols.new(t) end end
   
function Sample:distance(row1,row2,cols)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, self.my.p
  for _,col in pairs(cols or self.cols.xs) do
    x,y = row1[col.at],row2[col.at]
    inc = x=="?" and y=="?" and 1 or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end
    
function Sample:neighbors(row1,rows,cols,    t)
  rows = rows or top(self.my.some, shuffle(self.rows))
  t={}
  for _,row2 in pairs(rows) do 
    table.insert(t, {self:distance(row1,row2,cols),row2}) end
  table.sort(t, function (x,y) return x[1] < y[1] end)
  return t end

function Sample:better(row1,row2, cols)
  local e,w,s1,s2,n,a,b,what1,what2
  cols = cols or self.cols.ys
  what1, what2, n, e = 0, 0, #cols, math.exp(1)
  for _,col in pairs(cols) do
    a     = col:norm(row1[col.at])
    b     = col:norm(row2[col.at])
    w     = col.w -- w = (1,-1) if (maximizing,minimizing)
    what1 = what1 - e^(col.w * (a - b) / n)
    what2 = what2 - e^(col.w * (b - a) / n) end
  return what1 / n < what2 / n end

function Sample:sort(rows,cols)
  rows = rows or self.rows
  table.sort(rows, function(x,y) return self;better(x,y,cols) end)
  return rows
end

function Sample:faraway(row1,rows,cols,    tmp)
  tmp = self:neighbors(row1,rows,cols)
  return tmp[self.my.far * #tmp // 1] end

function Sample:klass(row) return row[self._klass.at] end

-- Fin.
return Sample
