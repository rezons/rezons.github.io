isa=setmetatable
fmt=string.format
function o(t,txt,    s,sep)
  sep=""
  if txt then for w in txt:gmatch("%S+") do 
    if not s then s=w.."{" else s=fmt("%s%s:%s %s",s,sep,w,t[w]);sep=" " end end
  else for _,v in pairs(t) do 
    if not s then s="{"..v else s=fmt("%s%s%s",s,sep,v);sep=" "end end end
  return s .."}" end
  

Pet={}
function Pet.__add(i,j)    return i.age+j.age end
function Pet.__tostring(i) return o(i,"Pet age") end
function Pet.new()         return isa({age=10},Pet) end

x=Pet.new()
y=Pet.new()
y.age =10000
print(x+y)
print(x)

