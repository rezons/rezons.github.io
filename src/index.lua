-- vim: filetype=markdown: 


--[[
&copy; 2022 Tim Menzies, Jamie Jennings

## Inexact, yet Reasonable


Algorithms make choices. Choices have consequences.
Many choices are ethical but not choosing is unethical and irrational.
Algorithms, once written, have to be wrangled. Do you know how to reason with your algorithms?

For example:

<table>
<tr> 
<td>
<small>
<pre>
local my= {
  sames=   cli("A",   512), 
  bins=    cli("b",  .5),
  best=    cli("B",  .5),
  cohen=   cli("C",  .35),
  combine= cli("c",  "mode"),
  far=     cli("f",  .9),
  conf=    cli("F",  .05),
  k=       cli("k",  2),  
  cliffs=  cli("I",  .25,
  loud=    cli("l",  false),
  bootstraps=cli("O", 512),
  p=       cli("p",  2), 
  seed=    cli("S",  10011),
  some=    cli("s",  256),
  todo=    cli("t",  "hello"),
  wait=    cli("w",  10)
 }
</pre>
</small>
</td>
<td>
<img src="https://user-images.githubusercontent.com/29195/130842711-01c78419-c8d4-4b96-8064-2fba3c33d6c4.png">
</td>
</tr>
</table>

But before answering that, perhaps we should ask "why is it important to ask that question?"
It has often been said, this is the age of the algorithm. Algorithms control nearly all aspects of our life from the power distribution to the cars,
to how we find new friends on the internet, right down to the beating of our hearts (as controlled by pacemakers). We once asked ours students "can you think of
anything not controlled by algorithms?" and someone said "my shoes!". In reply we asked "did you buy those shoes via some search engine?
Did you pay for those shows on-line? Did the shoes come from overseas and were deliered to you via  vast software-controlled develiery system?".

You get the point: algorithms rule. But who rules the alorithms? Much  has [been said](https://www.thesocialdilemma.com/)
 the effect of algorithm AI on, say, social media. 
And a common comment is that these algorithms
are beyond our control,
that they have  emigrant properties that no programmer ever realized could occur.
For example, consider the following little experiment. Some data miner is preciting XXX and y as ix SSS. an farness vs accuract

So instead of being exact and precise things with simple correct outputs, there are other kinds of inexact
algorithms
with many internal design choices. And those choices have consequences (here, they critically effective the fairness of
the output).
to say is that these inexact  algorithms have many choices and those choices have consequences.
For example, unless we are careful, we can accidentals choose to generate models that

- consume too much energy
- run too slowly
-  discriminate against some member of society
- or do not achieve any number of domains specific goals.

Our premise is that we need tore ason more abut the internal choces inside our algorthms. We should stop
always believing thatye theya re exact tools with single correct answers (since if you beleive that, you get consifed ad even wfearful when
the algorithms go wild and do what we did not expect).
Some algorithm are exact, deterministic, and are guaranteed to generate correct outout.
But some are not. ANd those that arenot are uusally better as scaling to very data sets. So we need to be able to reason
 about that **other kind of algorithm**.

What we will say is, to reason about this other other kind of inexact aglorithm, we need to reason about the
_data_ it is processing and the _goals_ of the people using it.
So when we reason about those kinds of algorithms, we need to reason not just about the program,
but also:

- the data they analyze (which may chage from day to day). 
- and the particular goals we want to achieve (which may change from user to user).

It turns out that this data-centric and goal-centric approach is astonoshingly useful. semu supervised
learning  manifolds data reduction.

Hence we offer a data-centric and human-centric of inexact algorithms. Our approach includes data mining and optimization and geometry.
ALso, we will talk  about human psychology., inparticualr heuristics, satisficing, and knowledge acqusition.

- _Heuristics_: Firstly, humans use heuristics to explore complex spaces  Herusitcs are:
  - short-cuts that simplify a task 
  - ways to scale some method to large problem (but sometimes might actually introduce errors).
  - and when ,  applied to algoriths, heursi makes them inexact 

- _Satisficing:_ (which is actually a special kind of heuristic) is a  combination of satisfy and suffice.
 Satisficing algorithms search
through the available alternatives until an acceptability threshold is met. For example, it is hard to
choose between two options if their average performance is very similar and each has some "wriggle" in their putputs 
  - For example, depending on wind conditions,
two sailboats with mean speeds of 20 and 22 knots, where that speed might "wriggle"   &plusmn;  5 knots.
  - A satisficing algorirhm might choose either boat at random since the two performances are so similar, we cannot tell them apart.
- _Biased_: 
  When  humans look at data, they often have _reaons_ for being biased towards some parts of thed ata to others. Such biases 
  can be good or bad:
  - Suppose our biases let us quickly discard the worst half of any set of solutions. If so, then 20 yes-or-no questions (2<sup>20</sup>)
    could let find a usefil option within a million possibiltiies.
  - But those biases can blind us to various aspects of the problem or (accidently or deliberately) make choices that harm people.
    In this case, we need tools that "shake up the bias" and let us (sometimes) explore the options discreacred by our biases.
  - Since bias can have negative connotations, we weill call these biases 
_reasons_
     given some model _Y=F(X)_
    these _reasons_ (to prefer soemthigns ver another) might be preferemce crtaie across the _X_ space or the _Y_ space.
- _Knowledge elicitiation by irritation_:
 These reasons many not become apparent until after humans see some output. Humans often never realize
that they do not like something until they can see specific examples.  This means we must assume that the reaosons may be ijitially empty and
grow over time.




## About our technology

This tutorial is is two parts: theory and practice. The theory is langauge and platform indepdnent
while the practical exercises are written in the Lua scripting language.
We use  Lua since:

- It installs, very, quickly on most platforms.
- It is fast to learn (see ["Learn Lua in Y minutes"](https://learnxinyminutes.com/docs/lua/);
- It uses constructs familiar to a lot of programmers (LUA is like Python, but without the overhead or the needless elaborations)
- Lua code has far fewer dependencies that code written in other languages. Having taught (a lot) programming for many eyars, we know that many peopl
have (e.g.) local Python environments that differ from platform to platform.   These platforms can be idiosyncratic. For
example, we know what many data scientists like Anaconda which is a decision that many other programmers prefer to avoid.
- Lua  has some interesting teaching advantages:
  - The code for one class can be spread across multiple files.
    So teaching can work week to week, presenting new ideas on a class,
    in different weeks.
  - Lua serves very  nicely as an executable specification language.
    we've had some past success giving  people the  Lua code then saying
    "code this up in any language you like, except Lua". We find that students
    can readily read and reproduce the code (in another  language). 
    And during that development work, the students  can run our Lua code to 
    see  what output is expected.
 
## Not Complexity, Complicity

simple Emergent  patterns  in  Apparently complex systems. While some human
problems are inherently complex, others are not. And it is prudent to try simple
before complex.

## Data 


Here, we say that we are reasoning froma  _sample_ of data,
_rows_ and _columns_.
Columns are also known as features, attributes, or variables.

Rows contain multiple _X, Y_ features where _X_ are the
independent variables (that can be observed, and sometimes
controlled) while _Y_ are the dependent variables (e.g. number
of defects). When _Y_ is absent, then _unsupervised learners_
seek mappings between the _X_ values. For example, clustering algorithms find groupings of similar rows (i.e. rows with
similar X values).

Usually most rows have values for most _X_ values. But
with text mining, the opposite is true. In principle, text
miners have one column for each work in text’s language.
Since not all documents use all words, these means that the
rows of a text mining data set are often “sparse”; i.e. has
mostly missing values.

- When _Y_ is present and there is only one of them (i.e.
_|Y| = 1_) then supervised learners seek mappings from the X
features to the _Y_ values. For example, logistic regression tries
to fit the _X, Y_ mapping to a particular equation.
- When there are many _Y_ values (i.e. _|Y| > 1_), then
another array _W_ stores a set of weights indicating what
we want to minimize or maximize (e.g. we would seek
to minimize _Y.i_ when _W.i &lt; 0s_). In this case, multi-objective
optimizers seek X values that most minimize or maximize
their associated Y values. 

So:
-  Clustering algorithms find groups of rows;
-  and Classifiers (and regression algorithms) find how those
groups relate to the target Y variables;
-  and Optimizers are tools that suggest “better” settings
for the X values (and, here, “better” means settings that
improve the expected value of the Y values).

Apart from _W, X, Y_ , we add _Z_, the hyperparameter settings
that control how learners performs regression or clustering.
For example, a K-th nearest neighbors algorithm needs to know how
many nearby rows to use for its classification (in which case,
that _k ∈ Z_). Usually the _Z_ values are shared across all rows
(exception: some optimizers first cluster the data and use
different _Z_ settings for different clusters)


Y = F(X)

Often easuer to find X than Y.

Samples arnot all data so we are always must guess how well some model _F_ learned from old data appies to new data.


--]]
