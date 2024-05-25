local terminfo = require "terminfo-parser"
local escape = assert(terminfo.escape)
local write = assert(io.write)
local terms = assert(terminfo.parse_file("terminfo.src"))
local counts, index, n = {}, {}, 0

for term, caps in terms:iter() do
    local kbs = caps.kbs
    if kbs then
        local count = counts[kbs]
        if count then
            counts[kbs] = count + 1
        else
            counts[kbs] = 1
            n = n + 1
            index[n] = kbs
        end
    end
end

table.sort(index, function(a, b)
    return counts[a] > counts[b]
end)

for i, str in ipairs(index) do
    write(("%5u  %s\n"):format(counts[str], escape(str)))
end
