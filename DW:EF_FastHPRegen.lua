-- =============================================
-- Decaying Winter: Eternal Fools - Fast HP Regen V2
-- Tìm remote/key tự động + Debug + Fallback heal
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local enabled = true
local connection = nil

local serverKey = nil
local playerKey = nil
local dealDamageRemote = nil

-- ================== DEBUG & TÌM REMOTE/KEY TỰ ĐỘNG ==================
local function findStuff()
    print("🔍 [DW:EF V2] Đang tìm remote & key...")

    -- Tìm remote dealDamage (có thể nằm ở nhiều chỗ)
    if workspace:FindFirstChild("ServerStuff") and workspace.ServerStuff:FindFirstChild("dealDamage") then
        dealDamageRemote = workspace.ServerStuff.dealDamage
        print("✅ Remote dealDamage tìm thấy ở workspace.ServerStuff")
    else
        -- Tìm sâu hơn
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("damage") or obj.Name:lower():find("heal") or obj.Name:lower():find("regen")) then
                dealDamageRemote = obj
                print("✅ Remote tìm thấy: " .. obj:GetFullName())
                break
            end
        end
    end

    if not dealDamageRemote then
        print("⚠️ Không tìm thấy remote dealDamage/regen nào!")
    end

    -- Tìm key (nhiều cách)
    pcall(function()
        serverKey = _G.serverKey or _G.ServerKey or _G.key or nil
        playerKey = _G.playerKey or _G.PlayerKey or _G.pkey or nil

        -- Nếu không có trong _G, thử clone client script
        for _, v in ipairs(player.Backpack:GetChildren()) do
            if v:IsA("LocalScript") and (v.Name == "Client" or v.Name:find("Client")) then
                local clone = v:Clone()
                clone.Parent = player.PlayerGui
                clone.Disabled = false
                task.wait(0.2)
                serverKey = serverKey or _G.serverKey or _G.ServerKey
                playerKey = playerKey or _G.playerKey or _G.PlayerKey
                clone:Destroy()
            end
        end
    end)

    if serverKey and playerKey then
        print("✅ Key lấy thành công! serverKey = " .. tostring(serverKey) .. " | playerKey = " .. tostring(playerKey))
    else
        print("⚠️ Không lấy được key. Script sẽ dùng fallback client-side heal.")
    end
end

-- ================== TẠO GUI (giữ nguyên như cũ) ==================
local function createGUI()
    if player.PlayerGui:FindFirstChild("DW_FastHPRegenGUI") then
        player.PlayerGui.DW_FastHPRegenGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DW_FastHPRegenGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 80)
    frame.Position = UDim2.new(1, -240, 0, 20)
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
    button.Text = "Fast HP Regen V2: ON\n(Decaying Winter Eternal Fools)"
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = enabled and "Fast HP Regen V2: ON\n(Decaying Winter Eternal Fools)" or "Fast HP Regen V2: OFF"
        button.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        print(enabled and "✅ V2: BẬT" or "❌ V2: TẮT")
    end)

    -- Kéo thả GUI (giữ nguyên)
    local dragging, dragInput, mousePos, framePos
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ================== HỒI MÁU (V2) ==================
local function fastRegen()
    if not enabled then return end

    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end

    local hum = character.Humanoid
    if hum.Health >= hum.MaxHealth then return end

    pcall(function()
        -- 1. Spam remote nếu tìm thấy
        if dealDamageRemote then
            for i = 1, 8 do  -- spam mạnh hơn một chút
                if serverKey and playerKey then
                    dealDamageRemote:FireServer("Regeneration", nil, serverKey, playerKey)
                else
                    dealDamageRemote:FireServer("Regeneration")  -- thử không key
                end
            end
        end

        -- 2. Fallback client-side heal (luôn chạy)
        hum.Health = math.min(hum.MaxHealth, hum.Health + 150)
    end)
end

-- ================== CHẠY SCRIPT ==================
findStuff()
createGUI()

connection = RunService.Heartbeat:Connect(fastRegen)

player.CharacterAdded:Connect(function()
    task.wait(1.2)
    findStuff()
    if enabled then fastRegen() end
end)

print("🚀 Decaying Winter: Eternal Fools - Fast HP Regen V2 đã load!")
print("   Mở F9 (console) để xem debug. Nếu vẫn không heal → paste lại nội dung console cho mình nhé!")
