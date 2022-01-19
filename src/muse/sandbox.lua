local PET
local the,help,as, atom,csv,fmt,klass,map,o,rnd,words = {},[[
aa
(C)2022 tim menzies

  -h  false
  -file ../../data/auto93.csv
  -rnd %.2f
]]
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
fmt = string.format
as  = setmetatable
function klass(    t,new)
  t={}; t.__index=t
  function new(_,...) return t.new(...) end
  return as(t,{__call=new}) end

function map(t,f, u) u={};for _,v in pairs(t) do u[1+#u]=f(v) end; return u end
function rnd(x) return fmt(type(x)=="number" and x~=x//1 and the.rnd or"%s",x) end
function o(t)   return table.concat(map(t,rnd),", ") end
function atom(x)   
  if x=="true" then return true elseif x=="false" then return false end
  return tonumber(x) or x end

function csv(file,       cells)
  function cells(x,  t)
    t={}; for y in x:gmatch"([^,]+)" do t[1+#t]=atom(y) end; return t end
  file = io.input(file)
  return function(    x) 
    x = io.read(); if x then return cells(x) else io.close(file) end end end

------------------------------------------
PET=klass()
function PET.new(name)     return as({age=10,name=name or "Fido"},PET) end
function PET.fred(i)       print(i.name) end
function PET.__tostring(i) return fmt("PET{:age %s :name %s}",i.age,i.name) end

------------------------------------------
help:gsub("\n  [-]([^%s]+)[^\n]*%s([^%s]+)", function(slot, x)
  for n,flag in ipairs(arg) do             
    if   flag:sub(1,1)=="-" and slot:match("^"..flag:sub(2)..".*") 
    then x = x=="false" and "true" or x=="true" and "false" or arg[n+1] end end 
  the[slot] = atom(x) end)

if the.h then print(help) end

for row in csv(the.file) do print(o(row)) end

x=PET("loeverboy")
y=PET()
y.age =10000
print(x)
x:fred()
print(o{10,20,30})
for k,v in pairs(_ENV) do if not b4[k] then print("?rogue",k,type(v)) end end
