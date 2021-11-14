local my        = require"my"
local cli       = my.get"cli cli"
local round     = my.get"maths round"
local push,abs = my.get"funs push abs"
local firsts,sort,map  = my.get"tables firsts sort map"
local srand,rand= my.get"rands srand rand"
local out,shout = my.get"prints out shout"

function poly3(x,x0,a,b,c) return x0 + a*x^1 + b*x^2 + c*x^3  end

task ={n= 60,
       e= 0.05,
       truth= {y1=function(x) return poly3(x.x1,1,-10,6,4) end },
       x= {x1={-10,10}},
       w= {a={-10,10},b={-10,10}, c={-10,10}, x0={-10,10}},
       y= {y1=function(x,w) return poly3(x.x1,w.x0, w.a, w.b, w.c) end}}

function evals(task,out)
  local x1,w,y,d,p,any,mre,eval,want,got
  d = d or 2
  function p(x)      return round(x,d) end
  function any(_,x)  return p(rand(x[1],x[2])) end
  function eval(_,f) return p(f(x,w)) end
  for i=1,task.n do 
    local now = {}
    now.x = map(task.x, any)
    now.c = map(task.c, any)
    now.y = map(task.y, function(_,f) return f(now.x,now.w) end) 
    want  = task.truth.y1(now.x)
    push(out, {abs((now.y.y1 - want)/want), w}) end 
  return out end

my = cli(my.how, arg)
srand(my.seed)
all=sort(evals(task,{}),firsts)
shout(all[1])
