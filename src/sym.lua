-- vim: ft=lua ts=2 sw=2 et:

-- # Sym = columns to treat as symbols
local oo=require"oo"
local Sym=oo.klass"Sym"

-- Create.
function Sym.new(at,txt) 
  return oo.isa(Sym,{at=at,txt=txt,n=0,mode=nil,most=1,has={}},Num) end

-- Update.
function Sym:add(x,  inc) 
  if x ~= "?" then
    inc = inc or 1
    i.n = i.n + inc
    self.has[x] = inc + (self.has[x] or 0) 
    if self.has[x] > self.most then
      self.most, self.mode = self.has[x], x end end 
  return self end

-- Aha's distance calculation. Symbols are either zero or one apart.
function Sym:dist(x,y) 
  return  x==y and 0 or 1 end

-- Combine to Symbols
function Sym:merge(other)
  new = Sym.new(self.at, self.txt)
  for k,n in pairs(self.has) do new:add(k,n) end
  for k,n in pairs(other.has) do new:add(k,n) end
  return new end

-- Fin
return Sym
