--!strict

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local REPL_STORE = game:GetService("ReplicatedStorage")
local RUN_SERV   = game:GetService("RunService")
local PLAYERS    = game:GetService("Players")

-- modules
local MODS = require(REPL_STORE.modules)

-- constants
local ATTACK_MOVE_SPEED = 50

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

function visible_to_player(player: Player, from: Vector3): boolean
    local visible = false
    local char = player.Character
    if not char then return false end
    local humanoid_root = MODS.utils.get_by_path_req(char, "HumanoidRootPart") :: Part
    local raycast_dir: Vector3 = humanoid_root.Position - from
    local raycast_res = workspace:Raycast(from, raycast_dir)
    local angle = math.deg(raycast_dir:Angle(-humanoid_root.CFrame.LookVector))
    visible = raycast_res.Instance:IsDescendantOf(char) and angle < 60
    return visible
end

function is_visible(from: Vector3): boolean
	local raycast_params = RaycastParams.new()
    raycast_params.FilterType = Enum.RaycastFilterType.Exclude
    local visible = false
	for _, player in PLAYERS:GetPlayers() do
		visible = visible_to_player(player, from)
    end
    return visible
end

function get_closest_player(origin: Vector3): Model?
    local closest_dist = math.huge
    local closest_char: Model? = nil
    for _, player in PLAYERS:GetPlayers() do
		local char = player.Character
        if char == nil then continue end
        local health = MODS.utils.get_by_path_req(char, "Humanoid.Health") :: number
        if (health <= 0) then continue end
        local char_pos = MODS.utils.get_by_path_req(char, "HumanoidRootPart.Position") :: Vector3
        local dist = (origin - char_pos).Magnitude
        local is_closest = dist < closest_dist
		if not is_closest then continue end
		closest_dist = dist
		closest_char = char
    end
    return closest_char
end

function upd_speed(humanoid: Humanoid, visible: boolean): ()
    humanoid.WalkSpeed = if visible then 0 else ATTACK_MOVE_SPEED
end

function move_towards(char: Model, humanoid: Humanoid): ()
    local char_pos = MODS.utils.get_by_path_req(char, "HumanoidRootPart.Position") :: Vector3
    humanoid:MoveTo(char_pos)
end

function try_kill(char: Model): ()
	local touching_parts = script.Parent.Torso:GetTouchingParts()
	for _, part in touching_parts do
        if not part:IsDescendantOf(char) then
			continue 
        end
        (MODS.utils.get_by_path(char, "Humanoid", true) :: Humanoid):TakeDamage(100)
	end
end

function update(): ()
    local humanoid = script.Parent.Humanoid
    local humanoid_root = script.Parent.HumanoidRootPart
	local visible = is_visible(humanoid_root.Position)
    upd_speed(humanoid, visible)
    if not visible then
        local char = get_closest_player(humanoid_root.Position)
        if char == nil then return end
        move_towards(char, humanoid)
        try_kill(char)
    end
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

RUN_SERV.Heartbeat:Connect(update)
