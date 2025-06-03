local CombatRemote = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Combat"):WaitForChild("AttackEvent")
local PlaySwishFX = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Combat"):WaitForChild("PlaySwishFX")

local SCH = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("External"):WaitForChild("shapecasthitbox"))
local HB = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Handlers"):WaitForChild("Hitbox"))

local CombatAnims = game:GetService("ReplicatedStorage"):WaitForChild("Animations"):WaitForChild("Combat") 
animations = {
	mixed = {
		idle = CombatAnims:WaitForChild("Mixed"):WaitForChild("Idle"), 
		light1 = CombatAnims:WaitForChild("Mixed"):WaitForChild("Light1"), 
		light2 = CombatAnims:WaitForChild("Mixed"):WaitForChild("Light2"), 
		light3 = CombatAnims:WaitForChild("Mixed"):WaitForChild("Light3"), 
		light4 = CombatAnims:WaitForChild("Mixed"):WaitForChild("Light4"), 
		heavy = CombatAnims:WaitForChild("Mixed"):WaitForChild("Heavy")
	}
}

for _, animSet in pairs(animations) do
	for _, anim in pairs(animSet) do
		game:GetService("ContentProvider"):PreloadAsync({anim})
	end
end

local function playCombatAnimation(char, style, animType, comboIndex)
	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return nil, nil end

	local animator = humanoid:FindFirstChild("Animator") or humanoid:WaitForChild("Animator")
	local styleAnims = animations[style:lower()]
	if not styleAnims then return nil, nil end

	local anim
	local heavy = false
	if animType == "light" then
		anim = styleAnims["light" .. comboIndex]
	elseif animType == "heavy" then
		anim = styleAnims["heavy"]
		heavy = true
	end
	
	local track, hitbox
	local hitbox = anim:GetAttribute("HitboxLimb")
	if anim then
		track = animator:LoadAnimation(anim)
		
		PlaySwishFX:FireAllClients(char, heavy)
		track:Play()
		--print(track.Length)
		return track, hitbox
	end
	
	return nil, nil
end

function CreateCooldown(track, char, time, attr)
	task.spawn(function()
		track.Stopped:Wait()
		task.wait(time)
		char:SetAttribute(attr, true)
	end)
end

function FreezeCharacter(humanoid, duration)
	if not humanoid then return end
	if humanoid.Parent:GetAttribute("Frozen") then return end

	local originalSpeed = humanoid.WalkSpeed
	local originalJump = humanoid.JumpPower
	
	print("Froze humanoid")
	humanoid.Parent:SetAttribute("Frozen", true)

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	task.delay(duration, function()
		if humanoid then
			print("Unfrozen humanoid")
			humanoid.WalkSpeed = originalSpeed
			humanoid.JumpPower = originalJump
			humanoid.Parent:SetAttribute("Frozen", false)
		end
	end)
end


CombatRemote.OnServerEvent:Connect(function(player, type)
	local char = player.Character
	if not char then return end
	
	local hum = char:FindFirstChild("Humanoid")
	local combatStyle = char:GetAttribute("CombatStyle") or "Mixed"
	local combo = char:GetAttribute("Combo") or 0
	local lastComboTime = char:GetAttribute("LastComboTime") or 0
	local now = tick()

	local COMBO_RESET_TIME = 1.2
	if now - lastComboTime > COMBO_RESET_TIME then
		combo = 0
	end
	
	local track, limb
	if type == "light" then
		if char:GetAttribute("CanLightAttack") == false then return end
		char:SetAttribute("CanLightAttack", false)
		
		combo += 1
		char:SetAttribute("Combo", combo)
		char:SetAttribute("LastComboTime", now)

		track, limb = playCombatAnimation(char, combatStyle, "light", combo)
		
		local cdTime = 0
		local ragdoll = false
		if combo >= 4 then
			char:SetAttribute("Combo", 0)
			cdTime = 1
			ragdoll = true
		end
		
		if track and limb then
			local animLength = track.Length
			HB.CreateHitbox(player, 5, animLength, limb, ragdoll, 30, 2)
			CreateCooldown(track, char, cdTime, "CanLightAttack")
			FreezeCharacter(hum, 1.5)
		end
	elseif type == "heavy" then
		if char:GetAttribute("CanHeavyAttack") == false then return end
		char:SetAttribute("CanHeavyAttack", false)
		
		char:SetAttribute("Combo", 0)
		track, limb = playCombatAnimation(char, combatStyle, "heavy")

		if track and limb then
			local animLength = track.Length
			HB.CreateHitbox(player, 15, animLength, limb, true, 45, 4)
			CreateCooldown(track, char, 3, "CanHeavyAttack")
			FreezeCharacter(hum, 1.5)
		end
	end
end)

