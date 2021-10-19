-- vim: ft=lua ts=2 sw=2 et:

-- # Sym = columns to treat as symbols
-- ## Create
local oo=require"oo"
local Sym=oo.klass"Sym"
function Sym.new(at,txt) 
  return oo.isa(Sym,{at=at,txt=txt,n=0,mode=nil,most=1,has={}},Num) end

--  ## Update
-- Increments.
function Sym:add(x,  inc) 
  if x == "?" then return end
  inc = inc or 1
  self.n = self.n + inc
  self.has[x] = inc + (self.has[x] or 0) 
  if self.has[x] > self.most then
    self.most, self.mode = self.has[x], x end end

-- Decrements.
function Sym:sub(x,  dec) 
  if x == "?" then return end
  dec = dec or 1
  self.n = self.n - dec
  self.has[x] = self.has[x] - dec end

-- Combine two symbols
function Sym:merge(other)
  new = Sym.new(self.at, self.txt)
  for k,inc in pairs(self.has)  do new:add(k,inc) end
  for k,cin in pairs(other.has) do new:add(k,inc) end
  return new end

-- ## Query
-- Central tendency.
function Sym:mid() return self.mu end 

-- Variability about the central tendency.
function Sym:spread(    e) 
  e=0; for _,v in pairs(self.has) do 
         if v>0 then e= e- v/self.n * math.log(v/self.n,2) end end
  return e end

-- Aha's distance calculation. Symbols are either zero or one apart.
function Sym:dist(x,y) 
  return  x==y and 0 or 1 end

-- ## Fin
return Sym
