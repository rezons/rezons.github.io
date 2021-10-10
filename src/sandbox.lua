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

function permutes(t)
  local a,out = {},{}
  local function worker(m)
    for _,v in pairs(t[m]) do
      a[m] = v
      if m < #t 
      then worker(m+1)
      else local b={}; for n,x in pairs(a) do b[n] = x end
           out[#out+1] = b end  end  end
  worker(1)
  return out
end

for _,x in pairs(permutes({{1,2,3},{4},{7,8}})) do print(table.concat(x,"")) end

 

