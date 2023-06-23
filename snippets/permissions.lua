--!strict

local permissions = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

--[[
The permissions module provides a single function that checks if a player is permitted to use
something. The permissions system itself is two-fold: 
    1. categorical department validation
    2. hierarchical personnel class validation
If both of these validation checks are passed, the function returns true.
--]]

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local TEAMS = game:GetService("Teams")

-- modules
local DEBUG = require(REPLICATED_STORAGE.debug)
local TYPES = require(REPLICATED_STORAGE.types)

-- constants
local MAIN_GROUP_ID = 4373288
local PERSONNEL_CLASS_ORDER: {TYPES.PersonnelClass} = 
	{ "class-d", "class-c", "class-b", "class-a", "administrator" }

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- performs conversation from department enums to department group ids
local function department_into_group_id(department: TYPES.Department): number?
	return
		if department == "administration" then 4904749
		elseif department == "research" then 4373370
		elseif department == "medical" then 4906342
		elseif department == "security" then 4906376
		else nil
end

-- performs conversion from main group roles into personnel class enums
local function main_group_role_into_personnel_class(main_group_role: string): TYPES.PersonnelClass
	return
		if main_group_role == "Class-C Personnel" then "class-c"
		elseif main_group_role == "Class-B Personnel" then "class-b"
		elseif main_group_role == "Class-A Personnel" then "class-a"
		elseif main_group_role == "Administrator" then "administrator"
		else "class-d"
end

-- performs conversation from team names into department enums
local function team_name_into_department(team_name: string?): TYPES.Department
	return 
		if team_name == "Administration Department" then "administration"
		elseif team_name == "Research Department" then "research"
		elseif team_name == "Medical Department" then "medical"
		elseif team_name == "Security Department" then "security"
		else "class-d"
end

-- gets a player's personnel class.
local function get_player_personnel_class(player: Player): TYPES.PersonnelClass
	local main_group_role = player:GetRoleInGroup(MAIN_GROUP_ID)
	return DEBUG.debug_value(
		player:GetAttribute("debug_personnel_class"), 
		main_group_role_into_personnel_class(main_group_role)
	)
end

-- performs conversion from permissions config folders into a table of permissions
local function permissions_config_into_permissions_table(permissions_config: Configuration): {[TYPES.Department] : TYPES.PersonnelClass}
	local permissions_table: {[TYPES.Department] : TYPES.PersonnelClass} = {}
	for _, child in permissions_config:GetChildren() do
		if child:IsA("StringValue") then
			local department: TYPES.Department = child.Name :: TYPES.Department
			local personnel_class: TYPES.PersonnelClass = child.Value :: TYPES.PersonnelClass
			permissions_table[department] = personnel_class
		end
	end
	return permissions_table
end

-- returns whether a player is a member of a department's associated group.
local function player_in_department(player: Player, department: TYPES.Department): boolean
	local player_in_department
	local department_group_id = department_into_group_id(department)
	if department_group_id == nil then 
		player_in_department = true 
	else
		player_in_department = player:IsInGroup(department_group_id)
	end
	return DEBUG.debug_value(
		player:GetAttribute("debug_department_membership"), 
		player_in_department
	)
end

-- returns whether a personnel class is hierarchically superior to a threshold personnel class
local function personnel_class_above_threshold(compared_personnel_class: TYPES.PersonnelClass, min_personnel_class: TYPES.PersonnelClass): boolean
	for _, personnel_class: TYPES.PersonnelClass in PERSONNEL_CLASS_ORDER do
		if personnel_class == min_personnel_class then
			return true
		elseif personnel_class == compared_personnel_class then
			return false
		end
	end
	return false
end

-- returns whether a player has a personnel class above the minimum personnel class.
local function player_personnel_class_above_threshold(player: Player, threshold_personnel_class: TYPES.PersonnelClass): boolean
	local player_personnel_class: TYPES.PersonnelClass = get_player_personnel_class(player)
	return personnel_class_above_threshold(player_personnel_class, threshold_personnel_class)
end

-- returns whether a player has sufficient clearance to access.
function permissions.player_has_permission(player: Player, permissions_config: Configuration): boolean
	local team_name = if player.Team == nil then nil else player.Team.Name
	local department: TYPES.Department = team_name_into_department(team_name)
	local permissions_table = permissions_config_into_permissions_table(permissions_config)
	local player_has_permission = 
		player_personnel_class_above_threshold(player, permissions_table[department])
		and player_in_department(player, department)
	DEBUG.log(
		if player_has_permission then `{player.Name} has permission.` 
			else `{player.Name} does not have permission.`
	)
	return 
		player_has_permission
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return permissions
