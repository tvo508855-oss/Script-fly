-- FLY SCRIPT (ROBLOX)
local Players = game:StringToService("Players") or game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Cấu hình tốc độ bay
local FLY_SPEED = 50
local isFlying = true

-- Tạo các đối tượng vật lý kiểm soát chuyển động
local attachment = Instance.new("Attachment", RootPart)
local linearVelocity = Instance.new("LinearVelocity", RootPart)
linearVelocity.Attachment0 = attachment
linearVelocity.MaxForce = math.huge
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector3

-- Biến lưu trạng thái phím bấm
local keys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

-- Theo dõi phím nhấn xuống
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local key = input.KeyCode.Name
    if keys[key] ~= nil then
        keys[key] = true
    end
    -- Nhấn phím 'F' để Bật/Tắt bay nhanh
    if input.KeyCode == Enum.KeyCode.F then
        isFlying = not isFlying
        if not isFlying then
            linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Theo dõi khi nhả phím
UIS.InputEnded:Connect(function(input)
    local key = input.KeyCode.Name
    if keys[key] ~= nil then
        keys[key] = false
    end
end)

-- Vòng lặp cập nhật hướng bay liên tục theo Camera
local connection
connection = RunService.RenderStepped:Connect(function()
    if not Character or not Character:Parent() then
        connection:Disconnect()
        return
    end
    
    if not isFlying then 
        linearVelocity.Enabled = false
        return 
    end
    
    linearVelocity.Enabled = true
    local camera = workspace.CurrentCamera
    local moveDirection = Vector3.new(0, 0, 0)
    
    -- Tính toán hướng dựa trên Camera góc nhìn người chơi
    if keys.W then moveDirection = moveDirection + camera.CFrame.LookVector end
    if keys.S then moveDirection = moveDirection - camera.CFrame.LookVector end
    if keys.A then moveDirection = moveDirection - camera.CFrame.RightVector end
    if keys.D then moveDirection = moveDirection + camera.CFrame.RightVector end
    if keys.Space then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
    if keys.LeftShift then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
    
    -- Áp dụng vận tốc bay
    if moveDirection.Magnitude > 0 then
        linearVelocity.VectorVelocity = moveDirection.Unit * FLY_SPEED
    else
        linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
    end
end)

-- Tự động dọn dẹp khi nhân vật reset/chết
Humanoid.Died:Connect(function()
    connection:Disconnect()
    linearVelocity:Destroy()
    attachment:Destroy()
end)
