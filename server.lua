require("items")
require("display")
require("input")
require("output")

local modem = peripheral.find("modem") or error("No modem attached", 0)
modem.open(43)

-- Test settings
local test = false
local inputChestFile = fs.open("inputChest", "r") or error("No input chest configured", 0)
local outputChestFile = fs.open("outputChest", "r") or error("No output chest configured", 0)

local inputChest = peripheral.wrap(inputChestFile.readLine()) or error("No input chest found", 0)
local outputChest = peripheral.wrap(outputChestFile.readLine()) or error("No output chest found", 0)

-- Get items
local periphsOrig = modem.getNamesRemote()
local periphs = {}

-- Filter out the in/out chests

for i, periph in ipairs(periphsOrig) do
    local inp = peripheral.getName(inputChest)
    local out = peripheral.getName(outputChest)

    if periph ~= inp and periph ~= out then
        table.insert(periphs, periph)
    end
end

print("--------------------------")
print("Loaded " .. #periphs .. " peripherals")
print("--------------------------")

Items = {}
StopOutput = false

while true do
    local function tasks()
        Items = GetItems(periphs)

        if StopOutput then
            StopOutput = false
        end

        print("Got " .. #Items .. " items")
        print("--------------------------")
        DrawMon(periphs)
        GetInput(periphs, inputChest)
    end

    local function events()
        OutputEvent(outputChest)
    end

    parallel.waitForAny(events, tasks)
end
