LUA = lua
GIT = git
NCURSES-REPO = https://github.com/ThomasDickey/ncurses-snapshots.git

EXAMPLE_OUTPUTS = $(addprefix examples/output/, $(addsuffix .txt, \
    backspace-key-sends-bs \
    backspace-key-sends-del \
    backspace-key-values \
    cap-names \
    delete-key-sends-del \
    has-auto-margins \
    has-repeat-char \
    longest-key-sequence \
    longest-sequence \
    needs-xon-or-padding \
))

update: update-terminfo example-outputs
example-outputs: $(EXAMPLE_OUTPUTS)

check:
	$(LUA) test.lua

$(EXAMPLE_OUTPUTS): examples/output/%.txt: examples/%.lua terminfo.src
	$(LUA) '$<' > '$@'

update-terminfo: | .tmp/ncurses-snapshots/
	$(GIT) -C $| pull origin master:master
	cp -p $|misc/terminfo.src terminfo.src

.tmp/ncurses-snapshots/: | .tmp/
	test -d $@ || $(GIT) clone $(NCURSES-REPO) $@

.tmp/:
	mkdir -p $@


.PHONY: update update-terminfo example-outputs check
