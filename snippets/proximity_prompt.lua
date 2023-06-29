--!strict

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local PROXIMITY_PROMPT_SERVICE = game:GetService("ProximityPromptService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")

-- modules
local DEBUG = require(REPLICATED_STORAGE.debug)

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- fires when a proximity prompt is triggered
function on_prompt_triggered(prompt: ProximityPrompt, player: Player)
	local interaction_type = DEBUG.exists(
		prompt:FindFirstAncestorOfClass("Model"), 
		"config.interaction_type.Value"
	)
	local event = DEBUG.exists(REPLICATED_STORAGE, `bindable_events.interactions.{interaction_type}`)
	local bindings = DEBUG.exists(prompt:FindFirstAncestorOfClass("Model"), "bindings")
	for _, value_object in bindings:GetChildren() do
		if value_object:IsA("ObjectValue") then
			event:Fire(player, value_object.Value, prompt)
		end
	end
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

PROXIMITY_PROMPT_SERVICE.PromptTriggered:Connect(on_prompt_triggered)

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--
