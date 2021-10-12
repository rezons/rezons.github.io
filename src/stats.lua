-- vim: ft=lua ts=2 sw=2 et:

-- todo samples all delta     
-- Theory note: parametric/non-parametric. effect size, significance tests
local same,cliffsDelta,bootstrap
local Num=require"num"

-- ## Effect Size 
-- Two lists re the same if an effect size test and significance test say so,
function same(xs,ys, my,     sames)
  sames = my and my.sames or 512
  if #xs > sames then xs = shuffle(xs, sames) end
  if #ys > sames then ys = shuffle(ys, sames) end
  return cliffsDelta(xs,ys,   my) and bootstrap(xs,ys,   my) end

-- Non parametric effect size test (i.e. are two distributions
-- different by more than a small amount?). Slow for large lists
-- (hint: sub-sample large lists).  Thresholds here set from
-- top of p14 of  https://bit.ly/3m9Q0pP .  0.147 (small), 0.33
-- (medium), and 0.474 (large)
function cliffsDelta(xs,ys,my,       lt,gt,thresholds)
  lt,gt,threshold = 0,0, (my and my.cliffs or .25)
  for _,x in pairs(xs) do
    for _,y in pairs(ys) do
      if y > x then gt = gt + 1 end
      if y < x then lt = lt + 1 end end end
  return math.abs(gt - lt)/(#xs * #ys) <= threshold end

-- ## Significance
-- Non parametric "significance"  test (i.e. is it possible to
-- distinguish if an item belongs to one population of
-- another).  Two populations are the same if no difference can be
-- seen in numerous samples from those populations.
-- Warning: very
-- slow for large populations. Consider sub-sampling  for large
-- lists. Also, test the effect size (and maybe shortcut the
-- test) before applying  this test.  From p220 to 223 of the
-- Efron text  'introduction to the boostrap'.
-- https://bit.ly/3iSJz8B Typically, conf=0.05 and b is 100s to
-- 1000s.
-- Translate both samples so that they have mean x, 
-- The re-sample each population separately.
function bootstrap(y0,z0,my)
  local x,y,z,xmu,ymu,zmu,yhat,zhat,tobs,ns, bootstraps, confidence
  bootstraps = my and my.bootstrap or 512
  confidence = my and my.conf or .05
  x, y, z, yhat, zhat = Num.new(), Num.new(), Num.new(), {}, {}
  for _,y1 in pairs(y0) do x:summarize(y1); y:summarize(y1) end
  for _,z1 in pairs(z0) do x:summarize(z1); z:summarize(z1) end
  xmu, ymu, zmu = x.mu, y.mu, z.mu
  for _,y1 in pairs(y0) do yhat[1+#yhat] = y1 - ymu + xmu end
  for _,z1 in pairs(z0) do zhat[1+#zhat] = z1 - zmu + xmu end
  tobs = y:delta(z)
  n = 0
  for _= 1,bootstraps do
    if adds(samples(yhat)):delta(adds(samples(zhat))) > tobs 
    then n = n + 1 end end
  return n / bootstraps >= conf end

-- ## Comparing Multiple Treatments
-- Do a top-down division of the `Num`s  in `nums`.
-- Divide  at the cut that maximizes  the  difference between
--  the  mean before and  after the cut. Stop cutting if
-- the top halves are statistically indistinguishable. 
-- Only calls the stats tests a logarithmic number of times.
function scottKnot(nums,the,      all,cohen)
  local mid = function (z) return z.some:mid() end

  local function summary(i,j,    out)
    out = copy( nums[i] )
    for k = i+1, j do out = out:merge(nums[k]) end
    return out end 

  local function div(lo,hi,rank,b4,       cut,best,l,l1,r,r1,now)
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
    return rank end 

  table.sort(nums, function(x,y) return mid(x) < mid(y) end)
  all   = summary(1,#nums)
  cohen = all.sd * the.iota
  div(1, #nums, 1, all)
  return nums end

-- ## Fin
return {same=same, cliffsDelta=cliffsDelta, bootstrap=bootstrap} 
