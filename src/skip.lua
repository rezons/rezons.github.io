-- vim: ft=lua ts=2 sw=2 et:

--- # Skip= Columns to Ignore
local oo=require"oo"
local Skip=oo.klass"Skip"

function Skip.new(at,txt) return oo.isa(Skip,{at=at,txt=txt}) end
function Skip:add(x)      return self end

return Skip
