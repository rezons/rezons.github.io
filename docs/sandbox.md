
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>


```lua
function permutes(t)
  local a,out = {},{}
  local function worker(m)
    for _,v in pairs(t[m]) do
      a[m] = v
      if m < #t 
      then worker(m+1)
      else local b={}; for n,x in pairs(a) do b[n] = x end
           out[#out+1] = b end  end  end
  worker(1)
  return out
end

for _,x in pairs(permutes({{1,2,3},{4},{7,8}})) do print(table.concat(x,"")) end

 
```
