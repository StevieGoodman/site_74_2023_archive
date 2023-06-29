--!strict

local debug = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local RUN_SERVICE = game:GetService("RunService")

-- constants
local IN_STUDIO = RUN_SERVICE:IsStudio()
local ON_SERVER = RUN_SERVICE:IsServer()

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- prints out a log message only in studio.
function debug.log(message: string)
	if IN_STUDIO or ON_SERVER then
		print(`DEBUG: {message}`)
	end
end

-- alias for Lua's error function.
function debug.error(message: string, source: Instance): ()
	error(`ERROR: {message}\nSOURCE: {source:GetFullName()}`)
end

-- returns an instance if it exists in the game, otherwise errors.
function debug.exists(starting_instance: any, path: string): any
	if starting_instance == nil then 
		error("MISSING: Can't find starting instance!") 
	end
	local child_names = path:split(".")
	local parent_instance: any = starting_instance
	for _, child_name in child_names do
		local success = pcall(
			function()
				parent_instance = parent_instance[child_name]
			end
		)
		if not success then
			error(`MISSING: {(parent_instance :: Instance):GetFullName()}.{child_name}`)
		end
	end
	return parent_instance
end

-- replaces a value with a debug value if in studio and debug value exists.
function debug.debug_value<T>(debug_value: T, normal_value: T): T
	if IN_STUDIO then
		return if debug_value ~= nil then debug_value :: T else normal_value
	else
		return normal_value
	end
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return debug
