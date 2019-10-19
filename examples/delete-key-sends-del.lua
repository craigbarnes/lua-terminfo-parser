local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))

for term, caps in pairs(terms) do
    if type(term) == "string" and caps.kdch1 == "\127" then
        print(term)
    end
end
