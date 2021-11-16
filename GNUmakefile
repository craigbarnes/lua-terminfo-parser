LUA = lua
GIT = git
NCURSES-REPO = https://github.com/ThomasDickey/ncurses-snapshots.git

check:
	$(LUA) test.lua

update: terminfo.src

terminfo.src: FORCE | .tmp/ncurses-snapshots/
	$(GIT) -C $| pull origin master:master
	cp $|misc/terminfo.src $@

.tmp/ncurses-snapshots/: | .tmp/
	test -d $@ || $(GIT) clone $(NCURSES-REPO) $@

.tmp/:
	mkdir -p $@


.PHONY: check update FORCE
