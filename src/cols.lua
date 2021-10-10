-- vim: ft=lua ts=2 sw=2 et:

-- # Cols = holds column roles
local oo=require"oo"
local Cols=oo.klass"Cols"
local is=require"is"

function Cols.new(t) 
  self= oo.isa(Cols,{ys={},xs={},xys={},head={}})
  self:header(t) 
  return self end

function Cols:header(t)
  self.head=new
  for at,txt in pairs(new) do 
    col = is.ako(txt).new(at,txt)
    push(self.xys, col)
    if not is.skip(txt) then
      if is.klass(txt) then self._klass = col end
      push(is.goal(txt) and self.ys or self.xs, col) end end end 

function Cols:add(t)
  for _,col in pairs(self.xys) do col:add( t[col.at] ) end
  return t end

-- Fin.
return Cols
