local function cli(flag, b4)
  for n,v in pairs(arg) do if v==flag then 
    return (b4==false) and true or (tonumber(arg[n+1]) or arg[n+1]) end end 
  return b4 end

local my= {
  combine= cli("-c", "mode"),
  data=    cli("-d", "../data/auto93.csv"),
  far=     cli("-f", .9),
  k=       cli("-k", 2),  
  p=       cli("-p", 2), 
  seed=    cli("-S", 10014),   -- random number see
  some=    cli("-s", 256),     -- use this many randomly nearest neighbors
  todo=    cli("-t", "hello"), -- default start up is to run Eg["todo"]
  wait=    cli("-w", 10)       -- start classifying after this many rows
 }

return function(  u) u={}; for k,v in pairs(my) do u[k]=v end; return u end
