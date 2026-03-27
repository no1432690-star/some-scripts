-- =============================================
-- Decaying Winter: Eternal Fools - Fast HP Regen V4 (Template)
-- YÊU CẦU: Phải điền chính xác RemoteEvent vào cấu hình
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local enabled = false

-- =============================================
-- ⚙️ CẤU HÌNH REMOTE (BẠN PHẢI SỬA PHẦN NÀY)
-- =============================================
-- Ví dụ đường dẫn: game:GetService("ReplicatedStorage").Remotes.HealEvent
local healRemote = nil -- ĐIỀN ĐƯỜNG DẪN REMOTE VÀO ĐÂY SAU KHI DÙNG SIMPLESPY

-- Điền các tham số (arguments) mà game yêu cầu để hồi máu
local function fireHealRemote()
    if healRemote then
        pcall(function()
            -- THAY ĐỔI CÁC THAM SỐ TRONG NGOẶC CHO ĐÚNG VỚI GAME
            -- Ví dụ: healRemote:FireServer("Heal", 50, "SecretKey123")
            healRemote:FireServer() 
        end)
    end
end

-- =============================================
-- 🎨 TẠO GUI ĐƠN GIẢN & AN TOÀN
-- =============================================
local function createGUI()
    local guiName = "DW_FastHPRegenGUI_V4"
    if player.PlayerGui:FindFirstChild(guiName) then
        player.PlayerGui[guiName]:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = guiName
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 60)
    frame.Position = UDim2.new(1, -220, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 1, -10)
    button.Position = UDim2.new(0, 5, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    button.Text = "Regen: OFF"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            button.Text = "Regen: ON"
            button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            button.Text = "Regen: OFF"
            button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)
end

-- =============================================
-- ⚙️ VÒNG LẶP HỒI MÁU (SPAM REMOTE)
-- =============================================
-- Dùng task.spawn và vòng lặp while để dễ dàng kiểm soát tốc độ gửi,
-- tránh việc gửi quá nhanh bằng Heartbeat khiến game kick bạn vì spam.
task.spawn(function()
    while task.wait(0.2) do -- Tốc độ spam: 0.2 giây / lần (điều chỉnh nếu cần)
        if enabled then
            local character = player.Character
            if character then
                local hum = character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
                    -- Gọi hàm gửi Remote lên server
                    fireHealRemote()
                end
            end
        end
    end
end)

-- Khởi chạy
createGUI()
print("🚀 Đã tải V4 Template. Nhớ cập nhật RemoteEvent trong script!")
