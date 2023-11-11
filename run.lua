local urlBase = "http://127.0.0.1:5500/"

-- Remove the old files
shell.execute("rm", "/storage.lua")
shell.execute("rm", "/items.lua")
shell.execute("rm", "/display.lua")
shell.execute("rm", "/input.lua")
shell.execute("rm", "/output.lua")
shell.execute("rm", "/server.lua")

-- Download the new files
shell.execute("wget", urlBase .. "storage.lua")
shell.execute("wget", urlBase .. "items.lua")
shell.execute("wget", urlBase .. "display.lua")
shell.execute("wget", urlBase .. "input.lua")
shell.execute("wget", urlBase .. "output.lua")
shell.execute("wget", urlBase .. "server.lua")

-- Run the new files
shell.execute("/server.lua")
