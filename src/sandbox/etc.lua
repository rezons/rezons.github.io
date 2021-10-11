-- # Tricks
local isa,klass,push,atom,shout,out,shuffle,top,cli,main,csv,cat
-- ## Shortcuts
push=table.insert

-- ## OO stuff

-- Make instance
function isa(mt,t) return setmetatable(t,mt) end
-- Make klass
function klass(name,  k) k={_name=name,__tostring=out};k.__index=k; return k end

-- ## String stuff

-- Coerce things to numbers, if myy want to
function atom(x) return tonumber(x) or x end

-- Print a flat string of a table
function cat(t,s) return "("..table.concat(t,s or ", ")..")" end

-- Print a nested string of a table
function shout(t) print(out(t)) end

-- Convert a table to astring
function out(t,     tmp,ks)
  local function pretty(x)
    return (
      type(x)=="function" and  "function") or (
      getmetatable(x) and getmetatable(x).__tostring and tostring(x)) or (
      type(x)=="table" and "#"..tostring(#x)) or ( 
      tostring(x)) end
  tmp,ks = {},{}
  for k,_ in pairs(t) do 
    if tostring(k):sub(1,1) ~= "_" then  ks[1+#ks]=k  end end
  table.sort(ks)
  for _,k in pairs(ks) do tmp[1+#tmp] = k.."="..pretty(t[k]) end
  return (t._name or "")..cat(tmp) end

-- ## List stuff

-- reorder a list (in place)
function shuffle(t,     j)
  for i = #t, 2, -1 do
    j = math.random(i)
    t[i], t[j] = t[j], t[i] end
  return t end

-- First few items in a list
function top(n,t,     u) 
  n = math.min(n,#t)
  print("n3",n)
  u={}; for i=1,n do u[i]=t[i] end; return u end

-- ## Sys stuff

-- Read rows from csv file
function csv(file,      n,split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  n      = 0
  return function(       t)
    if tmp then
      t, tmp = {}, tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if  #t > 0 then
        for j,x in pairs(t) do t[j] = atom(x) end
        n = n + 1
        return n,t end
    else io.close(stream) end end end

-- Start up
function main(todo,my,b4,     x)
  for n,v in pairs(arg) do -- apply any command line args
    if v:sub(1,1)=="-" then 
      x = v:sub(2,#v) 
      my[x] = my[x]==false and true or atom(arg[n+1]) end end 
  math.randomseed(my.seed)  -- reset the seed to some standard
  todo[my.todo]( my )         -- call some function
  for k,v in pairs(_ENV) do -- check for rogue varaiables
    if not b4[k] then io.stderr:write("?? "..k.."\n") end end  
  os.exit()                 -- good bye 
end

return {cat=cat,main=main,csv=csv,isa=isa, klass=klass,
        shuffle=shuffle,top=top,push=push,atom=atom,shout=shout,out=out} 
