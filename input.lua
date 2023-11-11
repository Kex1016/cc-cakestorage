package.preload["input"] = function()
    return {
        GetInput = GetInput
    }
end

function GetInput(periphs, inputChest)
    local validNames = {
        "chest",
        "reinfchest"
    }

    local valid = false
    local name = peripheral.getName(inputChest)
    for _, name in ipairs(validNames) do
        if name:find(name) then
            valid = true
            break
        end
    end

    if not valid then error("No chest attached to the left. Add a chest to make it an input chest.", 0) end

    for slot, item in pairs(inputChest.list()) do
        for _, periph in ipairs(periphs) do
            if periph:find("reinfchest") or periph:find("chest") then
                local chest = peripheral.wrap(periph)
    
                -- Check if the chest has open slots
                local chSize = chest.size()
                local chList = chest.list()
                if #chList >= chSize then
                    print("No open slots in chest, skipping...")
                    break
                end

                chest.pullItems(name, slot, item.count)
            end
        end
    end
end
