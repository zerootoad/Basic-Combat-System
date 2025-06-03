local Combat = {}

local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

local CombatRemote = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Combat"):WaitForChild("AttackEvent")

function Combat.Start()
	UserInputService.InputBegan:Connect(Combat.OnInputBegan)
end

function Combat.OnInputBegan(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		CombatRemote:FireServer("light")
		--print("M1")
	elseif input.KeyCode == Enum.KeyCode.R then
		CombatRemote:FireServer("heavy")
		--print("R")
	elseif input.KeyCode == Enum.KeyCode.F then
		CombatRemote:FireServer("block")
		--print("F")
	end
end

return Combat
