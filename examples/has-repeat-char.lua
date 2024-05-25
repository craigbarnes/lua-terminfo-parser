local terminfo = require "terminfo-parser"
local escape = assert(terminfo.escape)
local write = assert(io.write)
local terms = assert(terminfo.parse_file("terminfo.src"))

for term, caps in terms:iter() do
    local rep = caps.rep
    if rep then
        write(("%18s:  %s\n"):format(term, escape(rep)))
    end
end
