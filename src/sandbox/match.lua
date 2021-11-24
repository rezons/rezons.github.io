s=[[

function asda(a : ?[int],b:num) : fasdas
  asd end
function bad(c:num,d) :nil
   bad end

map(x,`((x) return print(x)))

asdas
]]

function fun(a,b,c) return a..b:gsub(":[^,)]+","").."\n" end

s=s:gsub("(function[^\n]+)(%b())(%s*:[^\n]*)\n",fun) ---"%1")
--s=s:gsub("^function[^\n]+(%b())","--")

s=s:gsub("`[\(](%b())[\)]","function %1 end") 
print(s)
