local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
local counts, index, n = {}, {}, 0

for term, caps in pairs(terms) do
    if type(term) == "string" then
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
end

table.sort(index, function(a, b)
    return counts[a] > counts[b]
end)

for i, str in ipairs(index) do
    io.write(("%5u  %s\n"):format(counts[str], terminfo.escape(str)))
end
