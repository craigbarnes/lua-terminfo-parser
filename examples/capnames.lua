local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
local ignored = {TERM = true, use = true}
local capnames = {n = 0}

for i, entry in ipairs(terms) do
    for k, v in pairs(entry) do
        if not ignored[k] and k:sub(1, 1) ~= "." and not capnames[k] then
            local n = capnames.n + 1
            capnames[n] = k
            capnames.n = n
            capnames[k] = true
        end
    end
end

table.sort(capnames)

for i, name in ipairs(capnames) do
    print(name)
end
