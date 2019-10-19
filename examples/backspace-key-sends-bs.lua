local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))

for term, caps in pairs(terms) do
    if type(term) == "string" and caps.kbs == "\b" then
        print(term)
    end
end
