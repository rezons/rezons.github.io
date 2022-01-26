local COL, NUM
function o(i)
  local u,v={},{};  
  for k,_ in pairs(i) do k=tostring(k) if k:sub(1,1)~="_" then u[1+#u]=k;end end
  table.sort(u)
  for _,k in pairs(u) do v[1+#v] = string.format(":%s %s",k,i[k]) end
  return "{"..table.concat(v," ").."}" end

function new(k,t) 
  k={__tostring=o}; k.__index=k; return setmetatable(t,k) end

COL={}
function COL.new(k,at,n) return new(k,{at=at or 20, n=n or 30,s=s or ""}) end
function COL.add(i,x) print("--",x) end

NUM=COL:new()


--function NUM.add(i,x) print("++",x) end

n1=NUM:new(100)
n2=NUM:new()
n1.at=100
--print(n1:add(25))
print(n1, n2)
