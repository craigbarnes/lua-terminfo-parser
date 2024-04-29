local terminfo = require "terminfo-parser"
local serpent = require "serpent"
local dump = assert(serpent.dump)
local terms = assert(terminfo.parse_file("terminfo.src"))

local options = {
    name = "terms",
    indent = "    ",
    comment = false,
    compact = false,
    fatal = true,
    sortkeys = true,
    sparse = true,
}

io.write(dump(terms, options), "\n")
