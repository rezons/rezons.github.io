-- get"file" : requires the  file and unpacks results in alphabetical order
-- get"file thing1 thing2.." : requires the  file and unpacks only thing1 thing2
--
-- e.g.
-- local get=require"get"
-- local fun5,fun1=get"fun fun5 fun1" -- only returns fun5 and fun1
-- local fun1,fun2,fun3,fun4,fun5=get"fun" -- everything unpacked in alpha order
local function get(spec)
  local gets, keys,out={},{},{}
  for get in string.gmatch(spec, "([^ ]+)") do gets[#gets+1]= get end
  local results = require(table.remove(gets,1))
  if   #gets>0 
  then  keys= gets
  else  for key,_ in pairs(results) do keys[#keys+1] = key end
        table.sort(keys)
  end
  for _,key in ipairs(keys) do out[#out+1] = results[key] end
  return table.unpack(out) 
end

return get
