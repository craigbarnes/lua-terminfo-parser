local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
assert(#terms > 1700)

do
    local term = assert(terms["v3220"])
    assert(term.am == true)
    assert(term.xenl == true)
    assert(term.cols == 80)
    assert(term.lines == 24)
    assert(term.is2 == "\27>\27[?3l\27[?7h\27[?8h\27[p")
    assert(term.cub1 == "\b")
    assert(term.ht == "\t")
end

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

do
    local term = assert(terms["ansi.sys"])
    assert(term.ka1 == "\128G")
    assert(term.kcbt == "\128\15")
    assert(term.kf6 == "\128@")
    assert(term.kf11 == "\128\133")
    assert(term.kf21 == "\128\\")
    assert(term.kf24 == "\128\136")
    assert(term.kf25 == "\128^")
end

io.stderr:write("OK\n")
