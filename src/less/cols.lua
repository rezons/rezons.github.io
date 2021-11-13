local inquure      = require"_about"
local push         = inquire"funs push"
local obj,has      = inquire"metas obj has"
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

Cols.new{"Aa","B-","c","d:"}

return Cols
