LUA = lua
CURL = curl
GUNZIP = gunzip
GET = $(CURL) -sSL -o '$@'

check:
	$(LUA) test.lua

update: terminfo.src

terminfo.src: .tmp/terminfo.src
	cat $< > $@

.tmp/terminfo.src: .tmp/terminfo.src.gz
	$(GUNZIP) -c $< > $@

.tmp/terminfo.src.gz: FORCE | .tmp/
	$(GET) https://invisible-island.net/datafiles/current/terminfo.src.gz

.tmp/:
	mkdir -p $@


.PHONY: check update FORCE
