-- =============================================
-- Decaying Winter: Eternal Fools - Fast HP Regen
-- Dành riêng cho game này (spam Regeneration Remote)
-- GUI bật/tắt + Anti-Detect
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local enabled = true
local connection = nil

local serverKey = nil
local playerKey = nil

-- ================== LẤY KEY (CẦN THIẾT CHO GAME) ==================
local function getKeys()
    -- Cách phổ biến trong Decaying Winter
    pcall(function()
        for _, v in ipairs(player.Backpack:GetChildren()) do
            if v:IsA("LocalScript") and v.Name == "Client" then
                v = v:Clone()
                v.Parent = player.PlayerGui
                local old = v.Disabled
                v.Disabled = false
                task.wait(0.1)
                serverKey = _G.serverKey or _G.ServerKey
                playerKey = _G.playerKey or _G.PlayerKey
                v:Destroy()
            end
        end
    end)
    
    if not serverKey or not playerKey then
        print("⚠️ Không lấy được key, thử reload script hoặc vào game lại!")
    else
        print("✅ Đã lấy serverKey & playerKey thành công!")
    end
end

-- ================== TẠO GUI ==================
local function createGUI()
    if player.PlayerGui:FindFirstChild("DW_FastHPRegenGUI") then
        player.PlayerGui:FindFirstChild("DW_FastHPRegenGUI"):Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DW_FastHPRegenGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 70)
    frame.Position = UDim2.new(1, -220, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.15
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 1, -20)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    button.Text = "Fast HP Regen: ON\n(Decaying Winter)"
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = button

    -- Click bật/tắt
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            button.Text = "Fast HP Regen: ON\n(Decaying Winter)"
            button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            print("✅ Fast HP Regen: BẬT (spam Regeneration)")
        else
            button.Text = "Fast HP Regen: OFF"
            button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            print("❌ Fast HP Regen: TẮT")
        end
    end)

    -- Kéo thả GUI
    local dragging = false
    local dragInput, mousePos, framePos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
        end
    end)

    button.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ================== FAST REGEN (Spam Regeneration) ==================
local function fastRegen()
    if not enabled or not serverKey or not playerKey then return end

    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end

    pcall(function()
        -- Spam Regeneration (mỗi frame ~5-8 lần, đủ nhanh nhưng không quá detect)
        for i = 1, 6 do
            game.Workspace.ServerStuff.dealDamage:FireServer("Regeneration", nil, serverKey, playerKey)
        end
        -- Backup client-side
        local hum = character.Humanoid
        if hum.Health < hum.MaxHealth then
            hum.Health = math.min(hum.MaxHealth, hum.Health + 150)
        end
    end)
end

-- ================== CHẠY SCRIPT ==================
getKeys()
createGUI()

-- Kết nối regen
connection = RunService.Heartbeat:Connect(fastRegen)

-- Respawn
player.CharacterAdded:Connect(function()
    task.wait(1)
    getKeys()
    if enabled then fastRegen() end
end)

print("✅ Decaying Winter Fast HP Regen đã load!")
print("   Click nút để bật/tắt | Hồi máu cực nhanh qua Regeneration")
print("   Nhấn lại script nếu key bị mất")
