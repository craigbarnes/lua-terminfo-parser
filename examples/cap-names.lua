local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
local capnames = {n = 0}

for term, caps in terms:iter() do
    for k in caps:iter() do
        if not capnames[k] then
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
