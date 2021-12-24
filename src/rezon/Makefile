f=rezon

show: 
	a2ps  -jr --line-numbers=1                       \
           --borders=no --pro=color --columns 2 -L 90      \
           --right-footer="" --left-footer="" \
            --footer="" \
           --pretty-print=lua.ssh -M letter -o $f.ps $f.lua 
	ps2pdf $f.ps $f.pdf
	rm $f.ps
	open $f.pdf

bye:
	git add *;git commit -am save;git push;git status
