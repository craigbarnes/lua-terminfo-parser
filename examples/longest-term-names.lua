local terminfo = require "terminfo-parser"
local escape = assert(terminfo.escape)
local write = assert(io.write)
local terms = assert(terminfo.parse_file("terminfo.src"))

local n = 0
local names = {}

for _, caps in terms:iter() do
    local t = assert(caps._TERM)
    for i = 1, #t do
        n = n + 1
        names[n] = t[i]
    end
end

table.sort(names, function(a, b)
    return #a > #b
end)

local limit = math.min(tonumber(arg[1]) or 10, #names)
for i = 1, limit do
    local name = assert(names[i])
    write(name, ": ", #name, "\n")
end
