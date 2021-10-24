local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local lib = require"lib"
local Eg = lib.Eg
local csv,shout = lib.csv,lib.shout
local the

-- ## Settings, CLI
local function keys()
  lib.main(b4, "lua keys.lua", {
    {"bw",   "-B", false,  "show color strings in black and white"},
    {"bins", "-b", 10,    "number of  bins"},
    {"data", "-d", "../data/auto93.csv", "data file"},
    {"help", "-h", false,  "show help"},
    {"seed", "-S", 937162211, "random number seed"},
    {"todo", "-t", "ls",  "default start-up action"},
    {"wild", "-W", false, "wild mode, run actions showing stackdumps"}}) end

local is={}
function is.use(s) return not s:find":" end
function is.goal(s) return s:find"+" or s:find"-" or s:find"!" end
function is.num(s) return s:match"^[A-Z]" end
-- -------------------------------------------------------------
-- ## main
Range=obj"Range"
function Range.new() return isa(Range,{lo=1E32, hi=-1E32}) end
function Range:add(x)
  if x > self.hi then self.hi = x end
  if x < self.lo then self.lo = x end end

function triangle(a,c,b,   u) 
  u = rand()
  return (u < (c-a)/(b-a) and a + u*(b-a)*(c-a) or b - (1-u)*(b-a)*(b-c))^0.5

local function main(      meta) 
  meta=nil
  for row in csv(the.data) do 
    if   meta
    then true
    else meta={}
         meta.uses = map(row, is.use)
         meta.nums = map(row, function(_,s) return is.num(s) and Range.new() end)
         meta.goals= map(row, is.goal)
    end end end
-- -------------------------------------------------------------
-- ## Examples
Eg.csv= {"read from stdio", 
         function(options) the=options; main() end}
-- -------------------------------------------------------------
-- ## Start-up
keys()
