--!strict

local doors = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local TWEEN_SERVICE = game:GetService("TweenService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local SERVER_SCRIPT_SERVICE = game:GetService("ServerScriptService")

-- modules
local DEBUG = require(REPLICATED_STORAGE.debug)
local TYPES = require(REPLICATED_STORAGE.types)
local PERMISSIONS = require(SERVER_SCRIPT_SERVICE.permissions)

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- tweens a door to a specified target position
local function tween_door(door: Part, duration: number, target_position: Vector3)
	local opening_tween = TWEEN_SERVICE:Create(
		door, 
		TweenInfo.new(
			duration,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.InOut
		),
		{ ["Position"] = target_position }
	)
	opening_tween:Play()
	opening_tween.Completed:Wait()
end

-- opens a door
function doors.open_door(door_system: Model, door: Part, proximity_prompt: ProximityPrompt)
	local open_state = DEBUG.exists(door_system, "state.open") :: StringValue
	if open_state.Value == "open" then return end
	open_state.Value = "open"
	proximity_prompt.Enabled = false
	local config = DEBUG.exists(door_system, "config") :: Configuration
	local moving_duration = DEBUG.exists(config, "moving_duration.Value") :: number
	local target_position = DEBUG.exists(config, "open_position.Value.WorldCFrame.Position") :: Vector3
	DEBUG.log("Opening door")
	tween_door(door, moving_duration, target_position)
end

-- closes a door
function doors.close_door(door_system: Model, door: Part, proximity_prompt: ProximityPrompt)
	local open_state = DEBUG.exists(door_system, "state.open") :: StringValue
	if open_state.Value == "closed" then return end
	open_state.Value = "closed"
	local config = DEBUG.exists(door_system, "config") :: Configuration
	local moving_duration = DEBUG.exists(config, "moving_duration.Value") :: number
	local target_position = DEBUG.exists(config, "closed_position.Value.WorldCFrame.Position") :: Vector3
	DEBUG.log("Closing door")
	tween_door(door, moving_duration, target_position)
	proximity_prompt.Enabled = true
end

-- attempts to open a door
function doors.try_open_door(player: Player, door_system: Model, door: Part, proximity_prompt: ProximityPrompt)
	local permissions = DEBUG.exists(door_system, "config.permission_archetype.Value") :: Configuration
	local is_locked = DEBUG.exists(door_system, "state.locked.Value") :: boolean
	if PERMISSIONS.player_has_permission(player, permissions) and not is_locked then
		DEBUG.log("Door is unlocked")
		doors.open_door(door_system, door, proximity_prompt)
	elseif is_locked then
		DEBUG.log("Door is locked")
	end
end

-- attempts to close a door
function doors.try_close_door(player: Player, door_system: Model, door: Part, proximity_prompt: ProximityPrompt)
	local permissions = DEBUG.exists(door_system, "config.permission_archetype.Value") :: Configuration
	local is_locked = DEBUG.exists(door_system, "state.locked.Value") :: boolean
	if PERMISSIONS.player_has_permission(player, permissions) and not is_locked then
		DEBUG.log("Door is unlocked")
		doors.close_door(door_system, door, proximity_prompt)
	elseif is_locked then
		DEBUG.log("Door is locked")
	end
end

-- locks a door
function doors.lock_door(door_system: Model)
	local state = DEBUG.exists(door_system, "state.locked") :: BoolValue
	state.Value = true
	DEBUG.log("Locked door")
end

-- unlocks a door
function doors.unlock_door(door_system: Model)
	local state = DEBUG.exists(door_system, "state.locked") :: BoolValue
	state.Value = false
	DEBUG.log("Unlocked door")
end



--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return doors
