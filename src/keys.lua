local b4={}; for k,v in pairs(_ENV) do b4[k]=v end

local _,Eg=require"Lib"

local map,shout,sort,about,cli,fmt=_.map,_.shout,_.sort,_.about,_cli,_.fmt
local go,isa,out,keys,obj,the,help = _.go,_.isa,_.out,_.keys,_.obj,_.the,_.help
local push,blue,fmt,randi,yellow =  _.push,_.blue, _.fmt,_.randi,_.yellow 
local rand,green,seed,cat,red = _.rand,_green, _.seed,_.cat, _.red

-- ## Settings, CLI
-- Check if `the` config variables are updated on the command-line interface.
function about(f) return {
  {"bw",     "-B", false, "show color strings in black and white"},
  {"bins",  "-b", .10,   "number of  bins"},
  {"help",   "-h", false, "show help"},
  {"seed",   "-S", 937162211,"random number seed"},
  {"todo",   "-t", "ls",  "default start-up action"},
  {"wild",   "-W", false, "wild mode, run actions showing stackdumps"}} end

-- -------------------------------------------------------------
-- ### Unit tests
local fails =  -1
-- ## Examples
Eg.fail={"demo failure", function () assert(false,"oops") end}

if cli().help then help("lua ibc.lua") else go(cli().todo) end
for k,v in pairs(_ENV) do if not b4[k] then print("?? ",k,type(v)) end end 
os.exit(fails) 
