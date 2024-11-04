local terminfo = assert(loadfile("./terminfo-parser.lua", "t"))()
local parse = assert(terminfo.parse)
local type, assert, error = type, assert, error
local _ENV = nil

local function assertError(input, line, column, pattern)
    local t, e = parse(input)
    assert(t == nil)
    assert(type(e) == "string")
    if e:find(("^:%d:%d:"):format(line, column)) == nil then
        local message = 'Expected error at %d:%d, got error:\n   "%s"'
        error(message:format(line, column, e), 2)
    end
    if pattern and not e:match(pattern) then
        local message = 'Expected error to match "%s", got error:\n   "%s"'
        error(message:format(pattern, e), 2)
    end
end

assertError('entry|lacking comma\n  am,\n', 2, 0, "unexpected '\\n', expecting EntryEnd")
assertError('entry|xyz,\n  am bw\n', 2, 5, "unexpected ' ', expecting '#', ',', '=', '@'")
