local CollectionService = game:GetService("CollectionService")
local RD = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("External"):WaitForChild("RagdollModule"))

local LIMB_HITBOX_SIZES = {
	["Left Arm"] = {Size = Vector3.new(1.3, 1.5, 1.3), Offset = CFrame.new(0, -0.5, 0)},
	["Right Arm"] = {Size = Vector3.new(1.3, 1.5, 1.3), Offset = CFrame.new(0, -0.5, 0)},
	["Left Leg"] = {Size = Vector3.new(1.3, 1.5, 1.3), Offset = CFrame.new(0, -0.5, 0)},
	["Right Leg"] = {Size = Vector3.new(1.3, 1.5, 1.3), Offset = CFrame.new(0, -0.5, 0)}
}

local LIMBS = {"Left Arm", "Right Arm", "Left Leg", "Right Leg"}

local function createHitbox(parent, name, size, color)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Anchored = false
	part.CanCollide = false
	part.Massless = true
	part.BrickColor = BrickColor.new(color or "Bright blue")
	part.Material = Enum.Material.Neon
	part.Transparency = 0.7
	part.Parent = parent

	part.CanQuery = false
	part.CanTouch = false

	return part
end

local function attachHitboxes(character)
	for _, child in ipairs(character:GetChildren()) do
		if child.Name:match("_Hitbox$") then
			child:Destroy()
		end
	end

	for _, limbName in ipairs(LIMBS) do
		local limb = character:FindFirstChild(limbName)
		if limb and limb:IsA("BasePart") then
			local hitboxData = LIMB_HITBOX_SIZES[limbName]
			local hitbox = createHitbox(character, limbName.."_Hitbox", hitboxData.Size, "Bright yellow")
			CollectionService:AddTag(hitbox, "DmgPoint")

			local weld = Instance.new("Weld")
			weld.Part0 = limb
			weld.Part1 = hitbox
			weld.Parent = hitbox
			weld.C0 = hitboxData.Offset
		end
	end
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	RD:RigCharacter(character)

	local conn

	conn = humanoid.Died:Connect(function()
		for _, child in ipairs(character:GetChildren()) do
			if child.Name:match("_Hitbox$") then
				child:Destroy()
			end
		end
		conn:Disconnect()
	end)

	attachHitboxes(character)
end

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end
end)

for _, player in ipairs(game.Players:GetPlayers()) do
	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end
end
