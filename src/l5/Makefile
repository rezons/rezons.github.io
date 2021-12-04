#  a2ps --line-numbers=5 --pro=color --columns 2 -f 5 -R --pretty-print=l0a.ssh -M letter -o $f.ps $f.lua
f=l5
pdf:
	a2ps --line-numbers=5 --pro=color --columns 2 -f 5 -BR --pretty-print=lua.ssh -M letter -o $f.ps $f.lua
	ps2pdf $f.ps $f.pdf
	rm $f.ps
