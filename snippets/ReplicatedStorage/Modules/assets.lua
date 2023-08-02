--!strict

local assets = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local REPL_STORE = game:GetService("ReplicatedStorage")

-- modules
local REPL_UTILS = require(script.Parent.utilities)
local REPL_DEBUG = require(script.Parent.debug)

-- constants
local ASSETS = REPL_STORE.assets

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- retrieves and returns a clone of an asset if found
function assets.get(name: string): Instance?
    local asset = REPL_UTILS.get_by_path(ASSETS, name) :: Instance?
    if asset then
        asset = asset:Clone()
    end
    return asset
end

-- retrieves and returns a clone of an asset if found. if not found, errors.
function assets.get_req(name: string): Instance
    local asset = assets.get(name)
    if not asset then
        REPL_DEBUG.err(`Missing required asset "{name}"`, ASSETS)
    end
    return asset :: Instance
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return assets
