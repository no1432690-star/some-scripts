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
    Smoothness = 0.08, -- thấp = gần silent hơn
    Prediction = 0.1,
    AimPart = "Head",
    ShootAssist = true,
    ESP = true,
    ShowHP = true
}

--// DRAW FOV
local circle = Drawing.new("Circle")
circle.Visible = true
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.6

--// STORAGE
local ESPs = {}
local HPLabels = {}

--// CREATE HP LABEL
local function createHP(model)
    if HPLabels[model] then return end

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 100, 0, 20)
    bill.AlwaysOnTop = true

    local text = Instance.new("TextLabel", bill)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1,0,0)
    text.TextScaled = true

    HPLabels[model] = {Gui = bill, Text = text}
end

--// UPDATE HP
local function updateHP(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")

    if hum and root then
        createHP(model)

        local data = HPLabels[model]
        data.Gui.Parent = root
        data.Text.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
    end
end

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
                    updateHP(v)
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

--// AIM (CHỈ KHI BẮN)
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
