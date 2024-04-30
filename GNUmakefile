LUA = lua
FETCH = curl -sSL -o '$@'
NCURSES_SNAPSHOTS = https://raw.githubusercontent.com/ThomasDickey/ncurses-snapshots
TERMINFO_SRC_ORIG = $(NCURSES_SNAPSHOTS)/master/misc/terminfo.src

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
))

update: update-terminfo example-outputs
example-outputs: $(EXAMPLE_OUTPUTS)

check:
	$(LUA) test.lua

$(EXAMPLE_OUTPUTS): examples/output/%.txt: examples/%.lua terminfo.src
	$(LUA) '$<' > '$@'

update-terminfo:
	$(FETCH) '$(TERMINFO_SRC_ORIG)'


.PHONY: update update-terminfo example-outputs check
