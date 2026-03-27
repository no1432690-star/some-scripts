-- =============================================
-- Fast HP Regen Universal + GUI + Anti-Detect
-- Hồi +100 HP mỗi frame
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local enabled = true
local connection = nil

-- ================== TẠO GUI ĐƠN GIẢN ==================
local function createGUI()
    -- Xóa GUI cũ nếu có (tránh chồng khi reload)
    if player:FindFirstChild("PlayerGui"):FindFirstChild("FastHPRegenGUI") then
        player:FindFirstChild("PlayerGui"):FindFirstChild("FastHPRegenGUI"):Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FastHPRegenGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 60)
    frame.Position = UDim2.new(1, -200, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.2
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 1, -20)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    button.Text = "Fast HP Regen: ON"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = button

    -- Làm GUI có thể kéo thả
    local dragging = false
    local dragInput, mousePos, framePos

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            button.Text = "Fast HP Regen: ON"
            button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            print("✅ Fast HP Regen: BẬT")
        else
            button.Text = "Fast HP Regen: OFF"
            button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
            print("❌ Fast HP Regen: TẮT")
        end
    end)

    -- Kéo thả GUI
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
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ================== HÀM HỒI MÁU ==================
local function regenerateHealth()
    if not enabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth then
        pcall(function()  -- Anti-detect: dùng pcall
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 100)
        end)
    end
end

-- ================== CHẠY SCRIPT ==================
createGUI()

-- Kết nối regen với Heartbeat + random nhỏ (chống detect)
connection = RunService.Heartbeat:Connect(function()
    if enabled then
        regenerateHealth()
        task.wait(math.random(1, 10) / 1000)  -- random 0-0.01s
    end
end)

-- Tự động regen khi respawn
player.CharacterAdded:Connect(function()
    task.wait(0.3)
    if enabled then
        regenerateHealth()
    end
end)

print("✅ Fast HP Regen Universal + GUI đã load thành công!")
print("   Click nút để bật/tắt | +100 HP mỗi frame")
