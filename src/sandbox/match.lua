s=[[

function asda(a : ?[int],b:num) : fasdas
  asd end
function bad(c:num,d) :nil
   bad end

asdas
]]

function fun(a,b,c) return a..b:gsub(":[^,)]+","").."\n" end

s=s:gsub("(function[^\n]+)(%b())(%s*:[^\n]*)\n",fun) ---"%1")
--s=s:gsub("^function[^\n]+(%b())","--")

print(s)
