package.path = '../src/?.lua'
math.randomseed(require("about")().seed)

local Sample=require"sample"

local function ish(x,y,e) return math.abs(x-y) < (e or 0.01) end

local s=Sample

local s=Sample.new
