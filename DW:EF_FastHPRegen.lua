--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--// SETTINGS
local Settings = {
    ShowHP = true,
    MaxDistance = 120,
    HideFullHP = false
}

--// STORAGE
local HPText = {}

--// CHECK PLAYER MODEL
local function isPlayerModel(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

--// COLOR BY HP %
local function getColor(percent)
    if percent > 0.6 then
        return Color3.fromRGB(0,255,0)
    elseif percent > 0.3 then
        return Color3.fromRGB(255,170,0)
    else
        return Color3.fromRGB(255,0,0)
    end
end

--// CREATE HP UI
local function setupHP(model)
    if HPText[model] then return end

    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return end
    if isPlayerModel(model) then return end -- bỏ player

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 100, 0, 20)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = root

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.Parent = bill

    local function update()
        if not Settings.ShowHP then
            bill.Enabled = false
            return
        end

        local dist = (root.Position - camera.CFrame.Position).Magnitude
        if dist > Settings.MaxDistance then
            bill.Enabled = false
            return
        end

        local percent = hum.Health / hum.MaxHealth

        if Settings.HideFullHP and percent >= 1 then
            bill.Enabled = false
            return
        end

        bill.Enabled = true

        if hum.Health <= 0 then
            text.Text = "DEAD"
            text.TextColor3 = Color3.fromRGB(255,0,0)
        else
            text.Text = math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)
            text.TextColor3 = getColor(percent)
        end
    end

    -- INIT
    update()

    -- REALTIME UPDATE
    hum:GetPropertyChangedSignal("Health"):Connect(update)
    hum:GetPropertyChangedSignal("MaxHealth"):Connect(update)

    -- CLEANUP
    hum.Died:Connect(function()
        text.Text = "DEAD"
    end)

    HPText[model] = bill
end

--// REGISTER
local function tryRegister(model)
    if not model:IsA("Model") then return end
    if model == player.Character then return end

    task.delay(0.3, function()
        if model.Parent then
            setupHP(model)
        end
    end)
end

--// INITIAL SCAN (1 lần)
for _, v in pairs(workspace:GetDescendants()) do
    tryRegister(v)
end

--// LISTEN SPAWN
workspace.DescendantAdded:Connect(function(v)
    tryRegister(v)
end)

--// LIGHT UPDATE LOOP (chỉ để check distance)
RunService.Heartbeat:Connect(function()
    for model, bill in pairs(HPText) do
        if not model or not model.Parent then
            bill:Destroy()
            HPText[model] = nil
        end
    end
end)

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HP_GUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 120)
frame.Position = UDim2.new(1, -200, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = gui

-- Toggle HP
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -10, 0, 30)
toggle.Position = UDim2.new(0, 5, 0, 5)
toggle.Text = "HP: ON"
toggle.TextScaled = true
toggle.Parent = frame

toggle.MouseButton1Click:Connect(function()
    Settings.ShowHP = not Settings.ShowHP
    toggle.Text = Settings.ShowHP and "HP: ON" or "HP: OFF"
end)

-- Toggle Hide Full HP
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(1, -10, 0, 30)
hideBtn.Position = UDim2.new(0, 5, 0, 40)
hideBtn.Text = "Hide Full: OFF"
hideBtn.TextScaled = true
hideBtn.Parent = frame

hideBtn.MouseButton1Click:Connect(function()
    Settings.HideFullHP = not Settings.HideFullHP
    hideBtn.Text = Settings.HideFullHP and "Hide Full: ON" or "Hide Full: OFF"
end)

-- Distance Info
local distLabel = Instance.new("TextLabel")
distLabel.Size = UDim2.new(1, -10, 0, 30)
distLabel.Position = UDim2.new(0, 5, 0, 75)
distLabel.Text = "Range: "..Settings.MaxDistance
distLabel.TextScaled = true
distLabel.BackgroundTransparency = 1
distLabel.Parent = frame

-- HOTKEY "]"
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightBracket then
        gui.Enabled = not gui.Enabled
    end
end)
