LUA = lua
GET = curl -sSLO
GUNZIP = gunzip -f

check:
	$(LUA) test.lua

update: terminfo.src.gz
	$(GUNZIP) $<

terminfo.src.gz: FORCE
	$(GET) https://invisible-island.net/datafiles/current/terminfo.src.gz


.PHONY: check update FORCE
