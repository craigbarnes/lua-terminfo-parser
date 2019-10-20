local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))

for term, caps in terms:iter() do
    if caps.kbs == "\b" then
        print(term)
    end
end
