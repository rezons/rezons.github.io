-- vim: ft=lua ts=2 sw=2 et:

-- # Is = magic symbols in column header
local  is={}
-- This code reads samples of data. The first row of each sample shows
-- the names of the columns. Columns starting with an upper case letter
-- are numeric. Goals are either symbolic classes (denoted with with `=`
-- or things to be minimized or maximized (denoted with `=` or `-`).
-- This code will ignore any column containing `:`.
function is.klass(s) return s:find"=" end
function is.goal(s)  return s:find"+" or s:find"-" or s:find"=" end
function is.skip(s)  return s:find":" end
function is.num(s)   return s:match("^[A-Z]") end

-- Using this information, we can return different kinds of columns.
function is.ako(s, skip,num,sym) 
  return is.skip(s) and skip or (is.num(s) and num or sym) end

-- Fin.
return is
