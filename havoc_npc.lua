local players = game:GetService("Players")
local registered = {}

local function is_player(model)
    for _, plr in players:GetPlayers() do
        if plr.Character == model or plr.Name == model.Name then
            return true
        end
    end
    return false
end

local function register_npc(model)
    local addr = model.Address
    if registered[addr] then return end
    if not model:FindFirstChild("HumanoidRootPart") then return end
    if is_player(model) then return end
    registered[addr] = RegisterModel({
        entry = model,
        ShouldDraw = function(m)
            return true
        end,
        GetDisplayName = function(m)
            return m.Name
        end,
        GetHealth = function(m)
            local hum = m:FindFirstChild("Humanoid")
            if hum then return hum.Health end
            return 100
        end,
        GetMaxHealth = function(m)
            local hum = m:FindFirstChild("Humanoid")
            if hum then return hum.MaxHealth end
            return 100
        end,
        GetTool = function(m)
            local tool = m:FindFirstChildOfClass("Tool")
            if tool then return tool.Name end
            return "None"
        end,
    })
    print("Registered: " .. model.Name)
end

local resolved_model_path
for i, v in next, workspace:GetChildren() do
    if v:FindFirstChild("NPCs") then
        resolved_model_path = v
    end
end

while true do
    for i, v in next, resolved_model_path:GetChildren() do
        if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then
            register_npc(v)
        end
    end
    wait(2)
end
