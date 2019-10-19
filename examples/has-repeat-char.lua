local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))

local escmap = setmetatable ({
    ["\a"] = "\\a",
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
    ["\v"] = "\\v",
    ["\\"] = "\\\\",
    ['"'] = '\\"',
}, {
    __index = function(t, ch)
        local byte = ch:byte()
        if byte <= 31 or byte >= 127 then
            return ("\\%03o"):format(byte)
        end
        return ch
    end
})

local function escape_code_to_string(code)
    if not code then
        return '""'
    end
    return '"' .. code:gsub(".", escmap) .. '"'
end

for term, caps in pairs(terms) do
    if type(term) == "string" then
        local rep = caps.rep
        if rep then
            io.write(("%18s:  %s\n"):format(term, escape_code_to_string(rep)))
        end
    end
end
