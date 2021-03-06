-- vim: ft=lua ts=2 sw=2 et:

-- # Sample = summarize rows into columns
local oo=require"oo"
local Cols=require"Cols"
local Sym,Num,Skip = require"Sym", require"Num", require"Skip"
local csv=require("lib").csv

-- Theory note: dialog independence
-- ## Create
-- If passed a table or a file name, add in that content.
local Sample=oo.klass"Sample"
function Sample.new(my, inits)
  self= oo.isa(Sample, {rows={}, cols=nil, my=my, keep=true}) 
  if type(inits)=="table"  then for _,t in pairs(inits) do self:add(t) end end
  if type(inits)=="string" then for _,t in csv(inits)   do self:add(t) end end
  return self end

-- ## Update
--  If this is the first row, then use it to create the
-- column headers.
function Sample:add(t)
  if   not self.cols 
  then self.cols = Cols.new(t) 
  else self.cols:add(t)
       if self.keep then table.insert(self.rows,t) end end end

-- ## Query
-- Return a  row's klass values (fails if there is no class).
function Sample:klass(row) return row[self._klass.at] end

-- Return a row's  goal values.
function Sample:ys(row,          u) 
  u={};for _,col in pairs(self.cols.ys) do u[1+#u]=row[col.at] end; return u end

-- Central tendency
function Sample:mid(         u) 
  u={};for _,col in pairs(self.cols.xys) do u[1+#u]=col:mid() end; return u end

-- Variability around central tendency
function Sample:spread(         u) 
  u={};for _,col in pairs(self.cols.xys) do u[1+#u]=col:spread() end; return u end

-- ### Distance
-- Using the attributes in `cols` (default= all x values),
-- return the separation of two rows.   
-- Theory note: unreliable when #cols gets large.
function Sample:distance(row1,row2,cols)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, self.my.p
  for _,col in pairs(cols or self.cols.xs) do
    x,y = row1[col.at],row2[col.at]
    inc = x=="?" and y=="?" and 1 or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end
   
-- Using the columns in `cols`.
-- return the `rows`, sorted by the distance to `row1`.
function Sample:distances(row1,rows,cols,    t)
  rows = rows or top(self.my.some, shuffle(self.rows))
  t={}
  for _,row2 in pairs(rows) do 
    table.insert(t, {self:distance(row1,row2,cols),row2}) end
  table.sort(t, function (x,y) return x[1] < y[1] end)
  return t end

-- Theory note: random projections. Hyperspace geometry.
-- Return a point somewhat distant to `row1`.
function Sample:faraway(row1,rows,cols,    tmp)
  tmp = self:neighbors(row1,rows,cols)
  return tmp[self.my.far * #tmp // 1] end


-- ### Sorting
-- Zitler's domination predicate. 
-- theory note. pareto frontier. no exact solution. problem of g>2 goals.
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

-- Sort all rows
function Sample:betters(cols)
  table.sort(self.rows, function (x,y) return self:better(x,y,cols) end)
  return self.rows end


-- Fin.
return Sample
