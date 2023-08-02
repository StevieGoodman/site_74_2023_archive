--!strict

--[[
	Provides various commonly used utility functions.
--]]

local utilities = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local PLAYERS    = game:GetService("Players")
local REPL_STORE = game:GetService("ReplicatedStorage")

-- modules
local DEBUG = require(REPL_STORE.modules.debug)

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

function utilities.get_by_path(root: any, path: string): any?
	if root == nil then return nil end
	local children = string.split(path, ".")
	for _, child in children do
		local success = pcall(function() 
			root = root[child]
		end)
		if success then continue end
		return nil
	end
	return root
end

function utilities.get_by_path_req(root: any, path: string): any
    local result = utilities.get_by_path(root, path)
    if not result then
        DEBUG.err(`Can't reach required path "{path}"`, root)
    end
    return result
end

function utilities.set_id(model: Model, id: number): ()
    model:SetAttribute("id", id)
end

function utilities.get_id(model: Model): number
    return model:GetAttribute("id")
end

function utilities.get_player_from(part: Part): Player?
    for _, player in PLAYERS:GetChildren() do
        local char = utilities.get_by_path(player, "Character") :: Model
        if char == nil then continue end
        if part:IsDescendantOf(char) then
            return player
        end
    end
    return nil
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return utilities
