local Hitbox = {}

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local RD = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("External"):WaitForChild("RagdollModule"))

function Hitbox.CreateHitbox(player, damageAmount, duration, limb, ragdoll, ragdollForce, ragdollTime)
	local character = player.Character
	if not character then return end

	local dmgPoints = {}
	for _, part in ipairs(CollectionService:GetTagged("DmgPoint")) do
		if part:IsA("BasePart") and part:IsDescendantOf(character) and part.Name:find(limb) then
			--print("added hitbox for limb "..limb)
			table.insert(dmgPoints, part)
		end
	end

	if #dmgPoints == 0 then print("found 0 dmg points")return end

	local targetsHit = {}
	local timer = 0
	local connection

	connection = RunService.Heartbeat:Connect(function(dt)
		--print("in the connection")
		timer += dt
		if timer > duration then
			--print("disconnecting timer > duration")
			connection:Disconnect()
			return
		end
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {character}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		
		for _, dmgPart in ipairs(dmgPoints) do
			--print("looping dmg parts")

			local castDirection = dmgPart.CFrame.LookVector * 3 -- dont change ts number gng ts the raylength
			local blockCastResult = workspace:Blockcast(
				dmgPart.CFrame,
				dmgPart.Size,
				castDirection,
				raycastParams
			)

			local debugPart = Instance.new("Part")
			debugPart.Anchored = true
			debugPart.CanCollide = false
			debugPart.Transparency = 0.7
			debugPart.Material = Enum.Material.Neon
			debugPart.BrickColor = BrickColor.new("Bright green")
			debugPart.Size = dmgPart.Size
			debugPart.CFrame = dmgPart.CFrame * CFrame.new(0, 0, castDirection.Magnitude / 2)
			debugPart.Parent = workspace
			game:GetService("Debris"):AddItem(debugPart, 0.1)

			if blockCastResult then
				--print("got blockcast result")
				local hitPart = blockCastResult.Instance
				local targetCharacter = hitPart:FindFirstAncestorOfClass("Model")
				if targetCharacter and not targetsHit[targetCharacter] then
					--print("found target char and not hit before")
					local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid ~= character:FindFirstChildOfClass("Humanoid") and humanoid.Health > 0 then
						RD:RigCharacter(targetCharacter)
						--print("found humanoid and damaged")
						humanoid:TakeDamage(damageAmount)
						targetsHit[targetCharacter] = true
						
						local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
						local attackerHRP = character:FindFirstChild("HumanoidRootPart")
						
						local lookat = CFrame.lookAt(hrp.Position, Vector3.new(attackerHRP.Position.X, hrp.Position.Y, attackerHRP.Position.Z))
						local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						local tween = TweenService:Create(hrp, tweenInfo, {CFrame = lookat})
						tween:Play()
						tween.Completed:Wait()
						
						game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Combat"):WaitForChild("PlayHitFX"):FireAllClients(targetCharacter, ragdoll)
						
						if hrp and attackerHRP and ragdoll then
							print("ragdollin")
							local direction = (hrp.Position - attackerHRP.Position).Unit
							print("direction: ".. tostring(direction))

							local line = Instance.new("Part")
							line.Anchored = true
							line.CanCollide = false
							line.Material = Enum.Material.Neon
							line.BrickColor = BrickColor.new("Bright red")
							line.Size = Vector3.new(0.1, 0.1, (hrp.Position - attackerHRP.Position).Magnitude)
							line.CFrame = CFrame.new(attackerHRP.Position, hrp.Position) * CFrame.new(0, 0, -line.Size.Z / 2)
							line.Parent = workspace

							game:GetService("Debris"):AddItem(line, 2)

							RD:Ragdoll(targetCharacter, {Direction = direction, Strength = ragdollForce}, ragdollTime)

							print("ragdolled")
						else
							Hitbox.ApplyStun(targetCharacter, game:GetService("ReplicatedStorage"):WaitForChild("Animations"):WaitForChild("Global"):WaitForChild("Stun"))
						end
					end
				end
			end
		end
	end)
end

function Hitbox.ApplyStun(targetChar, stunAnim)
	print("stunning")
	local humanoid = targetChar:FindFirstChild("Humanoid")
	if not humanoid then return end

	if targetChar:GetAttribute("IsStunned") then return end
	targetChar:SetAttribute("IsStunned", true)
	
	local originalSpeed = humanoid.WalkSpeed
	local originalJump = humanoid.JumpPower

	humanoid.WalkSpeed = 2
	humanoid.JumpPower = 0

	local animator = humanoid:FindFirstChild("Animator")
	local duration
	if animator then
		print("Found animator")
		game:GetService("ContentProvider"):PreloadAsync({stunAnim})
		local track = animator:LoadAnimation(stunAnim)
		duration = track.Length
		track:Play()
	end
	
	print("delaying")
	task.delay(duration, function()
		if humanoid then
			humanoid.WalkSpeed = originalSpeed
			humanoid.JumpPower = originalJump
		end
		targetChar:SetAttribute("IsStunned", false)
	end)
end

return Hitbox
