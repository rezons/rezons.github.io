return function(f,   t,u)
  f = require(f)
  t = {}; for k,_ in pairs(f) do t[#t+1] = k end
  table.sort(t)
  u = {}; for _,k in pairs(t) do u[#u+1] = f[k] end
  return table.unpack(u) end
