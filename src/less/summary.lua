local the       = require"the"
local shuffle,top,map,push,sort,firsts = the.get"tables shuffle top map push sort firsts"
local shout,out = the.get"prints shout out"
local e,rnd        = the.get"maths e round"
local obj,has   = the.get"metas obj has"
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
Summary= obj"Summary" ---------------------------------------------------------
function Summary.new(lst,       self,now,what)
  self = has(Summary, {header=lst,all={},xs={},ys={},klass=nil}) 
  for k,v in pairs(lst) do
    what = (skipp(v) and Skip) or (nump(v) and Num) or Sym 
    now = what(k,v)
    push(self.all, now)
    if not skipp(v) then 
      if klassp(v) then self.klass=now end
      push(goalp(v) and self.ys or self.xs, now) end end
  return self end

function Summary:add(t)
  for k,x in pairs(t) do self.all[k]:add(x) end; return t end

function Summary:better(row1,row2)
  local n,a,b,s1,s2
  s1, s2, n = 0, 0, #self.ys
  for _,col in pairs(self.ys) do
    a  = col:norm(row1[col.at]) --normalize to avoid explosion in exponentiation
    b  = col:norm(row2[col.at])
    s1 = s1 - e^(col.w * (a - b) / n)
    s2 = s2 - e^(col.w * (b - a) / n) end
  return s1 / n < s2 / n end

function Summary:dist(row1, row2, cols)
  local d,n,p = 0,0,the.p
  for _,col in pairs(cols or self.xs) do
    inc = col:dist(row1[col.at], row2[col.at]) 
    n,d = n + 1, d + inc^p 
    print(col.at, n, rnd(d,3), row1[col.at], row2[col.at], inc) end
  return (d/n)^(1/p) end

function Summary:neighbors(row1,rows,       some,dist)
  some = top(the.some, shuffle(rows))
  function dist(_,row2) return {self:dist(row1,row2),row2} end
  return sort(map(some, dist), firsts) end

return Summary
