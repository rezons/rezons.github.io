local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local btw,hue,keys,main,cli

function btw(...) io.stderr:write(string.format(...).."\n") end
function hue(n,s) return string.format("\27[1m\27[%sm%s\27[0m",n,s) end
function keys(t,   u) 
  u={}; for k,_ in pairs(t) do u[1+#u]=k ; print(k) end; table.sort(u); return u end

function main(globals,acts,     fails,defaults,todos,ok,msg)
  fails, defaults = 0,{}
  for k,v in pairs(globals) do defaults[k]=v end
  if globals.debug then acts[ globals.debug ]() end
  todos= globals.todo=="all" and keys(acts) or globals.todo and {globals.todo} or {}
  for _,todo in pairs(todos) do
     for k,v in pairs(defaults) do globals[k]=v end
     ok,msg = pcall( acts[todo] )
     if ok then btw("%s%s",hue(32,"-- PASS "),todo)
         else btw("%s%s %s",hue(31,"-- FAIL "),todo,msg); fails=fails+1 end 
  end
  btw(hue(33,"-- %s errors"),fails)
  for k,v in pairs(_ENV) do
    if not b4[k] then btw(hue(31,"-- rogue? %s %s"),k,type(v)) end end
  os.exit(fails) end

function cli(txt,    out)
  out={}
  txt:gsub("\n  [-]([^%s]+)[^\n]*%s([^%s]+)",
    function(flag,x)
      for n,word in ipairs(arg) do -- check for any updated to "flag" on command line
        -- use any command line "word" that matches the start of "flag"
        if flag:match("^"..word:sub(2)..".*") then
          -- command line "word"s for booleans flip the default value
          x=(x=="false" and "true") or (x=="true" and "false") or arg[n+1] end end
      if x=="true" then x=true elseif x=="false" then x=false else x=tonumber(x) or x end
      out[flag] = x end)
  out.seed = out.seed or 10019
  if out.h then print(txt) end 
  return setmetatable(out, {__call= main}) end

return cli
