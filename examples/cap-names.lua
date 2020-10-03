local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
local special_fields = assert(terminfo.special_fields)
local capnames = {n = 0}

local function is_ignored_field(k)
    -- Capability names starting with a period are "commented out"
    return special_fields[k] or k:sub(1, 1) == "."
end

for i, entry in ipairs(terms) do
    for k, v in pairs(entry) do
        if not capnames[k] and not is_ignored_field(k) then
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
