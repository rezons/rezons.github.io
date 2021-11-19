local the           = require"the"
local push         = the"funs push"
local obj,has      = the"metas obj has"
local Num,Sym,Skip = require"num", require"sym", require"skip"
local goalp,klassp,nump,skipp

function goalp(v)  return klassp(v)  or v:find"+" or v:find"-" end
function klassp(v) return v:find"!" end
function nump(v)   return v:match("^[A-Z]") end
function skipp(v)  return v:find":" end

-- New columns are either `Skip`s or `Num`s or `Sym`s.
-- New columns are always stored in `all` and
-- independent/dependent columns (that we are not `skipp`ing)
-- are stored  in `xs` or `ys` respectively.
Cols= obj"Cols" ---------------------------------------------------------------
function Cols.new(lst,       self,now,what)
  self = has(Cols, {header=lst,all={},xs={},ys={},klass=nil}) 
  for k,v in pairs(lst) do
    what = (skipp(v) and Skip) or (nump(v) and Num) or Sym 
    now = what.new(k,v)
    push(self.all, now)
    if not skipp(v) then 
      if klassp(v) then self.klass=now end
      push(goalp(v) and self.ys or self.xs, now) end end
  return self end

function Cols:better(row1,row2)
  local n,a,b,s1,s2,e
  e=2.71828
  s1, s2, n = 0, 0, #self.ys
  for _,col in pairs(self.ys) do
    a  = col:norm(row1[col.at]) --normalize to avoid explosion in exponentiation
    b  = col:norm(row2[col.at])
    s1 = s1 - e^(col.w * (a - b) / n)
    s2 = s2 - e^(col.w * (b - a) / n) end
  return s1 / n < s2 / n end

function Cols:add(t) for k,x in pairs(t) do self.all[k]:add(x) end; return t end

return Cols
