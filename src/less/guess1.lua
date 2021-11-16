local my        = require"my"
local firsts,sort,map  = my.get"tables firsts sort map"
local push      = my.get"funs push abs"
local out,shout = my.get"prints out shout"
local Best      = require"best"
local poly3,task,from,froms2,init

local r=math.random
local function poly3(x,x0,a,b,c) return x0 + a*x^1 + b*x^3 + c*x^3  end
local function exp(x,x0,a,b) return x0 + a*x^b  end

task ={
  n=  60,
  e=  0.05,
  w=  {-- weights to be learned
       a ={-5,5}, b={-5,5}, x0={-5,5}},
  x=  {-- inputs
       x1={-5,5}},
  y=  {-- outputs from our guesses (the "got")
       y1=function(x,w) return exp(x.x1, w.x0, w.a, w.b) end},
  z=  {-- ground truth (the "want") 
       y1=function(x)   return exp(x.x1, 1,    10, -3) end}
  }

local function from(t) return t[1] + r()*(t[2] - t[1]) end

local function froms(t,u,    v)
  v={}; for k,x in pairs(t) do v[k]=from({x,u[k]}) end; return v end

local function mre(want,got,x) print(want,got); return math.abs(100*(want-got)/(1E-32+want)) end

local function init(it,m,n,  t)
  local  function go(   w,err,x,got,want)
    w=    map(it.w, function(_,z) return from(z) end)
    err= map(it.z, function(_,_) return 0 end)
    for j=1,n do
      x=    map(it.x,  function(_,z) return from(z) end)
      got=  map(it.y,  function(_,f) return f(x,w)  end)
      want= map(it.z,  function(_,f) return f(x)  end)
      for k,x in pairs(want) do err[k] = err[k] + mre(x, got[k])/n end end 
    return {err.y1, w}  
  end -----
  t={}; for i=1,m do t[1+#t] = go() end; return sort(t,firsts) end

math.randomseed(my.seed)
local b =init(task,10000,10)
print(b[1][1],out(b[1][2]))
for k,v in pairs(_ENV) do if not my._b4[k] then print("? ",k,type(v)) end end
