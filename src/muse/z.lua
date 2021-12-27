local b4,_ = {},{}

-- Find and report local variables that accidently became globals.
b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
function _.rogues()
  for k,v in pairs(_ENV) do
    if not b4[k] then _.yellow("-- rogue? %s %s",k,type(v)) end end end

-- Print colored text to standard error.
function _.hue(n,s)    return string.format("\27[1m\27[%sm%s\27[0m",n,s) end
function _.btw(n,...)  io.stderr:write(_.hue(n,string.format(...)).."\n") end
function _.red(...)    return _.btw(31,...) end
function _.green(...)  return _.btw(32,...) end
function _.yellow(...) return _.btw(33,...) end

-- all keys, sorted
function _.keys(t,   u) 
  u={}; for k,_ in pairs(t) do u[1+#u]=k ; print(k) end; table.sort(u); return u end

-- Run some of the  "acts", resetting system back to defaults before each run.
-- Return to operating system the number of fails (so returning "0" means no errors)
function _.main(all,acts)
  local makeDefaults,reset2Defaults,runWithStackDumps,runWithNoStackDumps,known
  local fails, defaults,ok,msg
  known               = function(x) return assert(acts[x],"unknown "..x) and x end
  makeDefaults        = function()  for k,v in pairs(all) do defaults[k]=v end end
  reset2Defaults      = function()  for k,v in pairs(defaults) do all[k]=v end end
  runWithStackDumps   = function(x) acts[ known(x) ]() end 
  runWithNoStackDumps = function(x) return pcall( acts[ known(x) ] ) end
  ---------------
  fails,defaults = 0,{}
  makeDefaults()
  runWithStackDumps(all.debug) -- used when debugging one action
  if all.todo then
    for __,todo in pairs(all.todo=="all" and _.keys(acts) or {all.todo}) do
       reset2Defaults()
       ok,msg = runWithNoStackDumps(todo)
       if ok then _.green("%s%s",   "-- PASS ",todo)
             else _.red(  "%s%s %s","-- FAIL ",todo,msg); fails=fails+1 end end end
  _.yellow("-- %s errors",fails)
  _.rogues() -- check for stray locals on the way out
  os.exit(fails) end

-- Turn strings into their right types.
function _.coerce(x)
  if x=="true" then return true elseif x=="false" then return false end
  return tonumber(x) or x end

-- Check for any updated to "flag" on command line. Boolean flags have
-- no arguments (and if we see them on the command line, then flip their
-- default value). Other flags have one argument, immediately after the flag.
-- Flags do not have be spelt out in full on the command line (e.g. -t X
-- will match to the flag -todo).
function _.update(flag,x)
  for n,word in ipairs(arg) do 
    if flag:match("^"..word:sub(2)..".*") then
      x= x=="true" and"false" or x=="false" and "true" or  arg[n+1] end end
  return _.coerce(x) end

-- For help text lines starting with "  -", create a flag with a default value
-- from the first and last word on that line. Ensure that we have a random
-- number seed. Print help text (if asked to). Add a hook into "_.main".
function _.cli(s,    t)
  t={}
  s:gsub("\n  [-]([^%s]+)[^\n]*%s([^%s]+)", function(k,x) t[k]=_.update(k,x) end)
  t.seed = t.seed or 10019
  if t.h then print(s) end 
  return setmetatable(t, {__call= _.main}) end

return _.cli
