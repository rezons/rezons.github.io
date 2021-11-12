assuming

Y=F(X)

try to learn F given:

- lots of samples  of X 
  - e.g. data from the real world
  - random test case generation
  - some grammar-based fuzzing
- We don't way all Y, just a few best Y
- an oracle that can offer you (a few) few samples of y (e.g. ask a person, build one car
  and test it, run some drug trial, fund Christopher columns to sail west to to and find india)
  - wish to minimize calls to the oracle 

assume we have S= samples 
- where each sample is
  (X1,X2,X3..Y1,Y2,Y3) and the Yi values may currently nil
- Replacing the nil Yi values with an actual value means evaluating Y=F(X)
- one sample is better than another if it dominates the other
  - domination= pareto frontier multi-objective stuff




## random

start:
- set SOME=4 -- say
- set STOP = sqrt(#S) -- say
- MID= #S//2
- TRAIN, TEST=  S[ :MID ], S[ MID+1: ]
- TRAIN = shuffle(TRAIN)  
- goto prune

prune:
- if #TRAIN &lt; STOP then goto check 
- SAMPLED = sort(map(f, TRAIN[ 1:SOME ])) 
  - sorted using domination
- TRAIN = [ TRAIN[ SOME + 1: ]
  - i.e. everything not yet evaluated
- TMP = {}
- for ONE in TRAIN do
  - find nearest neighbor in SAMPLED
    - euclidean distance on X values
    - if nearest in first half of SAMPLED
      - TMP += [ONE]
- TRAIN = TMP
- goto prune
      
check:
- TEST= sort(map(f, TEST))
  - not something you can do in practice, but here we are doing a what-if query
  - specifically: if we knew all the test y values, where does our test set fall
- for pos,one in enumerate(TRAIN) do
     




