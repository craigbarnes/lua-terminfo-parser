local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
local max_lengths = {}

local caps = {
    "op", "sgr0", "rmkx", "smkx", "rmcup", "smcup", "cnorm", "civis",
}

for i, entry in ipairs(terms) do
    for _, cap in ipairs(caps) do
        local seq = entry[cap]
        if seq then
            local seq_len = #seq
            if seq_len > (max_lengths[cap] or 0) then
                max_lengths[cap] = seq_len
            end
        end
    end
end

for k, v in pairs(max_lengths) do
    print(k, v)
end
