local inquire, the = require"_about"
local map          = inquire"tables map"
local round        = inquire"maths round"
local Seed,rand    = inquire"rands Seed rand"
local out,shout    = inquire"prints out shout"

function poly3(x,x0,a,b,c) return x0 + a*x^1 + b*x^2 + c*x^3  end

task ={n= 1,
       e= 0.05,
       truth ={y1=function(x) return poly3(x.x1,1,-10,6,4) end },
       x= {x1={-10,10}},
       w= {a={-10,10},b={-10,10}, c={-10,10}, x0={-10,10}},
       y= {y1=function(x,w) return poly3(x.x1,w.x0, w.a, w.b, w.c) end}}

function evaluate(task, x,w,y,   d,p,any,eval)
  d = d or 3
  function p(x)      return round(x,d) end
  function any(_,x)  return p(rand(x[1],x[2])) end
  function eval(_,f) return p(f(x,w)) end
  for i=1,task.n do 
    x = map(task.x,any)
    w = map(task.w,any)
    y = map(task.y, eval)
    shout{x=x,y=y,w=w} end end
    
Seed=10019  
print(rand())
evaluate(task)

