-- vim: ft=lua ts=2 sw=2 et:

-- # Is = magic symbols in column header
local  is={}

function is.klass(s) return s:find"=" end
function is.goal(s)  return s:find"+" or s:find"-" or s:find"=" end
function is.skip(s)  return s:find":" end
function is.num(s)   return s:match("^[A-Z]") end
function is.ako(s) 
  return is.skip(s) and Skip or (is.num(s) and Num or Sym) end

return is
