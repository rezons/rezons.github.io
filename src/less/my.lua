local function get(s,   t,u)
  for x in s:gmatch("%w+") do 
    if not t then t,u = require(x),{} else u[ 1+#u ] = t[x] end end
  return table.unpack(u) end

return  {
  what= "guess",
  when= "(c) 2021, timm@ieee.org, unlicense.org",
  how={
      {"misc", "todo", "-do","help", "start up action"},
      {"",     "seed", "-S", 10019,  "random number seed"},
      {"dist", "p",    "-p", 2,      "distance exponent"},
      {"",     "some", "-s", 128,    "sample size for dist"}},
  b4= (function(t) t={}; for k,v in pairs(_ENV) do t[k]=v end; return t end)(),
  get=get}
