-- Get args
local args = {...}
if #args < 1 then
    print("Usage: storage <input/output> <peripheral>")
    return
end

local type = args[1] or error("No type specified", 0)

-- Write to file
local filename = type .. "Chest"
local file = fs.open(filename, "w")
file.writeLine(args[2])
file.close()
