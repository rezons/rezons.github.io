local has,obj

-- Instance  creation
function has(mt,x) return setmetatable(x,mt) end

-- Object creation.
function obj(s, o) o={_is=s, __tostring=out}; o.__index=o; return o end

return {has=has, obj=obj}
