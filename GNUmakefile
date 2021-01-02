HASH := \#
LUA = lua
CURL = curl
GUNZIP = gunzip
GET = $(CURL) -sSL -o '$@'

check:
	$(LUA) test.lua

update: terminfo.src

terminfo.src: .tmp/terminfo.src .tmp/foot.src
	cat $< > $@
	printf '\n\n$(HASH) !!! Additional entries appended below\n\n\n' >> $@
	cat $(filter-out $<, $+) >> $@

.tmp/terminfo.src: .tmp/terminfo.src.gz
	$(GUNZIP) -c $< > $@

.tmp/terminfo.src.gz: FORCE | .tmp/
	$(GET) https://invisible-island.net/datafiles/current/terminfo.src.gz

.tmp/foot.src: FORCE | .tmp/
	$(GET) https://codeberg.org/dnkl/foot/raw/branch/master/foot.info

.tmp/:
	mkdir -p $@


.PHONY: check update FORCE
