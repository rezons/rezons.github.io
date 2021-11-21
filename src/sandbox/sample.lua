function one(t, total)
  total=0
  for k,x in pairs(t) do total=total+x end
  r = math.random(total)
  for k,x in pairs(t) do 
    r = r - x
    if r <= 0 then return k end end end  

--for i=1,10^7 do one{a=2,b=6,c=1,d=3} end
for i=1,10^7 do  one{a=2,b=6,c=1,d=3}  end

--for i=1,10^7 do f() end
