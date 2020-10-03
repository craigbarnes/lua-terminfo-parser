local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
local bw, nterms = 0, 0

for term, caps in terms:iter() do
    if caps.bw then
        io.write("* ", term, "\n")
        bw = bw + 1
    end
    nterms = nterms + 1
end

io.write(("\n%u/%u terminals have 'bw' capability set\n\n"):format(bw, nterms))
