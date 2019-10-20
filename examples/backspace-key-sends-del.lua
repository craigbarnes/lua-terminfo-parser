local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))

for term, caps in terms:iter() do
    if caps.kbs == "\127" then
        print(term)
    end
end
