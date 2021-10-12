
<img alt="Lua" src="https://img.shields.io/badge/lua-v5.4-blue">&nbsp;<a 
href="https://github.com/timm/keys/blob/master/LICENSE.md"><img
alt="License" src="https://img.shields.io/badge/license-unlicense-red"></a> <img
src="https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet"> <img
alt="Platform" src="https://img.shields.io/badge/platform-osx%20,%20linux-lightgrey"> <a
href="https://github.com/timm/keys/actions"><img
src="https://github.com/timm/keys/actions/workflows/unit-test.yml/badge.svg"></a>

<hr>

# Config options
For any word on the command line starting with "-",
break the word into characters. If any  character
matches `it`, then  return a new  value. Else return  the `b4`  value.

```lua
local function cli(it, b4)
 for n,word in pairs(arg) do if word:sub(1,1)=="-" then
  for i = 2,#str do if it==word:sub(i,i) then
   return (b4==false) and true or tonumber(arg[n+1]) or arg[n+1] end end end end 
 return b4 end
```
Here are the defaults.

```lua
local my= {
  sames=   cli("A",   512), -- number of things to use in stats tests
  bins=    cli("b",  .5),
  best=    cli("B",  .5),
  cohen=   cli("C",  .35),
  combine= cli("c",  "mode"),
  data=    cli("d",  "../data/auto93.csv"),
  far=     cli("f",  .9),
  conf=    cli("F",  .05), -- confidence limits for stats
  k=       cli("k",  2),  
  cliffs=  cli("I",  (.147+.33)/2), -- small effect size threshold
  loud=    cli("l",  false),
  bootstraps=cli("O", 512),
  p=       cli("p",  2), 
  seed=    cli("S",  1971603567),  -- random number see
  some=    cli("s",  256),     -- use this many randomly nearest neighbors
  todo=    cli("t",  "hello"), -- default start up is to run Eg["todo"]
  wait=    cli("w",  10)       -- start classifying after this many rows
 }
```
Return a function that always returns a fresh copy of the defaults.
Theory note: random number generation

```lua
return function(  u) 
  math.randomseed(my.seed); 
  u={}; for k,v in pairs(my) do u[k]=v end; return u end
```
