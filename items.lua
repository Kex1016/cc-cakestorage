package.preload["items"] = function()
    return {
        GetItems = GetItems
    }
end

function GetItems(periphs)
    local items = {}

    for index, periph in ipairs(periphs) do
        if periph:find("reinfchest") or periph:find("chest") then
            local chest = peripheral.wrap(periph)

            for slot, item in pairs(chest.list()) do
                local _i = chest.getItemDetail(slot)
                if not _i then
                    break
                end

                table.insert(items, {
                    id = index,
                    name = _i.displayName,
                    count = item.count,
                    periphs = {
                        {
                            name = periph,
                            slot = slot,
                            count = item.count
                        }
                    }
                })
            end
        end
    end

    -- Sort items by name
    table.sort(items, function(a, b)
        return a.name < b.name
    end)

    -- Group items
    local last = items[1]
    local i = 2

    while i <= #items do
        if items[i].name == last.name then
            last.count = last.count + items[i].count
            table.insert(last.periphs, items[i].periphs[1])
            table.remove(items, i)
        else
            last = items[i]
            i = i + 1
        end
    end

    -- Sort items by count and then by name
    table.sort(items, function(a, b)
        if a.count == b.count then
            return a.name < b.name
        end

        return a.count > b.count
    end)

    return items
end
