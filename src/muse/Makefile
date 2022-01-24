duo:; $(MAKE) f=duo.lua pdf

f=muse
pdf: ok 
	a2ps  -BjR --line-numbers=1                       \
            --borders=no --pro=color --columns 2 \
            --right-footer="" --left-footer="" \
            --footer="page %p." \
            --pretty-print=lua.ssh -M letter -o $f.ps $f 
	ps2pdf $f.ps ../../docs/$f.pdf
	rm $f.ps
	git add ../../docs/$f.pdf

html:
	gawk -f lua2md.awk $f > $f.md
	pandoc -s --toc --toc-depth=6 -V fontsize=9pt  -c lua.css --metadata title="$f" $f.md -o $f.html

pandoc:
	gawk -f lua2md.awk $f > $f.md
	pandoc $f.md -V geometry:margin=1in  -V fontsize=9pt -V documentclass:scrbook -V fontfamily:times  --highlight=tango  -s --toc --toc-depth=6 --metadata title="$f" -o $f.pdf

header:
	@read x; echo $$x | figlet -W -f straight | gawk '{print "--    "$$0}'

ok:
	mkdir -p ../../docs

bye:
	git add *;git commit -am save;git push;git status

osxbrew:
	@which brew>/dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

osx: osxbrew
	brew install lua gawk npm
	npm install -g docco

doc: 
	docco keys.lua
	cp ../../etc/docco.css docs/
