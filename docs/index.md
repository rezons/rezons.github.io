# Inexact and Reosomable

&copy; 2022 Tim Menzies, Jamie Jennings

The tutroial is about algorthms, but perhaps not the kind of algorithms seen in most computer science textbooks.


Some algorithm are exact, deterministic, and are guaranteed to generate correct outout.

But some are not. ANd those that aren't can sometiems cale to very data sets. So we need to talk about those kinds of algorothms..

Waht we want to say is that these inexact  algorithms have many choices and those choices have consqueneces.
For example, unless we are careful, we can accidendelt chooise to generate models that

- consume too much energy
- run too slowly
-  discriminate against some member of society dnt hsoe chocies have consewuences. .
- or do not achive any number of domains specific goals.

So when we reason about those kinds of algorithms, we need to reason not just about the program,
but also:

- the data they analyze (which may chage from day to day). 
- and the particular goals we want to achieve (which may change from user to user).

Hence we offer a data-centric view of inexact algorithms. Our approach includes data mining and optimization and geometry.
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
- Biased_: 
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




## Why LUA?

This tutorial is is two parts: theory and practice. The theory is langauge and platform indepdnent
while the practical exercises are written in the LUA scripting language.
We use  LUA since:

- It installs, very, quickly on most platforms.
- It is fast to learn (see ["Learn LUA in Y minutes"](https://learnxinyminutes.com/docs/lua/);
- It uses constructs familiar to a lot of programmers (LUA is like Python, but without the overhead or the needless elaborations)
- LUA code has far fewer dependencies that code written in other languages. Having taught (a lot) programming for many eyars, we know that many peopl
have (e.g.) local Python environments that differ from platform to platform.   These platforms can be idiosyncratic. For
example, we know what many data scientists like Anaconda which is a decision that many other programmers prefer to avoid.


#e DatA 


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

