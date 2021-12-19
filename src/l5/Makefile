FROM=https://raw.githubusercontent.com/rezons/rezons.github.io/main
#------------------------------------------------------------------------------
ready: dirs files help  ## create files
GET=echo $@; wget -q -O $@ $(FROM)/$@
help: ## show this help
	@echo "usage: make [OPTIONS]\n\nOPTIONS:"
	@gawk -F: '/## / && !/@/ {x=$$1; sub(/.*##/,"\t",$$0); print "\t"x,$$0}' $(MAKEFILE_LIST)

bye:;   git add *;git commit -am save;git push;git status ## save files
hi:;    git pull ## get files

#------------------------------------------------------------------------------
dirs:;  @mkdir -p etc
files:  etc/vimrc etc/tmux-conf

etc/vimrc:;     @$(GET)
etc/tmux-conf:; @$(GET)
#------------------------------------------------------------------------------

ween1:
	lua ween.lua -todo ordered|column  -t

ween2:
	lua ween.lua -todo dist|column  -t

f=l5

small:
	figlet -Wk -f Cybermedium "r a n d o m" | gawk '{print "-- " $0}'|pbcopy

names:
	@egrep '^(lib|function)' z.lua \
	| sed 's/^.*lib.//' \
	| sed 's/[ \(].*//' \
	| sort | uniq | fmt -24 \
	| gawk '{gsub(/ /,","); b=$$0;gsub(/,/,", _.",b); print "local " $$0 " = _."b }'

doc: pdf ## make pdf and html
	docco l5.lua
	cp ../../etc/docco.css docs
           
#--left-footer="" --right-footer="$$s" --footer=""  \

f=l5
show:: 
	a2ps -jR --line-numbers=1                       \
           --borders=no --pro=color --columns 2 -L 150      \
           --right-footer="" --left-footer="" \
            --footer="" \
           --pretty-print=lua.ssh -M letter -o $f.ps $f.lua 
	ps2pdf $f.ps $f.pdf
	rm $f.ps
	open $f.pdf

t=tiny
tiny: 
	echo 111
	a2ps -jR -A fill --line-numbers=1                       \
           --borders=no --pro=color --columns 2 -L 150      \
           --right-footer="" --left-footer="" \
            --footer="" \
           --pretty-print=lua.ssh -M letter -o $t.ps $t.lua $(t)lib.lua $(t)0.lua
	ps2pdf $t.ps $t.pdf
	rm $t.ps
	open $t.pdf

f=l5
pdf: 
	a2ps -jR --line-numbers=1                       \
           --borders=no --pro=color --columns 2 -L 150      \
           --right-footer="" --left-footer="" \
            --footer="" \
           --pretty-print=lua.ssh -M letter -o $f.ps $f.lua lib.lua z.lua 
	ps2pdf $f.ps $f.pdf
	rm $f.ps
	open $f.pdf

s=auto93
h=4
ex0:
	lua l5.lua -f "../../data/$s.csv" -H $h -S $$RANDOM -W -T hints
	
s=auto93
d=/tmp/l5

ex1:
	mkdir -p $d
	for((i=1;i<=20;i++)) do lua l5.lua -f "../../data/$s.csv" -H $h -S $$RANDOM -W -T hints > $d/$$i.out ; done;
	paste $d/*.out > $d/all.dat
	for x in $d/*.out; do gawk '{n+=NR; m+=$$1} END {print m/n}' $$x; done | sort -n

ex2:
	$(MAKE) s=coc1000 ex1
