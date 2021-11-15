local my        = require"my"
local map       = my.get"tables map"
local push      = my.get"funs push abs"
local srand,rand= my.get"rands srand rand"
local out,shout = my.get"prints out shout"
local Best      = require"best"
local poly3,task,from,froms2,init

function poly3(x,x0,a,b,c) return x0 + a*x^1 + b*x^2 + c*x^3  end

task ={n= 60,
       e= 0.05,
       want= function(x) return poly3(x,1,-10,6,4) end,
       x= {x1={-10,10}},
       w= {a ={-10,10},b={-10,10},c={-10,10},x0={-10,10}},
       y= {y1=function(x,w) return poly3(x.x1,w.x0, w.a, w.b, w.c) end}}

function from(t) return t[1]+rand()*(t[2] - t[1]) end

function froms(t,u,    v)
  v={}; for k,x in pairs(t) do v[k]=from({x,u[k]}) end; return v end

function init(it,n,  t)
  t={}
  for i=1,n do
    x= map(it.x, function(_,z) return from(z) end)
    w= map(it.w, function(_,z) return from(z) end)
    y= map(it.y, function(_,f) return f(x,w)  end)
    print(i, out(y))
    t[1+#t] =  {y.y1, w} end 
  return t end

srand(my.seed)
shout(init(task, 10))
