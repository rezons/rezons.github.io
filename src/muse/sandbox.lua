local map,words,o,is,klass
function map(t,f,   u) u={};for _,v in pairs(t)  do u[1+#u]=f(v) end; return u end
function words(s,z, u) u={};for w in s:gmatch(z) do u[1+#u]=w    end; return u end

function o(t,s)
  local f = function(slot) return string.format(":%s %s",slot,t[slot]) end
  local u = s and map(words(s,"([^,]+)"),f) or map(t,tostring)
  return "{"..table.concat(u," ").."}" end

is=setmetatable
function klass(    t,new)
  function new(_,...) return t.new(...) end
  t={}; t.__index = t; return is(t,{__call=new}) end

Pet=klass("Pet","age name")
function Pet.__add(i,j)    return i.age+j.age end
function Pet.__tostring(i) return "Pet"..o(i,"age,name") end
function Pet.new(name)     return is({age=10,name=name or "Fido"},Pet) end
function Pet.fred(i)       print(i.name) end

x=Pet("loeverboy")
y=Pet()
y.age =10000
print(x+y)
print(x)
x:fred()
print(o{10,20,30})
