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

f=l5

small:
	figlet  -W  -f threepoint  "$$(read)"

doc: pdf ## make pdf and html
	docco l5.lua
	cp ../../etc/docco.css docs
           
#--left-footer="" --right-footer="$$s" --footer=""  \

pdf: 
	a2ps -jBR --line-numbers=1   -u tesst                    \
           --borders=no --pro=color --columns 2 -L 150      \
            --right-footer="$$q:$$l^-$$l."  \
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

ex1:
	mkdir -p $d
	for((i=1;i<=20;i++)) do lua l5.lua -f "../../data/$s.csv" -H $h -S $$RANDOM -W -T hints > $d/$$i.out ; done;
	paste $d/*.out > $d/all.dat
	for x in $d/*.out; do gawk '{n+=NR; m+=$$1} END {print m/n}' $$x; done | sort -n

ex2:
	$(MAKE) s=coc1000 ex1
