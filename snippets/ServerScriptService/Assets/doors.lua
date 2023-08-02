--!strict

--[[ 
	Responsible for responding to door events.
	Door events are most often invoked by interaction points like keycard scanners and buttons.
--]]

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- services
local COLL_SERV  = game:GetService("CollectionService")
local REPL_STORE = game:GetService("ReplicatedStorage")
local TWEEN_SERV = game:GetService("TweenService")

-- modules
local MODS  = require(REPL_STORE.modules)

-- constants
local TEMP_OPEN_DUR = 3
local MOVE_DUR = 1.5

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

type KeyInsts = {
    model: Model,
    parts: { 
        door: Part | MeshPart,
    },
    binds: {
        open_temp: Folder,
        open: Folder,
        close: Folder,
        lock: Folder,
    },
    events: {
        prompt_tog: BindableEvent,
    },
    attachs: {
        open: Attachment,
        closed: Attachment,
        door: Attachment,
    },
    sounds: {
        open: Sound,
        close: Sound,
        lock: Sound,
    },
}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

function is_open(model: Model): boolean
	return model:GetAttribute("state") == "open"
end

function is_closed(model: Model): boolean
	return model:GetAttribute("state") == "closed"
end

function is_locked(model: Model): boolean
	return model:GetAttribute("locked")
end

function get_key_insts(model: Model): KeyInsts
	return {
		model = model,
        parts = { 
            door = MODS.utils.get_by_path_req(model, "parts.door") :: MeshPart,
        },
        binds = {
            open_temp = MODS.utils.get_by_path_req(model, "bindings.open_temp") :: Folder,
            open      = MODS.utils.get_by_path_req(model, "bindings.open") :: Folder,
            close     = MODS.utils.get_by_path_req(model, "bindings.close") :: Folder,
            lock      = MODS.utils.get_by_path_req(model, "bindings.lock") :: Folder,
        },
        events = {
            prompt_tog = MODS.utils.get_by_path_req(model, "events.prompt_toggle") :: BindableEvent,
        },
        attachs = {
            open   = MODS.utils.get_by_path_req(model, "parts.frame.attach_open") :: Attachment,
            closed = MODS.utils.get_by_path_req(model, "parts.frame.attach_closed") :: Attachment,
            door   = MODS.utils.get_by_path_req(model, "parts.door.attach_door") :: Attachment,
        },
        sounds = {
            open  = MODS.utils.get_by_path_req(model, "parts.door.sound_open") :: Sound,
            close = MODS.utils.get_by_path_req(model, "parts.door.sound_close") :: Sound,
            lock  = MODS.utils.get_by_path_req(model, "parts.door.sound_lock") :: Sound,
        },
	}
end

function set_state(key_insts: KeyInsts, state: "open" | "active" | "closed")
    local cur_state = key_insts.model:GetAttribute("state")
    if state == "active" then
        key_insts.events.prompt_tog:Fire(false)
    else
        key_insts.events.prompt_tog:Fire(true)
    end
    key_insts.model:SetAttribute("state", state)
end

function get_attach_offset(key_insts: KeyInsts, attach: Attachment): Vector3
	local door_pos   = key_insts.attachs.door.WorldCFrame.Position
	local attach_pos = attach.WorldCFrame.Position
	return door_pos - attach_pos
end

function move_door_to(key_insts: KeyInsts, targ_pos: Vector3): ()
    set_state(key_insts, "active")
	local tween = TWEEN_SERV:Create(
		key_insts.parts.door,
		TweenInfo.new(MOVE_DUR, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        { CFrame = CFrame.new(targ_pos) * key_insts.parts.door.CFrame.Rotation }
	)
	tween:Play()
	tween.Completed:Wait()
end

function open(key_insts: KeyInsts, upd_state: boolean?): ()
	if is_closed(key_insts.model) and not is_locked(key_insts.model) then
		local offset = get_attach_offset(key_insts, key_insts.attachs.open)
        local targ_pos = key_insts.parts.door.Position - offset
        key_insts.sounds.open:Play()
        move_door_to(key_insts, targ_pos)
        MODS.debug.log(`Door {key_insts.model:GetAttribute("id")} opened`)
        if upd_state then
            set_state(key_insts, "open")
        end
	end
end

function close(key_insts: KeyInsts, upd_state: boolean): ()
	if is_open(key_insts.model) and not is_locked(key_insts.model) then
		local offset = get_attach_offset(key_insts, key_insts.attachs.closed)
        local targ_pos = key_insts.parts.door.Position - offset
        key_insts.sounds.close:Play()
		move_door_to(key_insts, targ_pos)
        key_insts.model:SetAttribute("state", "closed")
        MODS.debug.log(`Door {key_insts.model:GetAttribute("id")} closed`)
        if upd_state then
            set_state(key_insts, "closed")
        end
	end
end

function open_temp(key_insts: KeyInsts): ()
    open(key_insts, false)
    wait(TEMP_OPEN_DUR)
    key_insts.model:SetAttribute("state", "open")
    close(key_insts, true)
end

function lock(key_insts: KeyInsts): ()
    key_insts.model:SetAttribute("locked", true)
    key_insts.sounds.lock:Play()
    MODS.debug.log(`Door {key_insts.model:GetAttribute("id")} locked`)
end

function unlock(key_insts: KeyInsts): ()
    key_insts.model:SetAttribute("locked", false)
    key_insts.sounds.lock:Play()
    MODS.debug.log(`Door {key_insts.model:GetAttribute("id")} unlocked`)
end

function toggle_lock(key_insts: KeyInsts): ()
    local locked = key_insts.model:GetAttribute("locked")
    if locked then
        unlock(key_insts)
    else
        lock(key_insts)
    end
end

function set_up(): ()
	local doors = COLL_SERV:GetTagged("door")
	for id, door in doors do
        local key_insts = get_key_insts(door)
        MODS.utils.set_id(door, id)
        MODS.events.bind_folder(key_insts.binds.open_temp, function() open_temp(key_insts) end)
        MODS.events.bind_folder(key_insts.binds.open, function() open(key_insts, true) end)
        MODS.events.bind_folder(key_insts.binds.close, function() close(key_insts, true) end)
        MODS.events.bind_folder(key_insts.binds.lock, function() lock(key_insts) end)
	end
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

set_up()
