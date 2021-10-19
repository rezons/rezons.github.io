-- ## Distance
function Sym:dist(x,y) 
  return  x==y and 0 or 1 end

function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return math.abs(x-y) end

function Sample:dist(row1,row2)
  local d,n,p,x,y,inc
  d, n, p = 0, 1E-32, the.p
  for _,col in pairs(self.cols.xs) do
    x,y = row1[col.at], row2[col.at]
    inc = x=="?" and y=="?" and 1 or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end

function Sample:dists(row1,    aux)
  function aux(_,row2) return {self:dist(row1,row2),row2} end
  return sort(map(self.rows, aux),first) end

function Sample:biCluster(rows,        one,two,c,todo,left,right,mid,far,aux)
  function far(row,   t) 
    t=self:dists(row); return t[the.far*#t//1] end 
  function aux(_,x) 
    a,b=self:dist(x,one),self:dist(x,two); return {(a^2+c^2-b^2)/(2*c),x} end
  rows  = rows or self.rows
  _,one = self:far(any(rows))
  c,two = self:far(one)
  todo  = sort(map(rows, aux),first)
  left, right, mid  = {}, {}, #todo//2
  for i,x in pairs(todo) do push(i<=mid and left or right, x[2]) end
  return left,right end


