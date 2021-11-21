local lib={}

-- string shortcuts
lib.fmt   = string.format

-- meta shortcuts
lib.same  = function(x,...) return x  end

-- random shortcuts
lib.r     = math.random
lib.srand = math.randomseed

-- table position shortcuts
lib.first = function(t) return t[1] end
lib.last  = function(t) return t[#t] end
lib.second= function(t) return t[2] end

-- general table shortcuts
lib.cat   = table.concat
lib.pop   = table.remove
lib.push  = table.insert
lib.sort  = function(t,f) table.sort(t,f); return t end

-- maths shortcuts
lib.e     = 2.718281828459
lib.pi    = math.pi

lib.gt    = function(x,y) return x>y end
lib.lt    = function(x,y) return x<y end

lib.abs   = math.abs
lib.log   = math.log 
lib.sin   = math.sin 
lib.cos   = math.cos 
lib.sqrt  = math.sqrt 

return lib
