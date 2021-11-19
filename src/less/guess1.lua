local my        = require"my"
local per,firsts,sort,map  = my"tables per firsts sort map"
local push      = my"funs push abs"
local out,shout = my"prints out shout"
local round     = my"maths round"
local Best      = require"best"
local Num       = require"num"
local poly3,task,from,froms2,init

local r=math.random
local function poly3(x,x0,a,b,c) return x0 + a*x^1 + b*x^3 + c*x^3  end
local function exp(x,x0,a,b,z) return  x0 + a*x^b  end

task ={
  n=  60,
  e=  0.05,
  w=  {-- weights to be learned
       a ={-5,5}, b={-5,5}, c={-5,5}, x0={-5,5}},
  x=  {-- inputs
       x1={0,5}},
  y=  {-- outputs from our guesses (the "got")
       y1=function(x,w) return poly3(x.x1, w.x0, w.a, w.b, w.c) end},
  z=  {-- ground truth (the "want") 
       y1=function(x)   return poly3(x.x1, 1,    10, -3,  3) end}
  }

local function from(t) return t[1] + r()*(t[2] - t[1]) end

local function froms(t,u,    v)
  v={}; for k,x in pairs(t) do v[k]=from({x,u[k]}) end; return v end

local nums=Num.new()

local function mre(want,got,x)  --print(want,got)
  x = math.abs(want-got)
  return x end

local function init(it,m,n,   t,w,x,err,got,want)
  t = {}
  for i=1,m do 
    w   = map(it.w, function(_,z) return from(z) end)
    err = map(it.y, function(_,_) return 0 end)
    for i=1,n do
      x   = map(it.x, function(_,z) return from(z) end)
      got = map(it.y, function(_,f) return f(x,w)  end)
      want= map(it.z, function(_,f) return f(x)    end)
      err = map(want, function(k,x) return err[k] + mre(x, got[k]) end) 
    end
    err =map(err, function(_,x) return x/n end)
    nums:add(err.y1)
    t[1+#t] = {err.y1, w} end 
  return sort(t,firsts) end

math.randomseed(my.seed)
for _,n in pairs{10,20,50,100,200,500,1000,2000,5000} do
   local b =init(task,n,10)
   print(n,
         round(b[1][1],4),
         out(map(b[1][2],function(_,x) return round(x,4) end)))
end

print("")

print(.35*nums:spread())
for _,p in  pairs{.01,.025,.05,.1,.25,.5} do
  print(p,round(per(nums:all(),p),4)) end
for k,v in pairs(_ENV) do if not my._b4[k] then print("? ",k,type(v)) end end
