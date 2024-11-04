-- Parser for terminfo(5) source format.
-- Copyright 2018-2024 Craig Barnes.
-- SPDX-License-Identifier: GPL-3.0-only
-- See also: https://invisible-island.net/ncurses/#download_database

local lpeg = require "lpeg"
local char, tonumber, open, assert = string.char, tonumber, io.open, assert
local setmetatable, rawget = setmetatable, rawget
local pairs, ipairs, next = pairs, ipairs, next
local sort, concat = table.sort, table.concat
local wrap, yield = coroutine.wrap, coroutine.yield
local type, tostring = type, tostring
local P, R, S, V = lpeg.P, lpeg.R, lpeg.S, lpeg.V
local C, Cc, Cs = lpeg.C, lpeg.Cc, lpeg.Cs
local Cf, Cg, Ct = lpeg.Cf, lpeg.Cg, lpeg.Ct
local Cmt, Carg = lpeg.Cmt, lpeg.Carg
local _ENV = nil

-- NOTE: Numerical backslash sequences in Lua strings (e.g. "\27") are
-- decimal escapes; not octal as they would be in C or shell. This is
-- notable both in this table and in the LPeg grammar further below.
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

local function setfield(t, k, v)
    if k == "use" then
        local use = t._use
        if use then
            local length = use.length + 1
            use[length] = v
            use.length = length
        else
            t._use = {v, length = 1}
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

local function lineno(str, i)
    if i == 1 then
        return 1, 1
    end

    -- If the character at position i is a newline, adjust the calculation
    -- so that the reported position is the end of the line rather than the
    -- start of the next line
    local adj = (str:sub(i, i) == "\n") and 1 or 0

    local rest, n = str:sub(1, i - adj):gsub("[^\n]*\n", "")
    return n + 1, #rest + adj
end

local function tokenset_to_list(set)
    local list, i = {}, 0
    for s in pairs(set) do
        i = i + 1
        if s:match("^%p$") then
            -- Quote punctuation characters
            s = (s == "'") and '"\'"' or ("'" .. s .. "'")
        end
        list[i] = s
    end
    sort(list)
    return list
end

local char_to_printable = setmetatable ({
    ["\\"] = "\\\\",
    ["\a"] = "\\a",
    ["\b"] = "\\b",
    ["\t"] = "\\t",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    [0x7F] = "\\x7F",
}, {
    __index = function(t, ch)
        local byte = ch:byte()
        return (byte >= 32) and ch or ("\\x%02X"):format(byte)
    end
})

-- Get farthest failure position
local function getffp(subject, position, errorinfo)
    return errorinfo.ffp or position, errorinfo
end

local function report_error()
    local errorinfo = Cmt(Carg(1), getffp) * V"OneWord" / function(e, u)
        e.unexpected = u
        return e
    end
    return errorinfo / function(e)
        local filename = e.filename or ""
        local line, col = lineno(e.subject, e.ffp or 1)
        local unexpected = e.unexpected:gsub(".", char_to_printable)
        local expected = concat(tokenset_to_list(e.expected), ", ")
        local s = "%s:%d:%d: Syntax error: unexpected '%s', expecting %s"
        return nil, s:format(filename, line, col, unexpected, expected)
    end
end

local function setffp(subject, position, errorinfo, token_name)
    local ffp = errorinfo.ffp
    if not ffp or position > ffp then
        -- TODO: Instead of creating a new table each time the ffp advances,
        -- store token names in array indices (reusing a single table) and
        -- simply reset a length field here
        errorinfo.ffp = position
        errorinfo.expected = {[token_name] = true}
    elseif position == ffp then
        errorinfo.expected[token_name] = true
    end
    return false
end

local function updateffp(name)
    return Cmt(Carg(1) * Cc(name), setffp)
end

local function T(name)
    return V(name) + updateffp(name) * P(false)
end

local function symb(str)
    return P(str) + updateffp(str) * P(false)
end

local terminfo = P {
    V"Entries" * T"EOF" + report_error();

    Comment = P"#" * (P(1) - P"\n")^0 / 0;
    Space = S" \t\n";
    Skip = (V"Space" + V"Comment")^0;

    BackSlash = P"\\" / "" * (
        R"03" * R"09"^-2 / unescape_octal
        + S"Eenlrtbfs0^,:\\" / unescape_char
    );

    Caret = (P"^" / "" * (R("@_") / unescape_caret)) + (P"^?" / "\127");
    Escape = V"Caret" + V"BackSlash";
    StringChar = (R"\033\126" - S",\\") + (S" \t\n" / "");
    String = Cs((V"Escape" + V"StringChar")^0);

    Oct = P"0" * R"07"^0 / base8_tonumber;
    Dec = R"19" * R"09"^0 / tonumber;
    Hex = P"0x" * R("09", "AF", "af")^1 / tonumber;
    Number = V"Hex" + V"Oct" + V"Dec";

    CapName = C(R("az", "AZ", "09", "..", "__")^1);
    BoolCap = Cg(T"CapName" * Cc(true));
    NumCap = Cg(T"CapName" * symb"#" * T"Number");
    StrCap = Cg(T"CapName" * symb"=" * T"String");
    Cancelled = Cg(T"CapName" * symb"@" * Cc(false));
    CapSpace = P"\n"^0 * S" \t"^1;
    Cap = V"CapSpace" * (V"StrCap" + V"NumCap" + V"Cancelled" + V"BoolCap") * symb",";

    EntryChar = R"\032\126" - S",";
    EntryEnd = P",\n";
    EntryName = Cg(Cc"_DESC" * C(V"EntryChar"^1)) * T"EntryEnd";
    Caps = Cf(Ct"" * T"EntryName" * T"Cap"^1, setfield);
    Entry = V"Skip" * V"Caps" * V"Skip";
    Entries = Ct(V"Entry"^1);
    EOF = P(-1);

    -- Used by report_error() to extract the "unexpected" string
    OneWord = C(P(1)) + Cc(V"EOF");
}

local function is_non_enumerated_field(name)
    local prefixes = {
        ["."] = true, -- Commented out capability name
        ["_"] = true, -- Metadata field
    }
    return prefixes[name:sub(1, 1)]
end

local function iter_entry(self)
    local seen = {}
    local function iter(entry)
        for name, val in pairs(entry) do
            if not is_non_enumerated_field(name) and not seen[name] then
                seen[name] = true
                yield(name, val)
            end
        end
    end
    local function deep_iter(entry)
        iter(entry)
        local use = rawget(entry, "_use")
        if use then
            for i = use.length, 1, -1 do
                local refname = assert(use[i])
                deep_iter(assert(use._backref[refname]))
            end
        end
    end
    return wrap(function() deep_iter(self) end)
end

local Entry = {}

function Entry:__index(k)
    if k == "iter" then
        return iter_entry
    elseif is_non_enumerated_field(k) then
        return nil
    end
    local use = rawget(self, "_use")
    if not use then
        return nil
    end
    for i = use.length, 1, -1 do
        local refname = assert(use[i])
        local v = use._backref[refname][k]
        if v ~= nil then
            return v
        end
    end
end

local Entries = {}
Entries.__index = Entries

function Entries:iter()
    local function iter(t)
        for i, entry in ipairs(t) do
            local term = assert(entry._TERM[1])
            yield(term, entry, i)
        end
    end
    return wrap(function() iter(self) end)
end

local function parse(input, filename)
    local errorinfo = {subject = input, filename = filename}
    local entries, err = terminfo:match(input, 1, errorinfo)
    if not entries then
        return nil, err
    end
    for i = 1, #entries do
        local entry = assert(entries[i])
        local use = entry._use
        if use then
            -- Add reference to main table, for Entry methods to use
            use._backref = entries
        end
        local desc = assert(entry._DESC)
        local n = 0
        entry._TERM = {}
        for name in desc:gmatch("([^|]+)|") do
            entries[name] = entry
            n = n + 1
            entry._TERM[n] = name
        end
        if n == 0 then
            -- Some entries have only 1 name and no description, so
            -- the gmatch() loop above doesn't extract anything
            entries[desc] = entry
            entry._TERM[1] = desc
        end
        setmetatable(entry, Entry)
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
    return parse(text, filename)
end

local escmap = setmetatable ({
    [":"] = "\\:",
    [","] = "\\,",
    ["^"] = "\\^",
    [" "] = "\\s",
    ["\\"] = "\\\\",
    ["\a"] = "\\a",
    ["\b"] = "\\b",
    ["\t"] = "\\t",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\27"] = "\\E",
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
