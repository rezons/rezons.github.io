
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>


```lua
--- # Skip= Columns to Ignore
local oo=require"oo"
local Skip=oo.klass"Skip"
function Skip.new(at,txt) return oo.isa(Skip,{at=at,txt=txt}) end
```
`Skip` columns never update their contents.

```lua
function Skip:summarize(x) return self end

return Skip
```
