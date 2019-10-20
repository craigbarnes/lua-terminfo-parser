local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))

for term, caps in pairs(terms) do
    if type(term) == "string" then
        local rep = caps.rep
        if rep then
            io.write(("%18s:  %s\n"):format(term, terminfo.escape(rep)))
        end
    end
end
