local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Xác định container hiển thị
local targetContainer = game:GetService("CoreGui")
local success = pcall(function()
    local test = Instance.new("ScreenGui", targetContainer)
    test:Destroy()
end)
if not success then
    targetContainer = player:WaitForChild("PlayerGui", 5)
end

-- 1. Safe Floor
local safeFloor = Instance.new("Part")
safeFloor.Name = "SafeOptimizationFloor"
safeFloor.Size = Vector3.new(10000, 10, 10000)
safeFloor.Anchored = true
safeFloor.Transparency = 1
safeFloor.CanCollide = true
safeFloor.Parent = Workspace

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        safeFloor.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 5, hrp.Position.Z)
        if hrp.Position.Y < (safeFloor.Position.Y - 10) then
            hrp.CFrame = CFrame.new(hrp.Position.X, safeFloor.Position.Y + 10, hrp.Position.Z)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- 2. GUI cho màn hình đen
local bgGui = Instance.new("ScreenGui", targetContainer)
bgGui.Name = "Optimization_Background"
bgGui.ResetOnSpawn = false
bgGui.IgnoreGuiInset = true
bgGui.DisplayOrder = 1

local blackFrame = Instance.new("Frame", bgGui)
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 1
blackFrame.Visible = true

-- 3. GUI riêng cho Thanh FPS và Nút bấm
local topGui = Instance.new("ScreenGui", targetContainer)
topGui.Name = "Optimization_TopBar"
topGui.ResetOnSpawn = false
topGui.IgnoreGuiInset = true
topGui.DisplayOrder = 2147483647

-- Nút Tắt/Bật Màn hình đen
local button = Instance.new("TextButton", topGui)
button.Size = UDim2.new(0, 140, 0, 32)
button.Position = UDim2.new(0.02, 0, 0.17, 0)
button.Text = "Black Screen: ON"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 13
button.Font = Enum.Font.SourceSansBold
button.ZIndex = 10
button.Active = true
button.Draggable = true

local btnCorner = Instance.new("UICorner", button)
btnCorner.CornerRadius = UDim.new(0, 6)

-- Khung Banner Hiển Thị (Làm TO hơn và chuyển sang GÓC BÊN TRÁI)
local bannerFrame = Instance.new("Frame", topGui)
bannerFrame.Size = UDim2.new(0, 420, 0, 45) -- Kích thước to hơn
bannerFrame.Position = UDim2.new(0.02, 0, 0.02, 0) -- Đặt ở góc trên bên trái
bannerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
bannerFrame.BackgroundTransparency = 0.2
bannerFrame.BorderSizePixel = 0
bannerFrame.ZIndex = 10
bannerFrame.Active = true
bannerFrame.Draggable = true

local bannerCorner = Instance.new("UICorner", bannerFrame)
bannerCorner.CornerRadius = UDim.new(0, 8)

local bannerStroke = Instance.new("UIStroke", bannerFrame)
bannerStroke.Thickness = 1.5
bannerStroke.Color = Color3.fromRGB(255, 255, 255)

local infoLabel = Instance.new("TextLabel", bannerFrame)
infoLabel.Size = UDim2.new(1, 0, 1, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.TextSize = 20 -- Chữ to rõ hơn
infoLabel.RichText = true
infoLabel.ZIndex = 11
infoLabel.TextXAlignment = Enum.TextXAlignment.Center

local startTime = os.time()

local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

-- Đo FPS
local frameCount = 0
local lastUpdate = os.clock()
local currentFPS = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = os.clock()
    if now - lastUpdate >= 1 then
        currentFPS = math.floor(frameCount / (now - lastUpdate))
        frameCount = 0
        lastUpdate = now
    end
end)

-- Hiệu ứng Rainbow và cập nhật thông tin liên tục
task.spawn(function()
    while true do
        local elapsed = os.time() - startTime
        local timeStr = formatTime(elapsed)
        local username = player.Name
        
        -- Tạo màu Rainbow chạy theo thời gian thực (Hue chạy từ 0 đến 1)
        local tickTime = tick() * 2
        local r = math.floor(math.sin(tickTime) * 127 + 128)
        local g = math.floor(math.sin(tickTime + 2) * 127 + 128)
        local b = math.floor(math.sin(tickTime + 4) * 127 + 128)
        
        infoLabel.Text = string.format(
            '<font color="rgb(%d,%d,%d)">%d FPS</font>   <font color="rgb(255,60,60)">%s</font>   <font color="rgb(230,60,255)">%s</font>',
            r, g, b, currentFPS, timeStr, username
        )
        task.wait(0.05) -- Cập nhật nhanh mượt để hiệu ứng rainbow nhấp nháy đẹp mắt
    end
end)

-- 4. Xóa tất cả Player khác và dọn Map
local function removeOtherPlayers()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            pcall(function()
                p.Character:Destroy()
            end)
        end
    end
end

Workspace.ChildAdded:Connect(function(child)
    local otherPlayer = Players:GetPlayerFromCharacter(child)
    if otherPlayer and otherPlayer ~= player then
        task.wait(0.05)
        pcall(function() child:Destroy() end)
    end
end)

task.spawn(function()
    while true do
        removeOtherPlayers()
        task.wait(1)
    end
end)

local function clearMap()
    task.spawn(function()
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.Brightness = 0
            
            local terrain = Workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain:Clear()
            end
            
            for _, item in ipairs(Workspace:GetChildren()) do
                if item:IsA("BasePart") or item:IsA("Model") then
                    if item ~= safeFloor and item ~= player.Character then
                        pcall(function() item:Destroy() end)
                        task.wait(0.02)
                    end
                end
            end
        end)
    end)
end

task.spawn(function()
    task.wait(40)
    clearMap()
end)

-- 5. Nút bật/tắt màn hình đen
local enabled = true
button.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        blackFrame.Visible = true
        button.Text = "Black Screen: ON"
        button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        blackFrame.Visible = false
        button.Text = "Black Screen: OFF"
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)
