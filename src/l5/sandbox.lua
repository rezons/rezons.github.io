help=[[
asda
da
sdas
da
dasd
asd
a
da
sd
asd
as
as


OPTIONS:
  -kaa  kasdasaaas default = 23
  -mm   deada a sdas d  ade. default= asdasdaa ]]

local the={}
help:gsub("^.*OPTIONS:",""):gsub("\n%W*-(%w+)[^\n]*%W(%w+)",
   function(flag,default) 
     new = default
     for n,word in ipairs(arg) do if word==("-"..flag) then 
       new = old=="false" and "true" or arg[n+1] end end 
     the[flag] = tonumber(new) or new end)

Seed=the.seed or 10019
if the.help then print(help) else main() end
