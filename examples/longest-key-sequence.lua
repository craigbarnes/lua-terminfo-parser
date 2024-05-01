local terminfo = require "terminfo-parser"
local escape = assert(terminfo.escape)
local min, max, write = math.min, math.max, io.write
local terms = assert(terminfo.parse_file("terminfo.src"))
local keys, n = {}, 0

for term, entry in terms:iter() do
    for capname, val in entry:iter() do
        if (capname:sub(1, 1) == "k" and type(val) == "string") then
            n = n + 1
            keys[n] = {
                term = assert(entry._TERM[1]),
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

local limit = min(n, 20)
local termwidth = 0
for i = 1, limit do
    termwidth = max(#keys[i].term, termwidth)
end

for i = 1, limit do
    local t = assert(keys[i])
    local tpl = "%3u  %-6s %-" .. min(60, termwidth) .. "s  %s\n"
    write(tpl:format(t.len, t.cap, t.term, escape(t.seq)))
end
