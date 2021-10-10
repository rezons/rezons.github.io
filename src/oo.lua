-- # Object stuff
-- LUA implements polymorphism  with a delegation trick.
-- Tables can have a "metatable" that are passed anything not
-- handled by  the table. So multiple tables can share the same
-- methods (by making  them all share  the same metatable)
-- and different tables can  respond different  to the same
-- named method (but add methods  with the same key to different
-- metatables).

local klass,  -- define a new klass
      isa,    -- define a new instance  of a klass
      out,    -- generate an instance print string
      shout   -- print the string generated via `out`.
-- Functions
function isa(mt,t) return setmetatable(t,mt) end

function klass(name,  k) 
    k={_name=name,__tostring=out};k.__index=k; return k end

function shout(t) print(out(t)) end

function out(t,     tmp,ks)
  local function pretty(x)
    return (
      type(x)=="function" and  "function") or (
      getmetatable(x) and getmetatable(x).__tostring and tostring(x)) or (
      type(x)=="table" and "#"..tostring(#x)) or ( 
      tostring(x)) end
  tmp,ks = {},{}
  for k,_ in pairs(t) do if tostring(k):sub(1,1)~="_" then  ks[1+#ks]=k end end
  table.sort(ks)
  for _,k in pairs(ks) do tmp[1+#tmp] = k.."="..pretty(t[k]) end
  return (t._name or "").."("..table.concat(tmp,", ")..")" end
--
return {klass=klass, isa=isa, out=out, shout=shout}


