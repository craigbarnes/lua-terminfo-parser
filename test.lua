local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))

do
    local term = assert(terms["xterm+256color"])
    assert(term.colors == 256)
end

do
    local term = assert(terms["xterm+direct2"])
    assert(term.TERM == "xterm+direct2|xterm with direct-color indexing")
    assert(term.colors == 2^24)
    assert(term.RGB == true)
    assert(term.initc == false)
    local expected_setaf =
        "\27[%?%p1%{8}%<%t3%p1%d%e38:2:%p1%{65536}%/" ..
        "%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%d%;m"
    assert(term.setaf == expected_setaf)
end

do
    local term = assert(terms["xterm-direct2"])
    assert(term.use)
    assert(term.use.length == 3)
    assert(term.use[1] == "xterm+direct2")
    assert(term.use[2] == "xterm+titlestack")
    assert(term.use[3] == "xterm")
end
