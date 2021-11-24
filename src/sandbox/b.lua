s=[[

import f1 aa mm nn

function asda(a : ?[int],b:num) : fasdas
  return o end

`function X:bad(c:num,d) :nil
   ^o.bad end

^aa

`((x) a (1 1+3 ^(aa)))

`((y) ^a)
]]
function lunatic(s,is,         nohints,fun, with,fmt)
  fmt = string.format
  function nohints(a,b,c) return fmt("%s%s\n", a, b:gsub(":[^,)]+","")) end
  function fun(_,b)       return fmt("function %s end", b:sub(2,#b-1))  end
  function imports(s)
    t={}; for word in s:gmatch(  "([^ ]+)") do  t[#t+1] = word end
    local sep,pre,post,file = "","","",t[1]
    for i=2,#t do
      pre  = pre .. sep .. t[i] 
      post = post..sep..fmt('require("%s").%s',file, t[i])
      sep  = ", " end 
    return "\n"..pre .." = "..post.."\n" end
  function with(t,defaults,  u)
    u={}
    for k,v in pairs(defaults or {}) do u[k] = v end
    for k,v in pairs(t        or {}) do u[k] = v end
    return u end
  is = with(is,{FUN=true,LOCAL=true,RETURN=true,SELF=true,IMPORTS=true,LAMBDA=true})
  s = is.FUN     and s:gsub("(`)(%b())", fun)              or s
  s = is.LOCAL   and s:gsub("`","local ")                  or s
  s = is.RETURN  and s:gsub("(%s)^","%1return ")           or s
  s = is.SELF    and s:gsub("%f[%w_]o%f[^%w_]","self")     or s
  s = is.IMPORTS and s:gsub("\nimport([^\n]*)\n", imports) or s
  s = is.LAMBDA  and s:gsub("(function[^\n]+)(%b())(%s*:[^\n]*)\n",nohints) or s
  return s end

s=lunatic(s)
print(s)
