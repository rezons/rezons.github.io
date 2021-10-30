local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local the
require"fun"
local th=require"things"


local Eg={}
function run(k)
  the = cli(options())
  k = k or the.todo
  th.Seed = the.seed
  print(green(k))
  Eg[k][2]() end

Eg.all={"all",function(    t) 
  for _,k in pairs(keys(Eg)) do if k~="all" then run(k) end end end}

Eg.sample={"read data from disk",function(    t) 
  shout(th.Sample.new(the.data).cols) end }

Eg.guess={"fil in the table",function(    t)
  t = {[3]=10,[5]=20,[6]=15,[10]=10,[11]=10,[16]=5}
  for k,v in pairs(guess(t,20)) do print(k,t[k] or 0, v) end 
  print("")
  t = {[3]=10,[4]=10,[5]=10,[15]=20}
  for k,v in pairs(guess(t,20)) do print(k,t[k] or 0, v) end 
  end}

Eg.show={"show options",function()  shout(the) end}

Eg.help={"show help",function() 
  help("lua notbad.lua",options())
  print(gray("\nACTIONS:"))
  map(keys(Eg),function(_,k) print(fmt("  -t  %-20s %s",blue(k),Eg[k][1]))end) end}

Eg.num={"reproduce a distribtion", function(r,n,tmp,sym1,sym2)
  n=th.Nums.new(0,10,10)
  tmp={}
  r=10^5
  for i=1,r do push(tmp, 10*(math.random()^.5)//1) end
  for _,x in pairs(tmp) do n:add(x) end
  sym1=th.Sym.new()
  for _,x in pairs(tmp) do  sym1:add(x //1) end
  sym2=th.Sym.new()
  for i=1,r do sym2:add(n:any()//1) end
  for _,k in pairs(keys(sym2.has)) do print(k,sym1.has[k]/ sym2.has[k]) end end}

-- ## Start-up
run()
for k,v in pairs(_ENV) do if not b4[k] then 
  if type(v)~="function" then print("? ",k,type(v)) end end  end
