# How to Contribute

This code adheres to the following conventions.

## Less, but Better

Deiter rams, minimality. less cpu. usable without needs massive on-line resources
(which may be expensive to maintain, and could be taken away atht whim
of anyone else). less to read, undestand, easer to maintain

e.g. repalce ON(^2) compute with qrt(N) random sample before the O(N^2)
compariosn'

## Questions, not answers

"(Computers are)  useless. They can only give you answers."     
-- Pablo Picasso


## Refactor AI tools (mix and match)

not black box devices, but thigns we can mix together

hard to list all the influences here, but here is an ttempt:

- asdas
- Bayes paramea pptionization
- nonparametric reasonong
- random projections

## Nonparametric reasonong

world not normal

symbols and number s9epecailly when dealing with legistraltion)


## Hyerparameter optimziation

### Fairness

## Mechanisms, not Policies (use Domain-Specific Languages)

very simple, defined using regular expressions

data file header

help string

so all control parameters in one global

## Functional programming

## UNIX scripts

### Return number of errors

UNIX return the number of error encountered in actual operation
(this is used to support test-driven development, see below).  Hence,
this code has a  global `fails` that is updated if any assertion
fails (by the `azzert` function).  The final act of this code is
`os.exit(fails)`, which returns the number of failures.  For example,
this code prints "0" if no errors are encountered.

    lua keys.lua; echo $?

### Describe yourself

UNIX scripts offer command line help. This code  starts with a help
string that can be displayed, using the `-h` command.

### Customize on command-line

UNIX scripts can be customized by command-line flags. 
Inspired by the wonderful
[docopt](http://docopt.org/), this tool
contains a small parser that extracts flags (and their defaults)
from the help string:

```lua
function options(help_string)
  local t,update_from_cli  
  function update_from_cli(flag,x) 
    for n,txt in ipairs(arg) do         
      if   flag:match("^"..txt:sub(2)..".*") -- allow abbreviations for flags
      then x = x=="false" and"true" or x=="true" and"false" or arg[n+1] end end 
    t[flag] = coerce(x) end

  t={}
  help_string:gsub("\n  [-]([^%s]+)[^\n]*%s([^%s]+)", update_from_cli) 
  return t end
```
The regular expression on the second last line
extracts command line flags and defaults as the first and last word
on any line starting the two blank spaces and a dash.
For example, a help string code defines a 
 random number seed as follows:

      -seed   I  random number seed             : 10019
 
The function `update_from_cli` checks the command line for updates
to the defaults.  It supports two shorthand conventions:

- Partial match to flags; e.g. `-s  2000` is the same as `-seed 2000`;
- Toggling booleans; e.g., for a flag `X` is  a boolean default value
  then a command line entry of `-X` will toggle `false` to `true` (i.e.
  it enables that options).

## Test driver development.

## Dialog independence

## Domain-specific languages.

## Polymorphisms and Encapulation Rules! (and not Inheritance)

## N-1 globals is better than N

Apart from classes, this code makes minimal use of globals.


## Control the Seeds

## Documentation

All functions have help text with type hints. In those hints,

|Symbol| Notes                             |
|------|-----------------------------------|
| \|   | or                                |
| ?    | optional                          |
| any  | anything                          |
| str  | string                            |
| int  | integer                           |
| num  | float                             |
| bool | boolean                           |
| fun  | function                          |
| KLASS| any of the current instance types |

For method calls the method call type hint is:

- **i:KLASS:method(args...)**

This can be a little confusing the first time you read it (two colons to the left of the brackets) but given LUA's OO horthand and the standard conventions on how to do type hints, that is what we need to do here.

## Syntax

- Define all local names before they are used (so we can access them in any order).
- No tabs
- 2 spaces for indent
- No lines containing just "end"
- Create classes using `klass`.
- Create instances using `KLASS(...)`
- use "i" for self

## Local Stuff

- mid, div = synonms for mean,mode or stand deviation, entropy

$$ LUA notes

Why lua? why note? powerful lrlanguge. batteries nt incuded . encorauges minimaliity. Pwoerful alngauge. deletagation, functions, emta-rogrammingfacities. very portable. simple to elarn.

Traaining tool: recode THIS in what ever language you like.
