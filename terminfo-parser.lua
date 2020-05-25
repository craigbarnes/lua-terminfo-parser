-- Parser for terminfo(5) source format.
-- Copyright 2018-2019 Craig Barnes.
-- SPDX-License-Identifier: GPL-2.0-only
-- See also: https://invisible-island.net/ncurses/#download_database

local lpeg = require "lpeg"
local char, tonumber, open, assert = string.char, tonumber, io.open, assert
local ipairs, setmetatable = ipairs, setmetatable
local wrap, yield = coroutine.wrap, coroutine.yield
local type, tostring = type, tostring
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
    ["l"] = "\n",
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

-- These are the metadata fields added to each entry by the parser
local special_fields = {
    DESC = true, -- Raw/unparsed entry header
    TERM = true, -- Array of TERM names (parsed from DESC)
    use = true, -- Array of "use" references (if any)
}

local ChainedLookup = {
    __index = function(t, k)
        assert(not special_fields[k], "Invalid key: " .. k)
        local use = assert(t.use)
        for i = use.length, 1, -1 do
            local refname = assert(use[i])
            local v = use._backref[refname][k]
            if v ~= nil then
                return v
            end
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
    assert(t[k] == nil, "duplicate field")
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
    local entryname = Cg(Cc"DESC" * C(entrychar^1)) * P",\n"
    local caps = Cf(Ct"" * entryname * cap^1, setfield)
    local entry = skip * caps * skip
    local eof = P(-1)

    terminfo = Ct(entry^1) * eof
end

local Entries = {}
Entries.__index = Entries

function Entries:iter()
    local function iter(t)
        for i, v in ipairs(t) do
            yield(v.TERM[1], v)
        end
    end
    return wrap(function() iter(self) end)
end

local function parse(input)
    local entries = terminfo:match(input)
    if not entries then
        return nil, "Parsing failed"
    end
    for i = 1, #entries do
        local entry = assert(entries[i])
        if entry.use then
            -- Add reference to main table for ChainedLookup
            entry.use._backref = entries
        end
        local desc = assert(entry.DESC)
        local n = 0
        entry.TERM = {}
        for name in desc:gmatch("([^|]+)|") do
            entries[name] = entry
            n = n + 1
            entry.TERM[n] = name
        end
    end
    return setmetatable(entries, Entries)
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

local escmap = setmetatable ({
    [":"] = "\\:",
    [","] = "\\,",
    ["^"] = "\\^",
    [" "] = "\\s",
    ["\\"] = "\\\\",
    ["\127"] = "^?",
}, {
    __index = function(t, ch)
        local byte = ch:byte()
        if byte < 32 then
            return ("^%c"):format(byte + 64)
        elseif byte > 127 then
            return ("\\%03o"):format(byte)
        end
        return ch
    end
})

local function escape(cap)
    if type(cap) == "string" then
        return (cap:gsub(".", escmap))
    end
    return tostring(cap)
end

return {
    parse = parse,
    parse_file = parse_file,
    escape = escape,
}
