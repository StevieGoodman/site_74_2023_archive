--!strict

--[[
    Provides several useful permission functions.
--]]

local permissions = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- modules
local DEBUG = require(script.Parent.debug)
local ENUMS = require(script.Parent.enums)
local UTILS = require(script.Parent.utilities)

-- constants
local MAIN_GROUP_ID = 4373288
local RANK_TO_CLASS: {ENUMS.Class} = {
    ["Class-C Personnel"] = "class-c",
    ["Class-B Personnel"] = "class-b",
    ["Class-A Personnel"] = "class-a",
    ["Administrator"]     = "class-a",
}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

function role_to_class(rank: number): ENUMS.Class
    local class: ENUMS.Class = RANK_TO_CLASS[rank]
    if class == nil then  
        class = "class-d"
    end
    return class
end

function permissions.player_has_perms(player: Player, perms: Folder): boolean
    local role  = player:GetAttribute("DEBUG_ROLE") or player:GetRoleInGroup(MAIN_GROUP_ID)
    local class = role_to_class(role)
    local approved = UTILS.get_by_path(perms, `{class}.Value`) :: boolean
    if approved then
        DEBUG.log(`Permission approved for {role} {player.Name}`)
    else
        DEBUG.log(`Permission denied for {role} {player.Name}`)
    end
    return approved
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return permissions
    
