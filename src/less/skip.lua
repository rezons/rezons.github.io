local obj,has=require("my").get"metas obj has"

local Skip= obj"Skip" 
function Skip.new(i,s) return has(Skip,{at=i or 0,txt=s or ""}) end
function Skip:add(x)   return x end
function Skip:mid()    return "?" end
function Skip:spread() return "?" end

return {skip=Skip}
