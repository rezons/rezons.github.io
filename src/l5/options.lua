local lib=require"lib"

-- ____   _      ____   ____   ____ 
-- |___   |      |__|   | __   [__  
-- |      |___   |  |   |__]   ___] 
local function help(about)
  lib.say("\n%s [OPTIONS]\n%s\n%s\n\nOPTIONS:\n",
          arg[0], about.who, about.what)
  for _,t in pairs(about.how) do 
    lib.say("%4s %-9s%-30s%s %s",
            t[2],t[3] and t[1] or"", t[4],t[3] and"=" or"",t[3] or"") end
  print("\n"..about.why) end

-- Update fields from the command  line.
local function cli(about,u)
  u={}
  for _,t in pairs(about.how) do -- update defaults from command line
    u[t[1]] = t[3]
    for n,word in ipairs(arg) do if word==t[2] then
      local new = t[3] and (tonumber(arg[n+1]) or arg[n+1]) or true 
      assert(type(new) == type(u[t[1]]), word.." expects a "..type(u[t[1]]))
      u[t[1]] = new end end end
  lib.Seed = u.seed or 10019
  if u.HELP then help(about); os.exit() end
  return u end

-- ____   ___   ____   ____   ___        _  _   ___  
-- [__     |    |__|   |__/    |    __   |  |   |__] 
-- ___]    |    |  |   |  \    |         |__|   |    
-- make everything  the. the.Eg, 
-- assumes the, about, eg
local function main(settings,demos,    defaults,fails)
  defaults={}
  for k,v in pairs(settings) do defaults[k]=v end
  fails=0
  local function example(k,      f,ok,msg)
    f= demos[k]
    assert(f,"unknown action "..k)
    for k,v in pairs(defaults) do settings[k]=v end
    lib.Seed  = settings.SEED or 10019
    if settings.WILD then return f() end
    ok,msg = pcall(f)
    if ok then print(lib.green("PASS"),k) 
    else       print(lib.red("FAIL"),  k,msg); fails=fails+1 end 
  end ---------------------
  if     settings.TODO == "all" 
  then   lib.lap(lib.keys(demos),example) 
  elseif settings.TODO == "ls"
  then   print("\nACTIONS:")
         lib.map(lib.keys(demos),function(_,k) print("\t"..k) end)
  else   example(settings.TODO) 
  end
  lib.rogues()
  return os.exit(fails) end

-- _   _  _   _   ___ 
-- |   |\ |   |    |  
-- |   | \|   |    |  
-- return all the above functions, augmented with   
-- (1) any update on the constants from the command line;   
-- (2) a call method that offer some extra services.   
-- To avoid name classes (of config settings and functions),
-- always use UPPER CASE for the variables and lower case for
-- the first letter of the functions.
return function(t) 
  local function worker(settings,actions)
    for flag,val in pairs(actions or {}) do
      if flag=="nervous" and val then lib.rogues() end
      if flag=="demos"           then main(settings,val) end end 
    return t end
  t = cli(t)
  return setmetatable(t, {__call=worker}) end
