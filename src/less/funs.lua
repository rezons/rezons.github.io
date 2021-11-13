local lib={}
lib.abs  = math.abs
lib.cat  = table.concat
lib.fmt  = string.format
lib.log  = math.log 
lib.pop  = table.remove
lib.push = table.insert
lib.same = function(x,...) return x  end
lib.sort = function(t,f) table.sort(t,f); return t end

return lib
