local _,this=require"_about"

local Score={}
function Score.score(b,r,B,R) return Score[this.rank](b,r,B,R) end

function Score.plan(b,r,B,R) 
  n=1E-32; b,r = b/(n+B),r/(n+R); return b<r and 0 or b^2/(b+r) end

function Score.monitor(b,r,B,R)  return Score.plan(r,b,R,B)  end

function Score.novel(b,r,B,R) 
  b,r = b/(n+B),r/(n+R); return 1/(b+r) end

return Score
