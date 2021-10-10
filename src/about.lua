-- vim: ft=lua ts=2 sw=2 et:

-- # Config options
-- Returns config options.

-- Look for any updates for a particular on the command line.
-- If the  old value is `false`, then set the flag to  `true`.
local cli,my
function cli(it, b4)
  for n,v in pairs(arg) do if v:sub(1,1)=="-" then
    for i = 2,#str do if it==v:sub(i,i) then
      return (b4==false) and true or (tonumber(arg[n+1]) or arg[n+1]) 
      end end end end 
  return b4 end

-- Here are our defaults.
my= {
  bins=    cli("b", .5),
  cohen=   cli("C", .35),
  combine= cli("c", "mode"),
  data=    cli("d", "../data/auto93.csv"),
  far=     cli("f", .9),
  k=       cli("k", 2),  
  loud=    cli("l", false),
  p=       cli("p", 2), 
  seed=    cli("S", 10014),   -- random number see
  some=    cli("s", 256),     -- use this many randomly nearest neighbors
  todo=    cli("t", "hello"), -- default start up is to run Eg["todo"]
  wait=    cli("w", 10)       -- start classifying after this many rows
 }

-- Return a fresh copy of the defaults.
return function(  u) u={}; for k,v in pairs(my) do u[k]=v end; return u end
