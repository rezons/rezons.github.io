function items(t)
  local i,n=0,#t
  return function (now)
    if i<n then
      i=i+1
      now=t[i]
      if   type(now) == "table" 
      then for now1 in items(now) do return now1 end end 
      else return now end end end 
   
for x in items{{1,2},3,{4,{5,6}}} do print(x) end
