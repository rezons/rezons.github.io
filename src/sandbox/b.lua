
s=[[

`f1 gives aa mm nn

local aa,mm,nn = require("f1").aa, require("f1").mm, requre("f1").nn

function asda(a : ?[int],b:num) : fasdas
  return o end

`function X:bad(c:num,d) :nil
   ^o.bad end

^aa

`((x) a (1 1+3 ^(aa)))

`((y) ^a)
]]
fmt = string.format

function prep(s,         nohints,fun)
  function nohints(a,b,c) 
    return fmt("%s%s\n", a, b:gsub(":[^,)]+","")) end
  function fun(_,b)
    return fmt("function %s end", b:sub(2,#b-1))  end
  return s:gsub("(`)(%b())", fun)
          :gsub("`","local ")
          :gsub("(%s)^","%1return ") 
          :gsub("%f[%w_]o%f[^%w_]","self")
          :gsub("(function[^\n]+)(%b())(%s*:[^\n]*)\n",nohints) end

s=prep(s)
print(s)

s="import f1 aa mm nn"
t={}; for word in s:gmatch(  "([^ ]+)") do  t[#t+1] = word end
--t={}; for word in s:gmatch("([^,]+)") do  t[#t+1] = word end

sep,pre,post = "","",""
file=t[2]
for i=3,#t do
  word=t[i]
  pre  = pre .. sep .. word 
  post = post..sep..fmt('require("%s").%s',file, word)
  sep=", " end
print(pre .." = "..post)

