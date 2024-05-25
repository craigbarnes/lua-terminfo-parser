local terminfo = require "terminfo-parser"
local write = assert(io.write)
local terms = assert(terminfo.parse_file("terminfo.src"))
local lengths = {}

local caps = {
    "op", "sgr0", "rmkx", "smkx", "rmcup", "smcup", "cnorm", "civis",
}

for i, entry in ipairs(terms) do
    for _, cap in ipairs(caps) do
        local seq = entry[cap]
        if seq then
            local seq_len = #seq
            if seq_len > (lengths[cap] or 0) then
                lengths[cap] = seq_len
            end
        end
    end
end

table.sort(caps, function(a, b)
    return lengths[a] > lengths[b]
end)

for i, str in ipairs(caps) do
    write(("%4u  %s\n"):format(lengths[str], str))
end
