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
    Smoothness = 0.12,
    Prediction = 0.1,
    AimPart = "Head",
    TeamCheck = false,
    Holding = false,
    ESP = true
}

--// DRAW FOV
local circle = Drawing.new("Circle")
circle.Visible = true
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.7

--// ESP STORAGE
local ESPs = {}

--// CREATE ESP
local function createESP(model)
    if not Settings.ESP then return end
    if ESPs[model] then return end

    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Transparency = 0.8

    ESPs[model] = box
end

--// REMOVE ESP
local function removeESP(model)
    if ESPs[model] then
        ESPs[model]:Remove()
        ESPs[model] = nil
    end
end

--// UPDATE ESP
RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(mouse.X, mouse.Y)
    circle.Radius = Settings.FOV

    for model, box in pairs(ESPs) do
        if model and model:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(model.HumanoidRootPart.Position)
            if visible then
                box.Visible = true
                box.Size = Vector2.new(40, 60)
                box.Position = Vector2.new(pos.X - 20, pos.Y - 30)
            else
                box.Visible = false
            end
        else
            removeESP(model)
        end
    end
end)

--// INPUT
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.Holding = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.Holding = false
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
                createESP(v)

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

--// AIM
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled or not Settings.Holding then return end

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

--// GUI (DRAGGABLE + SLIDER)
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ProAimGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(1, -240, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local function createLabel(text, y)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.Text = text
    lbl.TextScaled = true
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,1)
end

local function createSlider(name, y, min, max, callback)
    createLabel(name, y)

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, -20, 0, 10)
    bar.Position = UDim2.new(0, 10, 0, y + 20)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local move
            move = UIS.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    local percent = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(percent,0,1,0)

                    local value = min + (max-min)*percent
                    callback(value)
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

-- Sliders
createSlider("FOV", 10, 50, 300, function(v)
    Settings.FOV = v
end)

createSlider("Smooth", 60, 0.05, 0.3, function(v)
    Settings.Smoothness = v
end)

createSlider("Prediction", 110, 0, 0.3, function(v)
    Settings.Prediction = v
end)

-- Toggle
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Position = UDim2.new(0, 10, 1, -40)
toggle.Text = "Toggle Aim"
toggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
toggle.TextScaled = true

toggle.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
end)
