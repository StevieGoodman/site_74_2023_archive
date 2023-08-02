--!strict

--[[ 
	Responsible for responding to button interactions.
	Button interactions are controlled by ProximityPrompts in the button's part hierarchy.
--]]

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local COLL_SERV  = game:GetService("CollectionService")
local REPL_STORE = game:GetService("ReplicatedStorage")

-- modules
local MODS = require(REPL_STORE.modules)

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

type KeyInsts = {
    model: Model,
    events: {
        press: BindableEvent
    },
    binds: {
        prompt_tog: Folder
    },
    sounds: {
        press: Sound
    },
    misc: {
        prompt: ProximityPrompt
    },
}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

function get_key_insts(model: Model): KeyInsts
	return {
        model = model,
        events = {
            press = MODS.utils.get_by_path_req(model, "events.press") :: BindableEvent,
        },
        binds = {
            prompt_tog = MODS.utils.get_by_path_req(model, "bindings.prompt_toggle") :: Folder  
        },
        sounds = {
            press = MODS.utils.get_by_path_req(model, "parts.button.sound_press") :: Sound,
        },
        misc = {
            prompt = MODS.utils.get_by_path_req(model, "parts.button.attach_prompt.prompt") :: ProximityPrompt,
        },
	}
end

function on_interact(key_insts: KeyInsts, player: Player): ()
    MODS.debug.log(`Button {MODS.utils.get_id(key_insts.model)} used by {player.Name}`)
    key_insts.sounds.press:Play()
    key_insts.sounds.press.Ended:Wait()
    key_insts.events.press:Fire()
end

function on_prompt_toggle(key_insts: KeyInsts, enable: boolean): ()
    key_insts.misc.prompt.Enabled = enable
end

function set_up(): ()
    local buttons = COLL_SERV:GetTagged("button")
	for id, button in buttons do
        local key_insts = get_key_insts(button)
        MODS.utils.set_id(button, id)
        key_insts.misc.prompt.Triggered:Connect(function(player: Player) on_interact(key_insts, player) end)
        MODS.events.bind_folder(key_insts.binds.prompt_tog, function(enable: boolean) on_prompt_toggle(key_insts, enable) end)
	end
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

set_up()
