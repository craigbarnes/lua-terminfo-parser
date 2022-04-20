local terminfo = assert(loadfile("./terminfo-parser.lua", "t"))()
local parse_file = assert(terminfo.parse_file)
local assert, type, stderr = assert, type, io.stderr
local pairs, rawget = pairs, rawget
local _ENV = nil

local terms = assert(parse_file("terminfo.src"))
assert(#terms > 1700)
assert(type(terms.iter) == "function")
assert(terms:iter()() == "dumb")

do
    local term = assert(terms.v3220)
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
    assert(term._DESC == "xterm+direct2|xterm with direct-color indexing (old building-block)")
    assert(#term._TERM == 1)
    assert(term._TERM[1] == "xterm+direct2")
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
    local use = assert(term._use)
    assert(use.length == 3)
    assert(use[1] == "xterm+direct2")
    assert(use[2] == "xterm+titlestack")
    assert(use[3] == "xterm")
    -- Chained from "xterm+kbs"
    assert(term.kbs == "\b")
    -- Chained from "xterm+pc+edit"
    assert(term.kend == "\27[4~")
    assert(term.khome == "\27[1~")
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

do -- Check that chained lookup of "use=" references works
    local tw52 = assert(terms.tw52)
    -- Lookup chain: tw52 -> tw52-m -> at-m
    assert(tw52.kRIT == "\27c")
    assert(tw52.non_existent_cap_name == nil)
end

do -- Check that Entry:__index("use") behaves as expected
    local djgpp203 = assert(terms.djgpp203)
    assert(djgpp203.use == nil)
    assert(djgpp203.lines == 25)
    assert(djgpp203.non_existent_cap_name == nil)
    local tw52 = assert(terms.tw52)
    assert(type(tw52._use) == "table")
    assert(tw52._use == rawget(tw52, "_use"))
end

do -- Check that entry headers with no description are parsed correctly
    local addrinfo = assert(terms.addrinfo)
    assert(addrinfo._TERM[1] == "addrinfo")
    assert(addrinfo.cup == "\31%p1%c%p2%c")
    assert(addrinfo.home == "\8")
    local infoton = assert(terms.infoton)
    assert(infoton._TERM[1] == "infoton")
    assert(infoton.cud1 == "\n")
    assert(infoton.ed == "\11")
end

do
    local tw52 = assert(terms.tw52)
    local seen = {}
    for k, v in tw52:iter() do
        assert(k ~= "use")
        assert(k ~= "DESC")
        assert(k ~= "TERM")
        assert(k ~= "_use")
        assert(k ~= "_DESC")
        assert(k ~= "_TERM")
        seen[k] = true
    end
    assert(seen.kRIT)
end

stderr:write("OK\n")
