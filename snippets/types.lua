--!strict

local types = {}

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

-- Types
export type Department = "administration" | "research" | "medical" | "security" | "class-d"
export type PersonnelClass = "class-d" | "class-c" | "class-b" | "class-a" | "administrator"
export type DoorState = "open" | "closed" | "moving"

--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--x--

return types
