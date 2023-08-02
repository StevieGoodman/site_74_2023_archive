--!strict

local debug = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local RUN_SERV = game:GetService("RunService")

-- constants
local IN_STUDIO = RUN_SERV:IsStudio()
local ON_SERVER = RUN_SERV:IsServer()

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- prints out a log message only in studio.
function debug.log(msg: string)
    if IN_STUDIO or ON_SERVER then
        print(`DEBUG: {msg}`)
    end
end

-- alias for Lua's error function.
function debug.err(msg: string, src: Instance): ()
    error(`ERROR: {msg}\nSOURCE: {src:GetFullName()}`)
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return debug
