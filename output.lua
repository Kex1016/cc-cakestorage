local searchString = ""
local itemNum = 1
local itemAmount = "0"

package.preload["output"] = function()
	return {
		OutputEvent = OutputEvent,
	}
end

-- FIXME: Might as well just rewrite this whole thing. It's a mess.

local mon = peripheral.find("monitor") or error("No monitor attached", 0)
local w, h = mon.getSize()

local title = "Search Inventory"
local subtitle = "Press enter to search"
local text = "$ "
local footer = "Right-click keyboard to type"
local textX = #text + 1

local screens = {
	"search",
	"choose",
	"amount",
	"output",
}

local screenIndex = 1
local screen = screens[screenIndex]

local key_blacklist = {
	"leftShift",
	"rightShift",
	"leftCtrl",
	"rightCtrl",
	"leftAlt",
	"rightAlt",
	"slash",
	"period",
	"minus",
	"equals",
	"comma",
	"semicolon",
	"leftBracket",
	"rightBracket",
	"grave",
	"enter",
}

local arrow_keys = {
	"up",
	"down",
	"left",
	"right",
}

local numbers = {
	zero = "0",
	one = "1",
	two = "2",
	three = "3",
	four = "4",
	five = "5",
	six = "6",
	seven = "7",
	eight = "8",
	nine = "9",
}

local selectedItem = {}

local function writeMon()
	mon.clear()
	mon.setCursorPos((w / 2) - (#title / 2), 1)
	mon.setTextColor(colors.green)
	mon.write(title)

	mon.setCursorPos((w / 2) - (#subtitle / 2), 2)
	mon.setTextColor(colors.gray)
	mon.write(subtitle)

	mon.setCursorPos(1, h)
	mon.setTextColor(colors.red)
	mon.write(footer)

	mon.setCursorPos(1, 4)
	mon.setTextColor(colors.yellow)
	mon.write(text)

	mon.setCursorPos(textX, 4)
	mon.setTextColor(colors.white)

	if screen == screens[1] then
		mon.write(searchString)
	elseif screen == screens[2] then
		mon.write(selectedItem.name)
	elseif screen == screens[3] then
		mon.write(tostring(itemAmount))
	end
end

writeMon()

function OutputEvent(outputChest)
	local event, key, is_held = os.pullEvent("key")
	local char = keys.getName(key)

	if char == "enter" then
		if #selectedItem == 0 then
			screenIndex = 1
			screen = screens[screenIndex]
		end

		if screenIndex >= #screens then
			screenIndex = 1
			screen = screens[screenIndex]

			-- reset values
			searchString = ""
			itemNum = 1
			itemAmount = ""
		else
			screenIndex = screenIndex + 1
			screen = screens[screenIndex]
		end
	end

	local valid = true
	for _, key in ipairs(key_blacklist) do
		if char == key then
			valid = false
			break
		end
	end

	local function replaceNumbers(character)
		if numbers[character] then
			return numbers[character]
		end

		return character
	end

	local function replaceString(str, character)
		local _str = str

		for _, key in ipairs(arrow_keys) do
			if character == key then
				character = ""
				break
			end
		end

		if valid then
			if character == "space" then
				_str = _str .. " "
			elseif character == "backspace" then
				_str = _str:sub(1, #_str - 1)
			else
				_str = str .. replaceNumbers(character)
			end

			-- if string larger than screen, return null
			if #_str > (w - #text) then
				_str = _str:sub(1, #_str - 1)
			end
		end

		return _str
	end

	local function listSearchItems(searchItems, doSearch)
		if doSearch then
			local resY = 6
			selectedItem = {}

			for _, item in ipairs(searchItems) do
				if item.name:lower():find(searchString:lower()) then
					if resY > h - 1 then
						break
					end

					-- clamp name
					local name = item.name
					if #name > (w - 8) then
						name = name:sub(1, w - 3) .. "..."
					end

					mon.setCursorPos(1, resY)
					mon.setTextColor(colors.lightGray)
					mon.write(name)

					mon.setCursorPos(w - (#tostring(item.count)), resY)
					mon.setTextColor(colors.green)
					mon.write(tostring(item.count))

					resY = resY + 1
					table.insert(selectedItem, item)
				end
			end
		else
			local resY = 4
			for index, item in ipairs(searchItems) do
				if resY > h - 1 then
					break
				end

				-- clamp name
				local name = item.name
				if index == itemNum then
					name = "> " .. name
				end
				if #name > (w - 8) then
					name = name:sub(1, w - 3) .. "..."
				end

				mon.setCursorPos(1, resY)
				mon.setTextColor(colors.lightGray)
				mon.write(name)

				mon.setCursorPos(w - (#tostring(item.count)), resY)
				mon.setTextColor(colors.green)
				mon.write(tostring(item.count))

				resY = resY + 1
			end
		end
	end

	local function onlyNumbers(string, character, max)
		local _str = string

		if numbers[character] then
			_str = _str .. numbers[character]
		elseif character == "backspace" then
			_str = _str:sub(1, #_str - 1)
		end

		if tonumber(_str) then
			if tonumber(_str) > max then
				_str = tostring(max)
			end

			if tonumber(_str) < 0 then
				_str = "0"
			end
		end

		return _str
	end

	if screen == screens[1] then
		searchString = replaceString(searchString, char)

		writeMon()
		listSearchItems(Items, true)
	elseif screen == screens[2] then
		-- Draw items
		subtitle = "Choose an item"
		text = ""

		if char == "up" then
			if itemNum > 1 then
				itemNum = itemNum - 1
			end
		elseif char == "down" then
			if itemNum < #selectedItem then
				itemNum = itemNum + 1
			end
		end

		-- Draw items
		writeMon()
		listSearchItems(selectedItem, false)
	elseif screen == screens[3] then
		subtitle = "How many?"
		text = "$ "
		local max = selectedItem[itemNum].count
		itemAmount = onlyNumbers(itemAmount, char, max)
		writeMon()
	elseif screen == screens[4] then
		-- Output items
		title = "Outputting..."
		subtitle = "Please wait..."
		text = ""
		footer = ""

		writeMon()

		local item = selectedItem[itemNum]

		local amount = tonumber(itemAmount)

		-- if the number of items in the chest is less than the number of items the player asked for, then set the amount to the number of items in the chest
		if item.count < amount then
			amount = item.count
		end

		-- if the amount is 0, then don't do anything
		if amount == 0 then
			return
		end

		-- go through the chests until the amount is 0 and send them to the output chest
		local outputChestName = peripheral.getName(outputChest)

		for index, periph in ipairs(item.periphs) do
			local chest = peripheral.wrap(periph.name)
			local chestItem = chest.getItemDetail(periph.slot)

			if not chestItem then
				break
			end

			if chestItem.count >= amount then
				chest.pushItems(outputChestName, periph.slot, amount)
				periph.count = periph.count - amount
				amount = 0
			else
				chest.pushItems(outputChestName, periph.slot, chestItem.count)
				periph.count = periph.count - chestItem.count
				amount = amount - chestItem.count
			end

			item.count = item.count - amount

			if amount == 0 then
				break
			end
		end

		for index, periph in ipairs(item.periphs) do
			if periph.count <= 0 then
				table.remove(item.periphs, index)
			end
		end

		if item.count <= 0 then
			table.remove(Items, itemNum)
		end

		Items[item.id] = item

		title = "Success!"
		subtitle = "Going back to menu..."
		text = ""
		footer = ""

		writeMon()

		sleep(2)

		screenIndex = 1
		screen = screens[screenIndex]

		-- reset values
		title = "Search Inventory"
		subtitle = "Press enter to search"
		text = "$ "
		textX = #text + 1
		footer = "Right-click keyboard to type"

		searchString = ""
		itemNum = 1
		itemAmount = ""

		selectedItem = {}

		writeMon()
	end
end
