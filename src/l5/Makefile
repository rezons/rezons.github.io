#  a2ps --line-numbers=5 --pro=color --columns 2 -f 5 -R --pretty-print=l0a.ssh -M letter -o $f.ps $f.lua
f=l5

small:
	figlet  -W  -f small  "$$(read)"

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
