local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local Eg,lib = require"lib"
local main = lib.main

-- ## Settings, CLI
local function keys()
  lib.main(b4, "lua keys.lua", function() return {
  {"bw",   "-B", false,     "show color strings in black and white"},
  {"bins", "-b", .10,        "number of  bins"},
  {"help", "-h", false,     "show help"},
  {"seed", "-S", 937162211, "random number seed"},
  {"todo", "-t", "ls",      "default start-up action"},
  {"wild", "-W", false,     "wild mode, run actions showing stackdumps"}
  } end) end

-- -------------------------------------------------------------
-- ## Examples
Eg.fred= {"asdas",function() print(1) end}
-- -------------------------------------------------------------
-- ## Start-up
keys()
