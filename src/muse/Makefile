f=muse
pdf: ok 
	a2ps  -Bjr --line-numbers=1                       \
            --borders=no --pro=color --columns 2 \
            --right-footer="" --left-footer="" \
            --footer="page %p." \
            --pretty-print=lua.ssh -M letter -o $f.ps $f 
	ps2pdf $f.ps ../../docs/$f.pdf
	rm $f.ps
	git add ../../docs/$f.pdf

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
	docco keys4.lua
	cp ../../etc/docco.css docs/
