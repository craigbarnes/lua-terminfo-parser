local terminfo = require "terminfo-parser"
local escape = assert(terminfo.escape)
local write = assert(io.write)
local capname = arg[1]
local match_value = arg[2]

local usage = [[
Usage: # CAPNAME [MATCH-VALUE]

Examples:
   # bce
   # Ms
   # kbs $'\b'
   # kbs $'\x7F'
]]

if not capname then
    io.stderr:write(usage:gsub("#", "lua " .. arg[0]), "\n")
    os.exit(1)
end

local terms = assert(terminfo.parse_file("terminfo.src"))
local nmatch = 0

for term, caps in terms:iter() do
    local value = caps[capname]
    if value and (not match_value or value == match_value) then
        write(("%23s: %s=%s\n"):format(term, capname, escape(value)))
        nmatch = nmatch + 1
    end
end

write("\nFound ", nmatch , " terminals with capability: ", capname)

if match_value then
    write("=", escape(match_value))
end

write("\n\n")
