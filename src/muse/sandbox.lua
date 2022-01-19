local the,help,cat, fmt,map,words,o,is,klass = {},[[
aa
(C)2022 tim menzies

  -h  false
]]

cat = table.concat
fmt = string.format
as  = setmetatable
function klass(is,public,    t,new)
  t={}; t.__index=t
  function new(_,...)      return t.new(...) end
  function t.__tostring(i) return is..o(i,public) end
  return as(t,{__call=new}) end

function map(t,f, u) u={};for _,v in pairs(t)    do u[1+#u]=f(v) end; return u end
function words(s, u) u={};for w in s:gmatch"([^,]+)" do u[1+#u]=w end;return u end
function atom(x)   
  if x=="true" then return true elseif x=="false" then return false end
  return tonumber(x) or x end

function csv(file)
  file = io.input(file) 
  return function(    t) 
    x=io.read(); if x then return map(words(x:gsub("%s+","")),atom) end 
    io.close(file) end end 

function o(t,s)
  local f = function(slot) return fmt(":%s %s",slot,t[slot]) end
  return "{"..cat(s and map(words(s,"([^,]+)"),f) or map(t,tostring)," ").."}" end

------------------------------------------
Pet=klass("Pet","age,name")
function Pet.new(name)     return as({age=10,name=name or "Fido"},Pet) end
function Pet.fred(i)       print(i.name) end

------------------------------------------
help:gsub("\n  [-]([^%s]+)[^\n]*%s([^%s]+)", function(flag, x)
  for n,txt in ipairs(arg) do             
    if   txt:sub(1,1)=="-" and flag:match("^"..txt:sub(2)..".*") 
    then x = x=="false" and"true" or x=="true" and"false" or arg[n+1] end end 
  the[flag] = atom(x) end)

if the.h then print(help) end

x=Pet("loeverboy")
y=Pet()
y.age =10000
print(x)
x:fred()
print(o{10,20,30})
