function sum1(n)
  if n > 0 then return n+sum1(n-1) else return 0 end
end
function sum2(accu,n)
  if n > 0 then return sum2(accu+n, n-1) else return accu end
end

for i = 1,8 do
  ok,msg=pcall(function() x=sum1(10^i)end)
  if ok then print(i,x) else print(i,"?") end
  print(i, sum2(0,10^i)) end
