local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local PlayHitFX = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Combat"):WaitForChild("PlayHitFX")
local PLaySwishFX = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Combat"):WaitForChild("PlaySwishFX")
local fxFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("FX")
local soundFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Sounds")

local sounds = {
	SwingLight= soundFolder:WaitForChild("SwingLight"),
	SwingHeavy = soundFolder:WaitForChild("SwingHeavy"),
	Light1Punch = soundFolder:WaitForChild("Light1Punch"),
	Light2Punch = soundFolder:WaitForChild("Light2Punch"),
	HeavyPunch = soundFolder:WaitForChild("HeavyPunch")
}

PlayHitFX.OnClientEvent:Connect(function(target, heavy)
	print("connected to event for fx")

	if not target or not target:IsDescendantOf(workspace) then return end
	local hrp = target:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local fxTemplate = fxFolder:WaitForChild("PunchLight")
	if heavy then
		fxTemplate = fxFolder:WaitForChild("PunchHeavy")
	end
	if fxTemplate then
		print("playing vfx")
		local fxPart = fxTemplate:Clone()
		fxPart.CFrame = hrp.CFrame
		fxPart.Parent = workspace
		fxPart.CanCollide = false
		fxPart.Anchored = false
		fxPart.CanCollide = false
		fxPart.Massless = true
		fxPart.CanQuery = false
		fxPart.CanTouch = false
		
		local actFx = fxPart:WaitForChild("Hit")
		if actFx:IsA("ParticleEmitter") then
			actFx:Emit(1)
		elseif actFx:FindFirstChildOfClass("ParticleEmitter") then
			local emitter = actFx:FindFirstChildOfClass("ParticleEmitter")
			emitter:Emit(1)
		end
		game.Debris:AddItem(fxPart, 2)
	end

	local sound
	if heavy then
		sound = sounds.HeavyPunch
	else
		local rand = math.random(1, 2)
		sound = rand == 1 and sounds.Light1Punch or sounds.Light2Punch
	end

	if sound then
		print("playing sound")
		local cloned = sound:Clone()
		cloned.Parent = hrp
		cloned:Play()
		game.Debris:AddItem(cloned, 3)
	end
end)

PLaySwishFX.OnClientEvent:Connect(function(char, heavy)
	local sound = sounds.SwingLight
	if heavy then
		sound = sounds.SwingHeavy
	end

	if sound then
		print("playing sound")
		local cloned = sound:Clone()
		cloned.Parent = char
		cloned:Play()
		game.Debris:AddItem(cloned, 3)
	end
end)

