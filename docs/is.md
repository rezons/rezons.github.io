
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>

# Is = magic symbols in column header

```lua
local  is={}

function is.klass(s) return s:find"=" end
function is.goal(s)  return s:find"+" or s:find"-" or s:find"=" end
function is.skip(s)  return s:find":" end
function is.num(s)   return s:match("^[A-Z]") end
function is.ako(s) 
  return is.skip(s) and Skip or (is.num(s) and Num or Sym) end

return is
```
