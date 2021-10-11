
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
```
This code reads samples of data. The first row of each sample shows
the names of the columns. Columns starting with an upper case letter
are numeric. Goals are either symbolic classes (denoted with with `=`
or things to be minimized or maximized (denoted with `=` or `-`).
This code will ignore any column containing `:`.

```lua
function is.klass(s) return s:find"=" end
function is.goal(s)  return s:find"+" or s:find"-" or s:find"=" end
function is.skip(s)  return s:find":" end
function is.num(s)   return s:match("^[A-Z]") end
```
Using this information, we can return different kinds of columns.

```lua
function is.ako(s, skip,num,sym) 
  return is.skip(s) and skip or (is.num(s) and num or sym) end
```
Fin.

```lua
return is
```
