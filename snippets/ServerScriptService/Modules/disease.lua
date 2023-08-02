--!strict

--[[
    Provides a base class used to simulate disease progression.
    Especially useful for disease-based SCPs like SCP-008.
--]]

local disease = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local REPL_STORE = game:GetService("ReplicatedStorage")
local RUN_SERV   = game:GetService("RunService")

-- modules
local REPL_MODS = require(REPL_STORE.modules)

-- constants
disease.PROGRESS_PER_SECOND = 1 
disease.EVENTS = {} :: {number: (Player) -> nil}

-- state
disease.name        = "generic disease"
disease.infected    = {} :: {Player: typeof(disease)}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- cures a player of the disease
function disease:cure(): ()
    REPL_MODS.debug.log(`{self.player} has been cured of {self.name}`)
    self.infected[self.player] = nil
end

-- increments progression every frame and calls any contained events
function disease:progress(delta_time: number): ()
    if self.progression > 100 or self.infected[self.player] == nil then return end
    self.progression += disease.PROGRESS_PER_SECOND * delta_time
    for prog, event in self.EVENTS do
        if self.progression < prog then continue end
        event(self.player)
        self.EVENTS[prog] = nil
        REPL_MODS.debug.log(`{disease.name} has reached a progression of {self.progression}% in {self.player}`)
    end
end

-- creates a new infection and associates it with a player
function disease:new(player: Player): ()
    local infection = table.clone(self)
    infection.EVENTS      = table.clone(self.EVENTS)
    infection.progression = 0
    infection.player      = player
    self.infected[player] = infection
    RUN_SERV.Heartbeat:Connect(function(delta) infection:progress(delta) end)
    player.CharacterRemoving:Connect(function() infection:cure() end)
    REPL_MODS.debug.log(`{player} has been infected with {self.name}`)
end

-- infects a player if they are not already infected
function disease:infect(player: Player): ()
    local infected = self.infected[player] ~= nil
    if infected then return end
    self:new(player)
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return disease
