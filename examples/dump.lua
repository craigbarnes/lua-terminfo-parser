local terminfo = require "terminfo-parser"
local escape = assert(terminfo.escape)
local write = assert(io.write)
local terms = assert(terminfo.parse_file("terminfo.src"))

for _, caps, idx in terms:iter() do
    local tnames = assert(caps._TERM)
    write(('[%u], ["%s"]'):format(idx, assert(tnames[1])))
    for i = 2, #tnames do
        write(', ["', tnames[i], '"]')
    end
    write(":\n")

    for capname, seq in caps:iter() do
        write(("   %-7s %s\n"):format(capname, escape(seq)))
    end
    write("\n")
end
