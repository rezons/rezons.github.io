local Seed=937162211

local function srand(x) Seed=x end

local function rand(lo,hi,     mult,mod)
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647
  return lo + (hi-lo) * Seed / 2147483647 end

local function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end

return {randi=randi, srand=srand, rand=rand}
