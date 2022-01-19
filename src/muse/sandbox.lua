local your,our={},{} -- things that can, can't be changed from command line
local as,csv,fmt,klass,map,o,rnd,rows,thing,things
local PET
our.help= [[
local PET
aa
(C)2022 tim menzies

  -h  false
  -file ../../data/auto93.csv
  -rnd %.2f
]]
our.b4={}; for k,_ in pairs(_ENV) do our.b4[k]=k end

fmt = string.format
as  = setmetatable

function klass(    t,new)
  t={}; t.__index=t
  function new(_,...) return t.new(...) end
  return as(t,{__call=new}) end

function map(t,f, u) u={};for _,v in pairs(t) do u[1+#u]=f(v) end; return u end

function rnd(x) return fmt(type(x)=="number" and x~=x//1 and your.rnd or"%s",x) end

function o(t) return "{"..table.concat(map(t,rnd),", ").."}" end

function thing(x)   
  if x=="true" then return true elseif x=="false" then return false end
  return tonumber(x) or x end

function things(x,sep,  t)
  t={};for y in x:gmatch(sep or"([^,]+)") do t[1+#t]=thing(y) end; return t end

function rows(file,      x)
  file = io.input(file)
  return function() 
    x=io.read(); if x then return things(x) else io.close(file) end end end

------------------------------------------
PET=klass()
function PET.new(name)     return as({age=10,name=name or "Fido"},PET) end
function PET.fred(i)       print(i.name) end
function PET.__tostring(i) return fmt("PET{:age %s :name %s}",i.age,i.name) end

CAT=klass()
function CAT.new(name)     return as({wealth=1,handle=name or "Pussy"},CAT) end
function CAT.fred(i)       print(i.handle) end
function CAT.__tostring(i) return fmt("CAT{:wealth %s :handle %s}",i.wealth,i.handle) end

------------------------------------------
our.help:gsub("\n  [-]([^%s]+)[^\n]*%s([^%s]+)", function(slot, x)
  for n,flag in ipairs(arg) do             
    if   flag:sub(1,1)=="-" and slot:match("^"..flag:sub(2)..".*") 
    then x = x=="false" and "true" or x=="true" and "false" or arg[n+1] end end 
  your[slot] = thing(x) end)

if your.h then print(help) end

--for row in rows(your.file) do print(o(row)) end

x=PET("loeverboy")
y=PET()
y.age =10000
print(x)
x:fred()

x=CAT("clarence")
y=CAT()
y.wealth =1999
print(y)
y:fred()

print(o{10,20,30})
for k,v in pairs(_ENV) do if not our.b4[k] then print("?rogue",k,type(v)) end end
