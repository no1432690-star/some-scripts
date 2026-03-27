--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local mouse = player:GetMouse()

--// SETTINGS
local Settings = {
    Enabled = true,
    FOV = 120,
    Smoothness = 0.08,
    Prediction = 0.1,
    AimPart = "Head",
    ShootAssist = true,
    ShowHP = true,
    ESP = true
}

--// FOV CIRCLE
local circle = Drawing.new("Circle")
circle.Visible = true
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.6

--// STORAGE
local HPUI = {}

--// COLOR BY HP
local function getHPColor(percent)
    if percent > 0.6 then
        return Color3.fromRGB(0,255,0)
    elseif percent > 0.3 then
        return Color3.fromRGB(255,170,0)
    else
        return Color3.fromRGB(255,0,0)
    end
end

--// CREATE HP BAR
local function setupHP(model)
    if HPUI[model] then return end

    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- Billboard
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 120, 0, 30)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    bill.Parent = root

    -- Background bar
    local bg = Instance.new("Frame", bill)
    bg.Size = UDim2.new(1,0,0.4,0)
    bg.Position = UDim2.new(0,0,0.3,0)
    bg.BackgroundColor3 = Color3.fromRGB(40,40,40)

    -- HP fill
    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new(1,0,1,0)

    -- Text
    local text = Instance.new("TextLabel", bill)
    text.Size = UDim2.new(1,0,0.5,0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextColor3 = Color3.new(1,1,1)

    local function update()
        if hum.Health <= 0 then
            text.Text = "DEAD"
            fill.Size = UDim2.new(0,0,1,0)
            return
        end

        local percent = hum.Health / hum.MaxHealth
        fill.Size = UDim2.new(percent,0,1,0)
        fill.BackgroundColor3 = getHPColor(percent)
        text.Text = math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)
    end

    update()

    hum:GetPropertyChangedSignal("Health"):Connect(update)
    hum:GetPropertyChangedSignal("MaxHealth"):Connect(update)

    HPUI[model] = bill
end

--// CLEANUP
RunService.RenderStepped:Connect(function()
    for model, gui in pairs(HPUI) do
        if not model or not model.Parent then
            gui:Destroy()
            HPUI[model] = nil
        end
    end
end)

--// TARGET
local function getTarget()
    local closest = nil
    local shortest = Settings.FOV

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= player.Character then
            local part = v:FindFirstChild(Settings.AimPart)
            local root = v:FindFirstChild("HumanoidRootPart")

            if part and root then
                if Settings.ShowHP then
                    setupHP(v)
                end

                local pos, visible = Camera:WorldToViewportPoint(part.Position)
                if visible then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = v
                    end
                end
            end
        end
    end

    return closest
end

--// SHOOT DETECT
local shooting = false
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        shooting = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        shooting = false
    end
end)

--// AIM LOOP
RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(mouse.X, mouse.Y)
    circle.Radius = Settings.FOV

    if not Settings.Enabled then return end
    if Settings.ShootAssist and not shooting then return end

    local target = getTarget()
    if target then
        local part = target:FindFirstChild(Settings.AimPart)
        local root = target:FindFirstChild("HumanoidRootPart")

        if part and root then
            local velocity = root.Velocity * Settings.Prediction
            local predicted = part.Position + velocity

            local camPos = Camera.CFrame.Position
            local aimCF = CFrame.new(camPos, predicted)

            Camera.CFrame = Camera.CFrame:Lerp(aimCF, Settings.Smoothness)
        end
    end
end)

--// GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ProAimUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 200)
frame.Position = UDim2.new(1, -240, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local function createSlider(name, y, min, max, callback)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.Position = UDim2.new(0,0,0,y)
    lbl.Text = name
    lbl.TextScaled = true
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,1)

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1,-20,0,10)
    bar.Position = UDim2.new(0,10,0,y+20)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0.5,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local move
            move = UIS.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    local percent = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    fill.Size = UDim2.new(percent,0,1,0)
                    callback(min + (max-min)*percent)
                end
            end)

            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    move:Disconnect()
                end
            end)
        end
    end)
end

createSlider("FOV", 10, 50, 300, function(v) Settings.FOV = v end)
createSlider("Smooth", 60, 0.05, 0.3, function(v) Settings.Smoothness = v end)
createSlider("Prediction", 110, 0, 0.3, function(v) Settings.Prediction = v end)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1,-20,0,30)
toggle.Position = UDim2.new(0,10,1,-40)
toggle.Text = "Toggle Aim"
toggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
toggle.TextScaled = true

toggle.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
end)
