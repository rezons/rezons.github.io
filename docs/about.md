
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<b>data:</b> <a href="rows.md">rows</a>,<a href="row.md">row</a>;
<b>cols:</b> <a href="num,md">num</a>,<a href="sym.md">sym</a>,<a href="skip,md">skip</a>;
<b>functions:</b> <a href="strings.md">strings</a>,<a href="maths.md">maths</a><br>


<img align=right width=300
src="https://user-images.githubusercontent.com/29195/130312030-beab122a-3526-4877-bcce-c8b94a387281.png">
<h1>about.lua</h1><br clear=all>


```lua
my= {
  combine= cli("-c", "mode"),
  data=    cli("-d", "../data/auto93.csv"),
  far=     cli("-f", .9),
  k=       cli("-k", 2),  
  p=       cli("-p", 2), 
  seed=    cli("-S", 10014),   -- random number see
  some=    cli("-s", 256),     -- use this many randomly nearest neighbors
  todo=    cli("-t", "hello"), -- default start up is to run Eg["todo"]
  wait=    cli("-w", 10)       -- start classifying after this many rows
 }
```
Look for any updates for a particular on the command line.
If the  old value is `false`, then set the flag to  `true`.

```lua
function cli(flag, b4)
  for n,v in pairs(arg) do if v==flag then 
    return (b4==false) and true or (tonumber(arg[n+1]) or arg[n+1]) end end 
  return b4 end
```
Return a fresh copy of the options.

```lua
return function(  u) u={}; for k,v in pairs(my) do u[k]=v end; return u end

```
