-- ----------------------------------------------------------------------------
OR=class{}
function OR.new() return new({ranges={}, rows={}}, OR) end

function OR.add(i,range)
  push(i.ranges,range)
  for id,row in pairs(range.rows) do i.rows[id] = row end end
-- ----------------------------------------------------------------------------
RANGE=class{}
function RANGE.new(col,lo,hi,stats) 
  return new({id=id(),col=col, lo=lo, hi=hi or lo, 
              ys=stats or SYM(),rows={}},RANGE) end

function RANGE.__tostring(i)
  return fmt("RANGE{:col %s :lo %s :hi %s :ys %s}",
             i.col,i.lo,i.hi,o(i.ys)) end

function RANGE.add(i,x,y,row)
  assert(i.lo <= x and x < i.hi, "in range")
  i.ys[y]       = 1 + (i.ys[y] or 0)
  i.rows[row.id] = row end
-- ----------------------------------------------------------------------------
RANGES=class{}
function RANGES.new() return new({cols={}, _score-0,rows=nil}, AND) end

function RANGES.add(i,range,    at)
  i.rows, i._score = nil,nil
  i.cols[range.col.at] = i.cols[range.col.at] or OR()
  i.cols[range.col.at]:add(range) end

function RANGES.all(i,,      both)
  function both(a,b,    c)
    c={};for id,row in pairs(a) do if b[id] then c[id]=row end end; return c end
  if not i.rows then
    for _,ors in pairs(i.cols) do
      i.rows = i.rows and both(i.rows,ors.rows) or ors.rows 
      if #i.rows == 0 then break end end end 
  return i.rows end

function RANGE.smile(i,b,r) return b>r and 0 or b*b/(b+r +1E-31) end
function RANGE.frown(i,b,r) return r>b and 0 or r*r/(b+r +1E-31) end
function RANGE.xplor(i,b,r) return 1/(b+r                +1E-31) end
function RANGE.doubt(i,b,r) return 1/(math.abs(b-r)      +1E-31) end

function RANGES.score(i,goal,bs,rs,  rows)
  if not i._score then
    b, r = 0, 0
    for _,row in pairs(i:all(goal)) do 
      if row.class==goal then b=b+1/bs else r=r+1/rs end end 
    ifor x,n in pairs(i.has) do
      if x==goal then best = best+n/i.n else rest = rest+n/i.n end end
    i.score = best + rest < 0.01 and 0 or goals[your.goal](best,rest) end
  return i.score end
end

