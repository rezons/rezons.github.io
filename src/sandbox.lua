function combo(n)
  local a,out = {},{}
  local function worker(m)
    for i = 1, n do
      a[m] = i
      if   m < n 
      then worker(m + 1)
      else local b={}; for n,x in pairs(a) do b[n] = x end
           out[#out+1] = b end  end  end
  worker(1)
  return out end

for _,x in pairs(combo(3)) do print(table.concat(x,"")) end

 

