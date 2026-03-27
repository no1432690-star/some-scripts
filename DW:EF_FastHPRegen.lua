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
    Smoothness = 0.1,
    Prediction = 0.1,
    AimPart = "Head",
    ShootAssist = true,
    ShowHP = true
}

--// FOV
local circle = Drawing.new("Circle")
circle.Visible = true
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.6

--// HP STORAGE
local HPText = {}

--// CREATE HP TEXT
local function setupHP(model)
    if HPText[model] then return end

    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 100, 0, 20)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = root

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.Parent = bill

    local function update()
        if hum.Health <= 0 then
            text.Text = "DEAD"
        else
            text.Text = math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)
        end
    end

    update()

    hum:GetPropertyChangedSignal("Health"):Connect(update)
    hum:GetPropertyChangedSignal("MaxHealth"):Connect(update)

    HPText[model] = bill
end

--// AUTO HP LOOP (FIX SPAWN)
task.spawn(function()
    while true do
        task.wait(1)

        if not Settings.ShowHP then continue end

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v ~= player.Character then
                local hum = v:FindFirstChildOfClass("Humanoid")
                local root = v:FindFirstChild("HumanoidRootPart")

                if hum and root then
                    setupHP(v)
                end
            end
        end
    end
end)

--// CLEANUP
RunService.RenderStepped:Connect(function()
    for model, gui in pairs(HPText) do
        if not model or not model.Parent then
            gui:Destroy()
            HPText[model] = nil
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
                local pos, visible = Camera:WorldToViewportPoint(part.Position)
                if visible then
                    local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(mouse.X,mouse.Y)).Magnitude
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
local gui = Instance.new("ScreenGui")
gui.Name = "AimGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(1, -220, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = gui

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -10, 0, 40)
toggle.Position = UDim2.new(0, 5, 0, 5)
toggle.Text = "Aim: ON"
toggle.TextScaled = true
toggle.Parent = frame

toggle.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    toggle.Text = Settings.Enabled and "Aim: ON" or "Aim: OFF"
end)

local hpToggle = Instance.new("TextButton")
hpToggle.Size = UDim2.new(1, -10, 0, 40)
hpToggle.Position = UDim2.new(0, 5, 0, 55)
hpToggle.Text = "HP: ON"
hpToggle.TextScaled = true
hpToggle.Parent = frame

hpToggle.MouseButton1Click:Connect(function()
    Settings.ShowHP = not Settings.ShowHP
    hpToggle.Text = Settings.ShowHP and "HP: ON" or "HP: OFF"

    if not Settings.ShowHP then
        for model, gui in pairs(HPText) do
            gui:Destroy()
            HPText[model] = nil
        end
    end
end)
