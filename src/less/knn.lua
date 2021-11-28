local the       = require"the"
local out,shout = the.get"prints out shout"
local push      = the.get"tables push"
local csv       = the.get"files csv"
local rnd       = the.get"maths round"
local Summary   = require"Summary"

function knn1(file,    summary,a,b,t)
  rows={}
  for row in csv(file) do
    if   not summary 
    then summary = Summary(row)
    else push(rows, summary:add(row)) end end 
  t = summary:neighbors(rows[1],rows)
  a,b = t[2][2],  t[100][2] 
  print("====")
  print(summary:dist(a,b))
  shout(a)
  shout(b)
end

knn1("../../data/auto93.csv")
