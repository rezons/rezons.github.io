local my        = require"my"
local cli       = my.get"cli cli"
local round     = my.get"maths round"
local obj,has   = my.get"metas obj has"
local push,abs  = my.get"funs push abs"
local srand,rand= my.get"rands srand rand"
local out,shout = my.get"prints out shout"
local top,any,firsts,sort,map  = my.get"tables top any firsts sort map"

function poly3(x,x0,a,b,c) return x0 + a*x^1 + b*x^2 + c*x^3  end

task ={n= 60,
       e= 0.05,
       want= function(x) return poly3(x,1,-10,6,4) end,
       x= {-10,10},
       w= {{.0001, {a=-10,b=-10,c=-10,x0=-10}},
           {.0001, {a= 10,b= 10,c= 10,x0= 10}}},
       y= function(x,w) return poly3(x,w.x0, w.a, w.b, w.c) end}

function from(t) return t[1]+rand()*(t[2] - t[1]) end

function froms(t,u,    v)
  v={}; for k,x in pairs(t) do v[k]=from({x,u[k]}) end; return v end


function evals(it,ws,n,best)
  local w,x,got,mre,out,want
  out = {}
  for i=1,n do 
    w =  #ws==2 and froms(ws[1], ws[2]) or froms(any(ws), any(ws))
    x   = from(task.x)
    got = task.y(x,w)
    want= task.want(x)
    mre = abs((got - want)/want)
    if mre<best then
      best = mre
      push(out, {mre, w}) end end
  return top(n//3, sort(out,firsts)) end

my = cli(my.how, arg)
srand(my.seed)
ws=task.w
best=math.huge
for i=1,10 do
  ws = evals(task,ws,20,best)
  print(ws[1][1])
  ws = map(ws,function(_,x) return x[2] end) end
