--!strict

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- types
type KeyObjs = {
    hitbox: Part
}

-- services
local PLAYERS     = game:GetService("Players")
local REPL_STORE  = game:GetService("ReplicatedStorage")
local SERV_SCRIPT = game:GetService("ServerScriptService")

-- modules
local MODS = require(REPL_STORE.modules)
local SERV_MODS = require(SERV_SCRIPT.modules)

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- returns a table of key objects for simple sampling
function get_key_objs(): KeyObjs
    return {
        hitbox = script.Parent.hitbox
    }
end

-- infects a player with 008
function infect(player: Player): ()
    SERV_MODS.scp_008:infect(player)
end

-- returns the player instance of a part's associated character, if possible
function get_player_from(part: BasePart): Player?
    for _, player in PLAYERS:GetChildren() do
        local char = MODS.utils.get_by_path(player, "Character") :: Model
        if char == nil then continue end
        if part:IsDescendantOf(char) then
            return player
        end
    end
    return nil
end

-- called when a part collides with the hitbox
function on_collision(part: BasePart): ()
    local player = get_player_from(part)
    if player == nil then return end
    infect(player)
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

get_key_objs().hitbox.Touched:Connect(on_collision)
