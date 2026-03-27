-- =============================================
-- Decaying Winter: Eternal Fools - Fast HP Regen V3
-- SUPER DEBUG MODE - Liệt kê TẤT CẢ RemoteEvent
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local enabled = true
local connection = nil

local dealDamageRemote = nil
local serverKey = nil
local playerKey = nil

-- ================== SUPER FINDER (liệt kê tất cả remote) ==================
local function superFinder()
    print("🔍 [DW:EF V3] BẮT ĐẦU TÌM TẤT CẢ REMOTE...")
    
    local remotesFound = 0
    
    -- Tìm trong mọi nơi client có thể thấy
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            remotesFound = remotesFound + 1
            local fullPath = obj:GetFullName()
            print("📡 RemoteEvent #" .. remotesFound .. ": " .. fullPath)
            
            -- Tự động nhận remote nếu tên giống
            if fullPath:lower():find("dealdamage") or fullPath:lower():find("deal_damage") or 
               fullPath:lower():find("regen") or fullPath:lower():find("heal") or 
               fullPath:lower():find("damage") then
                dealDamageRemote = obj
                print("✅ TÌM THẤY REMOTE TỐT: " .. fullPath)
            end
        end
    end
    
    print("🔍 Tìm thấy tổng cộng " .. remotesFound .. " RemoteEvent.")
    
    -- Tìm key
    pcall(function()
        serverKey = _G.serverKey or _G.ServerKey or _G.key or _G.Key
        playerKey = _G.playerKey or _G.PlayerKey or _G.pkey or _G.PKey
    end)
    
    if serverKey and playerKey then
        print("✅ KEY TÌM THẤY: serverKey = " .. tostring(serverKey) .. " | playerKey = " .. tostring(playerKey))
    else
        print("⚠️ VẪN KHÔNG TÌM ĐƯỢC KEY")
    end
    
    if dealDamageRemote then
        print("🎯 SẼ DÙNG REMOTE: " .. dealDamageRemote:GetFullName())
    else
        print("❌ KHÔNG TÌM THẤY REMOTE DEALDAMAGE/REGEN NÀO")
    end
end

-- ================== GUI (giữ nguyên) ==================
local function createGUI()
    if player.PlayerGui:FindFirstChild("DW_FastHPRegenGUI") then
        player.PlayerGui.DW_FastHPRegenGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DW_FastHPRegenGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 90)
    frame.Position = UDim2.new(1, -260, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.1
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 1, -20)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    button.Text = "Fast HP Regen V3: ON\n(Debug Mode)"
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = enabled and "Fast HP Regen V3: ON\n(Debug Mode)" or "Fast HP Regen V3: OFF"
        button.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        print(enabled and "✅ V3: BẬT" or "❌ V3: TẮT")
    end)
end

-- ================== REGEN ==================
local function fastRegen()
    if not enabled then return end
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    local hum = character.Humanoid
    if hum.Health >= hum.MaxHealth then return end

    pcall(function()
        -- Dùng remote nếu tìm thấy
        if dealDamageRemote then
            for i = 1, 10 do
                if serverKey and playerKey then
                    dealDamageRemote:FireServer("Regeneration", nil, serverKey, playerKey)
                else
                    dealDamageRemote:FireServer("Regeneration")
                end
            end
        end
        -- Fallback client
        hum.Health = math.min(hum.MaxHealth, hum.Health + 200)
    end)
end

-- ================== CHẠY ==================
superFinder()
createGUI()

connection = RunService.Heartbeat:Connect(fastRegen)

player.CharacterAdded:Connect(function()
    task.wait(1)
    superFinder()
end)

print("🚀 V3 ĐÃ LOAD - DEBUG MODE")
print("   Mở F9 và paste TOÀN BỘ console cho mình nhé!")
