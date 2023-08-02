--!strict

--[[ 
	Responsible for responding to keycard scanner interactions.
	Keycard scanner interactions are controlled by ProximityPrompts in the scanner's part hierarchy.
--]]

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local COLL_SERV  = game:GetService("CollectionService")
local REPL_STORE = game:GetService("ReplicatedStorage")

-- modules
local MODS  = require(REPL_STORE.modules)

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

type KeyInsts = {
    model: Model,
    events: {
        scan: BindableEvent,
    },
    binds: {
        prompt_tog: Folder,
    },
    sounds: {
        approve: Sound,
        deny: Sound,
    },
    misc: {
        prompt: ProximityPrompt,
    },
    config: {
        perms: Folder
    }
}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

function get_key_insts(model: Model): KeyInsts
	return {
        model = model,
        events = {
            scan = MODS.utils.get_by_path_req(model, "events.scan") :: BindableEvent,
        },
        binds = {
            prompt_tog = MODS.utils.get_by_path_req(model, "bindings.prompt_toggle") :: Folder,
        },
        sounds = {
            approve = MODS.utils.get_by_path_req(model, "parts.contact.sound_approve") :: Sound,
            deny    = MODS.utils.get_by_path_req(model, "parts.contact.sound_deny") :: Sound,
        },
        misc = {
            prompt = MODS.utils.get_by_path_req(model, "parts.contact.attach_prompt.prompt") :: ProximityPrompt,
        },
        config = {
            perms = MODS.utils.get_by_path_req(model, "config.perms") :: Folder,
        },
	}
end

function on_interact(key_insts: KeyInsts, player: Player): ()
    local valid = MODS.perms.player_has_perms(player, key_insts.config.perms)
    if valid then
        MODS.debug.log(`Keycard scanner {MODS.utils.get_id(key_insts.model)} used successfully by {player.Name}`)
        key_insts.sounds.approve:Play()
        key_insts.sounds.approve.Ended:Wait()
        key_insts.events.scan:Fire()
    else
        MODS.debug.log(`Keycard scanner {MODS.utils.get_id(key_insts.model)} used unsuccessfully by {player.Name}`)
        key_insts.sounds.deny:Play()
        key_insts.sounds.deny.Ended:Wait()
    end
end

function on_prompt_toggle(key_insts: KeyInsts, enable: boolean): ()
    key_insts.misc.prompt.Enabled = enable
end

function set_up(): ()
    local scanners = COLL_SERV:GetTagged("keycard_scanner")
    for id, scanner in scanners do
        local key_insts = get_key_insts(scanner)
        MODS.utils.set_id(scanner, id)
        key_insts.misc.prompt.Triggered:Connect(function(player: Player) on_interact(key_insts, player) end)
        MODS.events.bind_folder(key_insts.binds.prompt_tog, function(enable: boolean) on_prompt_toggle(key_insts, enable) end)
	end
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

set_up()
