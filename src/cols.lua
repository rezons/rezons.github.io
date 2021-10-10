-- vim: ft=lua ts=2 sw=2 et:

-- # Cols = holds column roles
local oo=require"oo"
local Cols=oo.klass"Cols"

function Cols.new() return oo.isa(Cols,{ys={},xs={},xys={},head={}}) 

-- Definitions of special column header roles.
function Cols:isKlass(s) return s:find"=" end
function Cols:isGoal(s)  return s:find"+" or s:find"-" or s:find"=" end
function Cols:isSkip(s)  return s:find":" end
function Cols:isNum(s)   return s:match("^[A-Z]") end
function Cols:ako(s) 
  return self:isSkip(s) and Skip or (self:isNum(s) and Num or Sym) end

function Col:header(t)
  self.head=new
  for at,txt in pairs(new) do 
    col = ako(txt).new(at,txt)
    push(self.xys, col)
    if not self:isSkip(txt) then
      if self:isKlass(txt) then self._klass = col end
      push(self:isGoal(txt) and self.ys or self.xs, col) end end end end

-- Fin.
return Cols
