--!strict

local events = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- modules
local DEBUG = require(script.Parent.debug)

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

function events.bind(obj_val: ObjectValue, lambda: (...any) -> ())
    if obj_val.Value and obj_val.Value:isA("BindableEvent") then
        (obj_val.Value :: BindableEvent).Event:Connect(lambda)
    else
        DEBUG.err("Binding incorrectly set up", obj_val)
    end
end

function events.bind_folder(folder: Folder, lambda: (...any) -> ())
    for _, child in folder:GetChildren() do
        if child:IsA("ObjectValue") then
            events.bind(child, lambda)
        else
            DEBUG.err(`Child of class {child.ClassName} in binding folder`, child)
        end
    end
end

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return events
