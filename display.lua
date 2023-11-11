package.preload["display"] = function()
    return {
        DrawMon = DrawMon
    }
end

function DrawMon(periphs)
    for _, periph in ipairs(periphs) do
        if periph:find("tm_") then
            --print("Found monitor, drawing...")
    
            local gpu = peripheral.wrap(periph) or error("No monitor attached", 0)
            gpu.setSize(64)
            gpu.refreshSize()
            gpu.fill()
            gpu.sync()
    
            local w, h, x, y = gpu.getSize()
            gpu.setFont("ascii")
    
            w, h = gpu.getSize()
    
            -- add some padding
            w = w - 10
            h = h - 10
    
            -- draw header
            gpu.filledRectangle(1, 1, w + 10, 40, 0x252625)
            local title = "Inventory"
            gpu.drawTextSmart((w / 2) - ((#title * 10) / 2), 5, title, 0x00FF00, 0x252625, 20)
            
            -- draw border
            gpu.rectangle(1, 1, w + 10, h + 10, 0x252625)
            gpu.drawTextSmart(5, 25, "Name", 0x7e7f7e)
            gpu.drawTextSmart(w - 50, 25, "Count", 0x006b0a)
    
            local textX, textY = 5, 45
    
            for _, item in ipairs(Items) do
                if textY >= h then
                    break
                end
    
                -- clamp name
                local name = item.name
                if #name > 15 then
                    name = name:sub(1, w - 3) .. "..."
                end
    
                gpu.drawTextSmart(textX, textY, item.name)
                gpu.drawTextSmart(w - (#tostring(item.count) * 12) + 5, textY, tostring(item.count), 0x00FF00)
                textY = textY + 20
            end
    
            break
        end
    end
end