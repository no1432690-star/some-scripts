-- =============================================
-- Fast HP Regen Universal Script
-- Hoạt động trên mọi game Roblox
-- Dành cho Executor (Synapse, Fluxus, Solara, v.v.)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local enabled = true  -- Bạn có thể thay thành false để tắt script sau này

local function regenerateHealth()
    if not enabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        -- Fast regen: Set full HP mỗi frame (rất nhanh)
        humanoid.Health = humanoid.MaxHealth
    end
end

-- Kết nối với Heartbeat để regen siêu nhanh
local connection = RunService.Heartbeat:Connect(regenerateHealth)

-- Tự động regen khi nhân vật respawn
player.CharacterAdded:Connect(function()
    task.wait(0.2)  -- Chờ humanoid load xong
    regenerateHealth()
end)

-- Thông báo khi script chạy thành công
print("✅ Fast HP Regen đã kích hoạt! Máu hồi cực nhanh.")
print("   Nhấn lại script nếu muốn reload.")

-- ========================
-- Cách tắt script (nếu cần)
-- ========================
-- Uncomment 2 dòng dưới nếu bạn muốn thêm phím tắt (ví dụ: nhấn "P" để bật/tắt)
-- local UserInputService = game:GetService("UserInputService")
-- UserInputService.InputBegan:Connect(function(input)
--     if input.KeyCode == Enum.KeyCode.P then
--         enabled = not enabled
--         print("Fast HP Regen: " .. (enabled and "ON" or "OFF"))
--     end
-- end)