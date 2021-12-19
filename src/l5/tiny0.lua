-- standard load and  start functions
-- first line of code should be a help string (e.g. see tiny.lua)
-- last line  of code should call this code, pass in table of actions
-- e.g
--       the(go)

-- .__                
-- [__) _  _ . . _  __
-- |  \(_)(_](_|(/,_) 
--        ._|         
-- at load time, remember the current globals
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
-- after start time, complain if code has created  rogue globals
local function rogues() 
  for k,v in pairs(_ENV) do if not b4[k] then print("?:",k,type(v)) end end end

-- .  .       
-- |\/|* __ _.
-- |  ||_) (_.
-- Table keys, in sorted order
local function keys(t,u)     
  u={}; for k,_ in pairs(t) do u[1+#u]=k end;  table.sort(u); return u end 

-- pretty colors, n={31,32},={red,green}
local function color(n,s) return string.format("\27[1m\27[%sm%s\27[0m",n,s) end

-- shallow copy of a list
local function copy(t,  u)
     u={}; for k,v in pairs(t) do u[k]=v end ; return u end 

--  __. ,        ,            
-- (__ -+- _.._.-+- ___ . .._ 
-- .__) | (_][   |      (_|[_)
local help = ""

-- All the start-up actions:
-- [1] keep a copy of the options as "defaults"
-- [2] maybe just show the  help text
-- [3] maybe run an  action in verbose mode (show stackdump; halt on error)
-- [4] before actions, reset options to detaults
-- [5] before actions, reset random number seed
-- [6] maybe  run an  action in fast mode (no stackdumps; no halts one errors)
-- [7] for fast mode, count the number of failures
-- [8] return to the operating system the count of failures
-- [9] lint the code (right now, we just print rogue globals)
local function what2doAtLastLine(options, actions) 
  local fails, defaults = 0, copy(options)             -- [1]
  if options.h     then return print(help) end         -- [2]
  if options.debug then actions[ options.debug ]() end -- [3]
  local todos = options.todo =="all" and keys(actions) or {options.todo}
  for _,todo in pairs(todos) do
    if   type(actions[todo]) ~= "function" 
    then print(color(31,"NOFUN:"),todo) 
    else for k,v in pairs(defaults) do options[k]=v end -- [4]
         options.seed = options.seed or 10019           -- [5]
         local ok,msg = pcall( actions[todo] )          -- [6]
         if ok then print(color(32,"PASS ")..todo)         
               else print(color(31,"FAIL ")..todo,msg)  
                    fails=fails+1 end end                -- [7]
  end             
  rogues()           -- [9]
  os.exit(fails) end -- [8]

-- .            .__.      
-- |   *._  _   |  |._  _ 
-- |___|[ )(/,  |__|[ )(/,
-- In paragraph of the text that starts with "Options", all lines that start with
-- "-flag" have a default value as the last word on that line.
-- [1] Build the "options" array from those flags and defaults 
-- [2] Check if we can update those defaults from command line arguments).
-- [3] Anything on the command line is a string. Check if these can become nums
-- For the sake of brevity:
-- [4] command line flags need only match the start of the flag;
-- [5] for boolean values, -flag flips the default boolean
-- [6] add in the ability to call "what2doAtLastLine"
local function what2doAtFirstLine(txt)
  local options={}
  help = txt
  txt:gsub("^.*OPTIONS:",""):gsub("\n%s*-([^%s]+)[^\n]*%s([^%s]+)",
    function(flag,x) 
      for n,word in ipairs(arg) do                  -- [2]
        if flag:match("^"..word:sub(2)..".*") then  -- [4]
          x=(x=="false" and "true") or (x=="true" and "false") or arg[n+1] end end
      if     x=="true"  then x=true 
      elseif x=="false" then x=false -- [4]
      else   x= tonumber(x) or x     -- [3]
      end
      options[flag] = x end)         -- [1]
  return setmetatable(options,{__call=what2doAtLastLine}) end -- [6]

-- .__     ,          
-- [__) _ -+-. .._.._ 
-- |  \(/, | (_|[  [ )
return what2doAtFirstLine
