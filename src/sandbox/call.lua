function fred(...)
  for k,v in pairs{...} do
     print(k,v) end end 

t={a=1,b=2,__call=fred}
setmetatable(t,t)

t(22)

print(t.a)
t[32]=21
print(t)
