local function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do push(t,y) end
      tmp = io.read()
      if  #t > 0 then return map(t, function(_,x) return tonumber(x) or x end) end
    else io.close(stream) end end end

return  {csv=csv}
