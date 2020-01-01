local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
local keys, n = {}, 0

for i, entry in ipairs(terms) do
    for capname, val in pairs(entry) do
        if (capname:sub(1, 1) == "k" and type(val) == "string") then
            n = n + 1
            keys[n] = {
                term = entry.TERM[1],
                cap = capname,
                seq = val,
                len = #val
            }
        end
    end
end

table.sort(keys, function(a, b)
    if a.len == b.len then
        if a.term == b.term then
            return a.cap > b.cap
        end
        return a.term > b.term
    end
    return a.len > b.len
end)

for i = 1, n do
    local t = assert(keys[i])
    local seq = terminfo.escape(t.seq)
    io.write(("%3u  %-6s %-18s %s\n"):format(t.len, t.cap, t.term, seq))
    if i >= 20 then
        break -- Show top 20
    end
end
