local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
local counts, index, n = {}, {}, 0

for term, caps in terms:iter() do
    local el = caps.el
    if el then
        local count = counts[el]
        if count then
            counts[el] = count + 1
        else
            counts[el] = 1
            n = n + 1
            index[n] = el
        end
    end
end

table.sort(index, function(a, b)
    return counts[a] > counts[b]
end)

for i = 1, n do
    local str = index[i]
    io.write(("%5u  %s\n"):format(counts[str], terminfo.escape(str)))
end
