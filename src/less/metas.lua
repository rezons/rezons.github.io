local out=require("prints").out
local has,obj

-- Instance  creation
function has(mt,x) return setmetatable(x,mt) end

-- Object creation.
function obj(s, o) 
   o={ _is        = s,
       __tostring = out,
       __call     = function(_,...) return o.new(...) end}
   o.__index=o
   return setmetatable(o,o) end 

return {has=has, obj=obj}
