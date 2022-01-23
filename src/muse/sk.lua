local same,cliffsDelta,bootstrap
local Num=require"num"
-- from https://github.com/timm/keys/blob/fd79b481053e2679856078df3a9f74f7097f5812/src/num.lua
function same(xs,ys)
  if #xs > your.ampl then xs = many(xs, your.ampl) end
  if #ys > your.ampl then ys = shuffle(ys, your.amlp) end
  return cliffsDelta(xs,ys) and bootstrap(xs,ys) end

-- top of p14 of  https://bit.ly/3m9Q0pP .  0.147 (small), 0.33
-- (medium), and 0.474 (large)
function cliffsDelta(xs,ys)
  local lt,gt = 0,0
  for _,x in pairs(xs) do
    for _,y in pairs(ys) do
      if y > x then gt = gt + 1 end
      if y < x then lt = lt + 1 end end end
  return math.abs(gt - lt)/(#xs * #ys) <= your.cliffs end

-- adds
--samples
-- function Num:delta(other,      y,z,e)
--    e, y, z = 1E-32, self, other
--    return math.abs(y.mu - z.mu) / (
--              (e + y.sd^2/y.n + z.sd^2/z.n)^.5) end
--  From p220 to 223 of the
-- Efron text  'introduction to the boostrap'.
-- https://bit.ly/3iSJz8B Typically, conf=0.05 and b is 100s to
-- 1000s.
function bootstrap(y0,z0)
  local  x,y,z,xmu,ymu,zmu,yhat,zhat,tobs
  x, y, z, yhat, zhat = Num(), Num(), Num(), {}, {}
  for _,y1 in pairs(y0) do x:add(y1); y:add(y1)           end
  for _,z1 in pairs(z0) do x:add(z1); z:add(z1)           end
  xmu, ymu, zmu = x.mu, y.mu, z.mu
  for _,y1 in pairs(y0) do yhat[1+#yhat] = y1 - ymu + xmu end
  for _,z1 in pairs(z0) do zhat[1+#zhat] = z1 - zmu + xmu end
  tobs = y:delta(z)
  n = 0
  for _= 1,your.bootstrap do
    if adds(samples(yhat)):delta(adds(samples(zhat))) > tobs 
    then n = n + 1 end end
  return n / your.bootstrap >= your.conf end

function scottKnot(nums,      all,cohen)
  local mid = function (z) return z.some:mid() end
  local function summary(i,j,    out)
    out = copy( nums[i] )
    for k = i+1, j do out = out:merge(nums[k]) end
    return out 
  end -------- 
  local function div(lo,hi,rank,b4)
    local        cut,best,l,l1,r,r1,now
    best = 0
    for j = lo,hi do
      if j < hi  then
        l   = summary(lo,  j)
        r   = summary(j+1, hi)
        now = (l.n*(mid(l) - mid(b4))^2 + r.n*(mid(r) - mid(b4))^2
              ) / (l.n + r.n)
        if now > best then
          if math.abs(mid(l) - mid(r)) >= cohen then
            cut, best, l1, r1 = j, now, copy(l), copy(r) 
    end end end end
    if cut and not l1:same(r1,the) then
      rank = div(lo,    cut, rank, l1) + 1
      rank = div(cut+1, hi,  rank, r1) 
    else
      for i = lo,hi do nums[i].rank = rank end end
    return rank 
  end --------- 
  nums= sort(nums, function(x,y) return mid(x) < mid(y) end)
  all   = summary(1,#nums)
  cohen = all.sd * the.iota
  div(1, #nums, 1, all)
  return nums end
