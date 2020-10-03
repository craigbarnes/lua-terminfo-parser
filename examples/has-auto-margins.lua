local terminfo = require "terminfo-parser"
local terms = assert(terminfo.parse_file("terminfo.src"))
local write = assert(io.write)
local am, bw, nterms = 0, 0, 0

for term, caps in terms:iter() do
    write(("%24s:"):format(term))
    if caps.am then
        write("  am")
        am = am + 1
    end
    if caps.bw then
        write("  bw")
        bw = bw + 1
    end
    write("\n")
    nterms = nterms + 1
end

write (
    "\n Totals:\n\n",
    ("    am: %4u/%u\n"):format(am, nterms),
    ("    bw: %4u/%u\n"):format(bw, nterms),
    "\n"
)
