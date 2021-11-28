--[[ 
Converts things  like this into help text and a table of values
{SLOT1 = VALUE1, SLOT2 = VALUE2,.. } where each VALUE is one of the
DEFAULTs below, updated from the  command line (if there exists
FLAG on the command line.

{ what= USAGE
  when= COPYRIGHT
  how = {
    GROUP1 = {SLOT1 = {FLAG1, DEFAULT1, HELP1},
              SLOT2 = {FLAG2, DEFAULT2, HELP2}},
    GROUP2 = {...} }
}
--]]

local function items(t) 
  local i,u = 0,{}; for k,_ in pairs(t) do u[ 1+#u ]=k end
  table.sort(u)
  return function() if i<#u then i=i+1; return u[i], t[u[i]] end end end 

local function helpString(opt)
  print( opt.what .. " [OPTIONS]\n" .. opt.when .. "\n\nOPTIONS:" )
  for group,slots in items(opt.how) do
    print("\n"..group..":")
    for _,x in items(slots) do
      local what= (x[2]==false          and "   ") or (
                   type(x[2])=="number" and " N ") or (
                   type(x[2])=="string" and " S ") or (
                   " X ")
      print(string.format("  %3s  %s  %s [default=%s]",
            x[1],what,x[3],x[2])) end end end

local function updateFromCommandLine(t0,   t)
  t={}
  for group,slots in pairs(t0) do
    for key,x in pairs(slots) do
      t[key] = x[2]
      for n,word in ipairs(arg) do if word==x[1] then
        t[key] = x[2]==false and true or tonumber(arg[n+1]) or arg[n+1]
        end end end end
  return t end

local function someFunsFromFile(s,   u,file)
  u={}
  for word in s:gmatch("%w+") do 
    if   not file 
    then file = word
    else assert(require(file)[word] ~= nil, word.." not in "..file) 
         u[ 1+#u ] = require(file)[word] end end
  return table.unpack(u) end
  
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

local function rogues(b4)
  for k,v in pairs(_ENV) do 
    if not b4[k] then 
      print("?? rogue",k,type(v)) end end end

local function what2do(thing,t)
  if thing=="END"  then return rogues(b4)    end
  if thing=="HELP" then return helpString(t) end
   return someFunsFromFile(thing)  end 

return function(t)
  t = updateFromCommandLine(t.how)
  t.get = function(thing) return what2do(thing,t) end
  return t end 
