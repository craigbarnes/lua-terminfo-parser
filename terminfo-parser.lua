-- Parser for terminfo(5) source format.
-- Copyright 2018 Craig Barnes.
-- SPDX-License-Identifier: GPL-2.0-only
-- See also: https://invisible-island.net/ncurses/#download_database

local lpeg = require "lpeg"
local char, tonumber, open, assert = string.char, tonumber, io.open, assert
local setmetatable = setmetatable
local P, R, S = lpeg.P, lpeg.R, lpeg.S
local C, Cc, Cs = lpeg.C, lpeg.Cc, lpeg.Cs
local Cf, Cg, Ct = lpeg.Cf, lpeg.Cg, lpeg.Ct
local _ENV = nil

local unescape_char = {
    [":"] = ":",
    [","] = ",",
    ["^"] = "^",
    ["0"] = "\128",
    ["\\"] = "\\",
    ["b"] = "\b",
    ["e"] = "\27",
    ["E"] = "\27",
    ["f"] = "\f",
    ["l"] = "\n", --<< TODO: ensure this is correct
    ["n"] = "\n",
    ["r"] = "\r",
    ["s"] = " ",
    ["t"] = "\t",
}

local function unescape_caret(caret)
    local byte = caret:byte() - 64
    assert(byte > 0)
    return char(byte)
end

local function unescape_octal(octstr)
    local byte = assert(tonumber(octstr, 8))
    assert(byte <= 255)
    if byte == 0 then
        -- terminfo(5) states: "\0 will produce \200, which does not terminate
        -- a string but behaves as a null character on most terminals".
        -- Decimal 128 == octal 200.
        byte = 128
    end
    return char(byte)
end

local ChainedLookup = {
    __index = function(t, k)
        assert(k ~= "TERM")
        assert(k ~= "use")
        local use = assert(t.use)
        for i = use.length, 1, -1 do
            local refname = assert(use[i])
            return use._backref[refname][k]
        end
    end
}

local function setfield(t, k, v)
    if k == "use" then
        local use = t.use
        if use then
            local length = use.length + 1
            use[length] = v
            use.length = length
        else
            t.use = {v, length = 1}
            setmetatable(t, ChainedLookup)
        end
        return t
    end
    t[k] = v
    return t
end

local function base8_tonumber(str)
    return tonumber(str, 8)
end

local terminfo
do
    local comment = P"#" * (P(1) - P"\n")^0 / 0;
    local whitespace = S" \t\n";
    local skip = (whitespace + comment)^0

    local backslash = P"\\" / "" * (
        R"03" * R"09"^-2 / unescape_octal
        + S"Eenlrtbfs0^,:\\" / unescape_char
    )

    local caret = (P"^" / "" * (R("@_") / unescape_caret)) + (P"^?" / "\127")
    local escape = caret + backslash
    local stringchar = (R"\033\126" - S",\\") + (S" \t\n" / "")
    local string = Cs((escape + stringchar)^0)

    local oct = P"0" * R"07"^0 / base8_tonumber
    local dec = R"19" * R"09"^0 / tonumber
    local hex = P"0x" * R("09", "AF", "af")^1 / tonumber
    local number = hex + oct + dec

    local capname = C(R("az", "AZ", "09", "..")^1)
    local boolcap = Cg(capname * Cc(true))
    local numcap = Cg(capname * P"#" * number)
    local strcap = Cg(capname * P"=" * string)
    local cancelled = Cg(capname * P"@" * Cc(false))
    local capspace = P"\n"^0 * S" \t"^1
    local cap = capspace * (strcap + numcap + cancelled + boolcap) * P","

    local entrychar = R"\032\126" - S","
    local entryname = Cg(Cc"TERM" * C(entrychar^1)) * P",\n"
    local caps = Cf(Ct"" * entryname * cap^1, setfield)
    local entry = skip * caps * skip
    local eof = P(-1)

    terminfo = Ct(entry^1) * eof
end

local function parse(input)
    local t = terminfo:match(input)
    if not t then
        return nil, "Parsing failed"
    end
    for i = 1, #t do
        local entry = assert(t[i])
        if entry.use then
            -- Add reference to main table for ChainedLookup
            entry.use._backref = t
        end
        local names = assert(entry.TERM)
        for name in names:gmatch("([^|]+)|") do
            t[name] = entry
        end
    end
    return t
end

local function parse_file(filename)
    local file, open_err = open(filename, "r")
    if not file then
        return nil, open_err
    end
    local text, read_err = file:read("*a")
    file:close()
    if not text then
        return nil, read_err
    end
    return parse(text)
end

return {
    parse = parse,
    parse_file = parse_file,
}
