#  a2ps --line-numbers=5 --pro=color --columns 2 -f 5 -R --pretty-print=l0a.ssh -M letter -o $f.ps $f.lua
f=l5

small:
	figlet  -W  -f threepoint  "$$(read)"

doc: pdf
	docco l5.lua
	cp ../../etc/docco.css docs

pdf:
	a2ps -jBR --line-numbers=1   -u tesst                            \
           --left-footer="" --right-footer="" --footer=""  \
           --borders=no --pro=color --columns 2 -L 150      \
           --pretty-print=lua.ssh -M letter -o $f.ps $f.lua
	ps2pdf $f.ps $f.pdf
	rm $f.ps
	open $f.pdf

s=auto93
h=4
ex0:
	lua l5.lua -f "../../data/$s.csv" -H $h -S $$RANDOM -W -T hints
	
s=auto93
d=/tmp/l5
#rnows 100s=4,1000=5,10000=6
ex1:
	mkdir -p $d
	for((i=1;i<=20;i++)) do lua l5.lua -f "../../data/$s.csv" -H $h -S $$RANDOM -W -T hints > $d/$$i.out ; done;
	paste $d/*.out > $d/all.dat
	for x in $d/*.out; do gawk '{n+=NR; m+=$$1} END {print m/n}' $$x; done | sort -n

ex2:
	$(MAKE) s=coc1000 ex1
