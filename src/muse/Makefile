f=muse
show: ok 
	a2ps  -Bjr --line-numbers=1                       \
            --borders=no --pro=color --columns 2 -L 90      \
            --right-footer="" --left-footer="" \
            --footer="page %p." \
            --pretty-print=lua.ssh -M letter -o $f.ps $f 
	ps2pdf $f.ps ../../docs/$f.pdf
	rm $f.ps
	git add ../../docs/$f.pdf

ok:
	mkdir -p ../../docs

bye:
	git add *;git commit -am save;git push;git status
