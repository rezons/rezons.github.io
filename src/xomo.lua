-- vim: ft=lua ts=2 sw=2 et:

obj=require"obj"
isa,klass = obj.isa, obj.klass

local Cocomo=klass"Comoco"

function Cocomo.defaults()
  local _,ne,nw,nw4,sw,sw4,ne46,w26,sw46
  local p,n,s="+","-","*"
  _ = 0
  ne={{_,_,_,1,2,_}, -- bad if lohi
    {_,_,_,_,1,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_}}
  nw={{2,1,_,_,_,_}, -- bad if lolo
    {1,_,_,_,_,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_}}
  nw4={{4,2,1,_,_,_}, -- very bad if  lolo
    {2,1,_,_,_,_},
    {1,_,_,_,_,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_}}
  sw={{_,_,_,_,_,_}, -- bad if  hilo
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {1,_,_,_,_,_},
    {2,1,_,_,_,_},
    {_,_,_,_,_,_}}
  sw4={{_,_,_,_,_,_}, -- very bad if  hilo
    {_,_,_,_,_,_},
    {1,_,_,_,_,_},
    {2,1,_,_,_,_},
    {4,2,1,_,_,_},
    {_,_,_,_,_,_}}
  -- bounded by 1..6
  ne46={{_,_,_,1,2,4}, -- very bad if lohi
    {_,_,_,_,1,2},
    {_,_,_,_,_,1},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_}}
  sw26={{_,_,_,_,_,_}, -- bad if hilo
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {1,_,_,_,_,_},
    {2,1,_,_,_,_}}
  sw46={{_,_,_,_,_,_}, -- very bad if hilo
    {_,_,_,_,_,_},
    {_,_,_,_,_,_},
    {1,_,_,_,_,_},
    {2,1,_,_,_,_},
    {4,2,1,_,_,_}}
  return {
    loc = {"1",2,200},
    acap= {n,1,5}, cplx={p,1,6}, prec={s,1,6},
  	aexp= {n,1,5}, data={p,2,5}, flex={s,1,6},
  	ltex= {n,1,5}, docu={p,1,5}, arch={s,1,6},
  	pcap= {n,1,5}, pvol={p,2,5}, team={s,1,6},
  	pcon= {n,1,5}, rely={p,1,5}, pmat={s,1,6},
  	plex= {n,1,5}, ruse={p,2,6},
  	sced= {n,1,5}, stor={p,3,6},
  	site= {n,1,5}, time={p,3,6},
    tool= {n,1,5}
    }, {
    cplx= {acap=sw46, pcap=sw46, tool=sw46}, --12
    ltex= {pcap=nw4},  -- 4
    pmat= {acap=nw,   pcap=sw46}, -- 6
    pvol= {plex=sw},  --2
    rely= {acap=sw4,  pcap=sw4,  pmat=sw4}, -- 12
    ruse= {aexp=sw46, ltex=sw46},  --8
    sced= {cplx=ne46, time=ne46, pcap=nw4, aexp=nw4, acap=nw4,
           plex=nw4,  ltex=nw, pmat=nw, rely=ne, pvol=ne, tool=nw}, -- 34
    stor= {acap=sw46, pcap=sw46}, --8
    team= {aexp=nw,   sced=nw,  site=nw}, --6
    time= {acap=sw46, pcap=sw46, tool=sw26}, --10
    tool= {acap=nw,   pcap=nw,  pmat=nw}} end -- 6

--- Effort and rist estimation
-- For moldes defined in `risk.lua` and `coc.lua`.

--- Define the internal `cocomo` data structure:
-- `x` slots (for business-level decisions) and
-- `y` slots (for things derived from those decisions, 
-- like `self.effort` and `self.risk')
function Cocomo.new(project) 
  return isa(Cocomo,{x={},y={}}):ready(project) end

function Cocomo:effort()
  local em,sf=1,0
  for k,t in pairs(self.coc) do
    if     t[1] == "+" then em = em * self.y[k] 
    elseif t[1] == "-" then em = em * self.y[k] 
    elseif t[1] == "*" then sf = sf + self.y[k] end end 
  return self.y.a*self.x.loc^(self.y.b + 0.01*sf) * em end
  
function Cocomo:risk()
  local n=0
  for a1,t in pairs(self.risk) do
    for a2,m in pairs(t) do
      n  = n  + m[self.x[a1]][self.x[a2]] end end
  return n/108 end

local function from(lo,hi) return lo+(hi-lo)*math.random() end

local function y(meta,x)
    if     meta=="1" then return x 
    elseif meta=="+" then return (x-3)*from( 0.073,  0.21 ) + 1 
    elseif meta=="-" then return (x-3)*from(-0.178, -0.078) + 1 
    else                  return (x-6)*from(-1.56,  -1.014) end end

-- Ensures that `y` is up to date with the `x` variables.
function Cocomo:ready(project)
  for k,span in pairs(Cocomo.defaults()[1]) do 
    local lo,hi,lo1,hi1
    lo,hi = span[2],span[3]
    if project[k] then
      lo1,hi1 = project[k]
      if   lo<=lo1 and lo1<=hi and lo <=hi1 and hi1<hi 
      then lo,hi=lo1,hi 
      else print("#E>",lo1,hi1,"not in range",lo,hi) end end 
    self.x[k] = from(lo,hi)
    self.y[k] = y(t[1], self.x[k])
  end 
  local gradient= (.85 - 1.1)/(9.18 - 2.2)
  local xintercept= (.85 - gradient*9.18)
  self.y.a = from(2.2, 9.18)
  self.y.b = gradient*self.y.a+ xintercept
  return self end
