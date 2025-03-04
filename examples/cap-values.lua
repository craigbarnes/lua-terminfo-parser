local terminfo = require "terminfo-parser"
local escape = assert(terminfo.escape)
local write = assert(io.write)
local terms = assert(terminfo.parse_file("terminfo.src"))
local counts, index, n = {}, {}, 0
local verbose = (arg[1] == "-v")
local capname = arg[verbose and 2 or 1]

if not capname then
    io.stderr:write("Usage: ", arg[0], " [-v] CAP-NAME\n")
    os.exit(1)
end

for term, caps in terms:iter() do
    local val = caps[capname]
    if val then
        if verbose then
            write(("%5s   %s\n"):format(escape(val), term))
        end
        local count = counts[val]
        if count then
            counts[val] = count + 1
        else
            counts[val] = 1
            n = n + 1
            index[n] = val
        end
    end
end

if n == 0 then
    io.stderr:write("Error: no entries with capability '", capname, "'\n")
    os.exit(1)
end

table.sort(index, function(a, b)
    return counts[a] > counts[b]
end)

if verbose then
    write("\nTotals\n-----------\n")
end

for i = 1, n do
    local str = index[i]
    write(("%5u  %s\n"):format(counts[str], escape(str)))
end
