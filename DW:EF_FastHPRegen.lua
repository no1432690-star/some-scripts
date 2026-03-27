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
    ShowHP = true,
    MaxDistance = 150 -- 🔥 giới hạn khoảng cách
}

--// FOV
local circle = Drawing.new("Circle")
circle.Visible = true
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.6

--// CACHE
local Entities = {}
local HPText = {}

--// ADD ENTITY
local function registerEntity(v)
    if Entities[v] then return end

    local hum = v:FindFirstChildOfClass("Humanoid")
    local root = v:FindFirstChild("HumanoidRootPart")

    if hum and root then
        Entities[v] = {
            Hum = hum,
            Root = root
        }
    end
end

--// INITIAL SCAN (1 lần)
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Model") and v ~= player.Character then
        registerEntity(v)
    end
end

--// ADD NEW ENTITY (spawn)
workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Model") then
        task.delay(0.5, function()
            registerEntity(v)
        end)
    end
end)

--// HP SETUP
local function setupHP(model, data)
    if HPText[model] then return end

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 100, 0, 20)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = data.Root

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextColor3 = Color3.new(1,1,1)
    text.Parent = bill

    local function update()
        if data.Hum.Health <= 0 then
            text.Text = "DEAD"
        else
            text.Text = math.floor(data.Hum.Health).." / "..math.floor(data.Hum.MaxHealth)
        end
    end

    update()

    data.Hum:GetPropertyChangedSignal("Health"):Connect(update)

    HPText[model] = bill
end

--// HP LOOP (TỐI ƯU)
task.spawn(function()
    while true do
        task.wait(1.5) -- 🔥 giảm load

        if not Settings.ShowHP then continue end

        for model, data in pairs(Entities) do
            if model.Parent then
                local dist = (data.Root.Position - Camera.CFrame.Position).Magnitude
                if dist < Settings.MaxDistance then
                    setupHP(model, data)
                end
            end
        end
    end
end)

--// CLEANUP (NHẸ)
task.spawn(function()
    while true do
        task.wait(3)

        for model, gui in pairs(HPText) do
            if not model or not model.Parent then
                gui:Destroy()
                HPText[model] = nil
                Entities[model] = nil
            end
        end
    end
end)

--// TARGET
local function getTarget()
    local closest = nil
    local shortest = Settings.FOV

    for model, data in pairs(Entities) do
        if model.Parent then
            local dist3D = (data.Root.Position - Camera.CFrame.Position).Magnitude
            if dist3D < Settings.MaxDistance then
                local part = model:FindFirstChild(Settings.AimPart)
                if part then
                    local pos, visible = Camera:WorldToViewportPoint(part.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(mouse.X,mouse.Y)).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = model
                        end
                    end
                end
            end
        end
    end

    return closest
end

--// SHOOT
local shooting = false
UIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        shooting = true
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        shooting = false
    end
end)

--// AIM LOOP (GIỮ MƯỢT)
RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(mouse.X, mouse.Y)
    circle.Radius = Settings.FOV

    if not Settings.Enabled then return end
    if Settings.ShootAssist and not shooting then return end

    local target = getTarget()
    if target then
        local data = Entities[target]
        local part = target:FindFirstChild(Settings.AimPart)

        if part and data then
            local predicted = part.Position + data.Root.Velocity * Settings.Prediction
            local camPos = Camera.CFrame.Position
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(camPos, predicted),
                Settings.Smoothness
            )
        end
    end
end)
