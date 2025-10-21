-- [[ CODE ]] --
local map;
local coins;
local last_coin;

local players = game:GetService("Players");
local localplayer = players.LocalPlayer;

local camera = workspace.CurrentCamera;
local screen_size = camera.ViewportSize;

function draw(type)
    local new_draw = Drawing.new(type);
    new_draw.Transparency = 1;
    new_draw.Visible = true;

    return new_draw;
end;

function is_valid(obj)
    return obj and obj.Parent ~= nil;
end;

function magnitude(point1, point2)
    local dx = point2.X - point1.X;
    local dy = point2.Y - point1.Y;
    local dz = point2.Z - point1.Z;
    return math.sqrt(dx*dx + dy*dy + dz*dz);
end;

function get_closest_coin()
    local closest_coin = nil;
    local closest_distance = math.huge;

    local character = localplayer.Character;
    if not character then return nil, closest_distance end;

    local humanoidrootpart = character:FindFirstChild("HumanoidRootPart");
    if not humanoidrootpart then return nil, closest_distance end;

    local coin_container = map:FindFirstChild("CoinContainer");
    if not coin_container then return nil, closest_distance end; 

    for _, coin in next, coin_container:GetChildren() do
        if is_valid(coin) and coin:FindFirstChild("TouchInterest") and coin:FindFirstChild("CoinVisual") then
            local coin_distance = magnitude(coin.Position, humanoidrootpart.Position);
            if coin_distance < closest_distance then
                closest_coin = coin;
                closest_distance = coin_distance;
            end;
        end;
    end;

    return closest_coin, closest_distance;
end;

local can_tween = true;

function tween_position(object, target, duration)
    local start_time = os.clock();
    local start_pos = object.Position;
    local end_time = start_time + duration;
    can_tween = false;

    while os.clock() < end_time do
        if (not is_valid(object)) or (not is_valid(target) or (not is_valid(map))) then
            break;
        end;

        local alpha = (os.clock() - start_time) / duration;
        if alpha > 1 then alpha = 1 end;

        local tx, ty, tz = target.Position.X, target.Position.Y, target.Position.Z;
        local sx, sy, sz = start_pos.X, start_pos.Y, start_pos.Z;

        object.Position = Vector3.new(
            sx + (tx - sx) * alpha,
            sy + (ty - sy) * alpha,
            sz + (tz - sz) * alpha
        );
        object.Velocity = Vector3.new(0, 0, 0);
    end;

    can_tween = true;
    object.Position = target.Position;
end;

function set_noclip()
    local character = localplayer.Character;
    if character then
        for i, v in next, character:GetChildren() do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("BasePart") then
                v.CanCollide = false;
            end;
        end;
    end;
end;

local next_coin_line = draw("Line");
local status = draw("Text");
status.Center = true;

function update_auto_farm()
    screen_size = camera.ViewportSize;
    status.Position = Vector2.new(screen_size.X / 2, screen_size.X * 0.2);

    for _, v in next, workspace:GetChildren() do
        if v:FindFirstChild("Base") then
            map = v;
        end;
    end;

    if (not is_valid(coins)) then
        coins = localplayer.PlayerGui.MainGUI.Game.CoinBags.Container.Candy.CurrencyFrame.Icon.Coins
    end;

    local character = localplayer.Character;
    if character then
        local humanoidrootpart = character:FindFirstChild("HumanoidRootPart");
        if humanoidrootpart then
            if (last_coin) then
                local rootpos, on_screen = WorldToScreen(humanoidrootpart.Position);
                local coinpos, on_screen_coin = WorldToScreen(last_coin.Position);

                next_coin_line.From = rootpos;
                next_coin_line.To = coinpos;
                next_coin_line.Visible = on_screen and on_screen_coin;
            end;

            if (is_valid(map)) and coins.Text ~= "40" then
                local closest_coin, coin_distance = get_closest_coin();

                if is_valid(closest_coin) then
                    last_coin = closest_coin;
                    humanoidrootpart.Velocity = Vector3.new(0, 0, 0);
                    status.Text = "Auto Farming Status: Currently " .. coins.Text .. " Coins";

                    if (can_tween) then
                        spawn(function() 
                            tween_position(humanoidrootpart, closest_coin, coin_distance / tween_speed); 
                        end);
                    end;
                end;
            else
                if (coins.Text == "40") then
                    status.Text = "Auto Farm Status: Coin Full";
                else
                    status.Text = "Auto Farm Status: IDLE";
                end;

                humanoidrootpart.Velocity = Vector3.new(0, 0, 0);
                -- tween_position(humanoidrootpart, game.Workspace.Lobby.Map.zombieking.HumanoidRootPart, tween_duration);
                humanoidrootpart.Position = Vector3.new(-4981.51, 308.51, 3.79);

                
                next_coin_line.Visible = false;
            end;
        else
            status.Text = "Auto Farm Status: Can't find RootPart";
            next_coin_line.Visible = false;
        end;
    else
        status.Text = "Auto Farm Status: Can't find Character";
        next_coin_line.Visible = false;
    end;
end;

spawn(function()
    while true do
        set_noclip();
        wait(0.1);
    end;
end);

local _, err = pcall(function()
    while true do
        update_auto_farm();
    end;
end);

if err then
    error(err);
end;
