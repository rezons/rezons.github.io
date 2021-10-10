
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>


```lua
local klass,  -- define a new klass
      isa,    -- define a new instance  of a klass
      out,    -- generate an instance print string
      shout   -- print the string generated via `out`.
```
Functions

```lua
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

```
