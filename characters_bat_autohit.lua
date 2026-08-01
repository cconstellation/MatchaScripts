-- Workspace.Characters bat auto-hit (closest alive zombie)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Characters = game.Workspace:WaitForChild("Characters")

local function get_root(model)
	return model.PrimaryPart
		or model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("Torso")
		or model:FindFirstChildWhichIsA("BasePart")
end

local function is_player_character(model)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name == model.Name or player.Character == model then
			return true
		end
	end
	return false
end

local function is_alive(model)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end
	return humanoid.Health > 0
end

local function get_closest_zombie_character(my_character)
	local my_root = get_root(my_character)
	if not my_root then
		return nil
	end

	local closest, closest_dist = nil, math.huge

	for _, child in ipairs(Characters:GetChildren()) do
		if child ~= my_character and not is_player_character(child) and is_alive(child) then
			local root = get_root(child)
			if root then
				local dist = (my_root.Position - root.Position).Magnitude
				if dist < closest_dist then
					closest_dist = dist
					closest = child
				end
			end
		end
	end

	return closest
end

task.spawn(function()
	while true do
		local character = Characters:FindFirstChild(LocalPlayer.Name)
		if character and is_alive(character) then
			local bat = character:FindFirstChild("Bat")
			if bat then
				local swing = bat:FindFirstChild("Swing")
				local hit_targets = bat:FindFirstChild("HitTargets")
				local zombie_character = get_closest_zombie_character(character)

				if swing and hit_targets and zombie_character then
					swing:FireServer()
					hit_targets:FireServer({ zombie_character })
				end
			end
		end

		wait(0.1)
	end
end)
