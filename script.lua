local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    Lighting.FogEnd = 9e9
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPS_Boost_UI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = -100

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 140, 0, 30)
Frame.Position = UDim2.new(0.5, -70, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.4
Frame.BorderSizePixel = 0

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = Frame
UIStroke.Thickness = 2

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = Frame
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.TextSize = 14
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.Text = "FPS: ..."

task.spawn(function()
    local hue = 0
    while task.wait(0.02) do
        hue = (hue + 0.005) % 1
        local rainbowColor = Color3.fromHSV(hue, 0.8, 1)
        TextLabel.TextColor3 = rainbowColor
        UIStroke.Color = rainbowColor
    end
end)

local frameCount = 0
local lastTime = os.clock()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = os.clock()
    
    if currentTime - lastTime >= 0.5 then
        local fps = math.floor(frameCount / (currentTime - lastTime))
        TextLabel.Text = "FPS: " .. tostring(fps)
        frameCount = 0
        lastTime = currentTime
    end
end)

local function isCharacterPart(item)
    return item:FindFirstAncestorOfClass("Model") and item:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid")
end

local function optimizePart(item)
    if isCharacterPart(item) then return end

    if item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Smoke") or item:IsA("Fire") or item:IsA("Sparkles") then
        item.Enabled = false
    elseif item:IsA("Decal") or item:IsA("Texture") then
        item.Texture = ""
    elseif item:IsA("SpecialMesh") then
        item.TextureId = ""
    elseif item:IsA("BasePart") then
        item.Material = Enum.Material.SmoothPlastic
        item.Reflectance = 0
    end
end

for _, item in pairs(workspace:GetDescendants()) do
    optimizePart(item)
end

workspace.DescendantAdded:Connect(function(item)
    task.wait(0.1)
    optimizePart(item)
end)

for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
        effect.Enabled = false
    end
end
    if isCharacterPart(item) then return end

    if item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Smoke") or item:IsA("Fire") or item:IsA("Sparkles") then
        item.Enabled = false
    elseif item:IsA("Decal") or item:IsA("Texture") then
        item.Texture = ""
    elseif item:IsA("SpecialMesh") then
        item.TextureId = ""
    elseif item:IsA("BasePart") then
        item.Material = Enum.Material.SmoothPlastic
        item.Reflectance = 0
    end
end

-- Áp dụng cho các vật thể trong map
for _, item in pairs(workspace:GetDescendants()) do
    optimizePart(item)
end

-- Tối ưu vật thể mới sinh ra
workspace.DescendantAdded:Connect(function(item)
    task.wait(0.1)
    optimizePart(item)
end)

-- Tắt hiệu ứng làm đẹp trong Lighting
for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
        effect.Enabled = false
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

-- Khung Banner Hiển Thị (Đã đẩy xuống Y = 0.08 để tránh bị mép trên che)
local bannerFrame = Instance.new("Frame", topGui)
bannerFrame.Size = UDim2.new(0, 380, 0, 42)
bannerFrame.Position = UDim2.new(0.02, 0, 0.08, 0) -- Đẩy xuống thấp hơn
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
infoLabel.TextSize = 18
infoLabel.RichText = true
infoLabel.ZIndex = 11
infoLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Nút Tắt/Bật Màn hình đen (Nằm ngay bên dưới banner)
local button = Instance.new("TextButton", topGui)
button.Size = UDim2.new(0, 140, 0, 32)
button.Position = UDim2.new(0.02, 0, 0.19, 0) -- Đẩy xuống theo banner
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

-- Hiệu ứng Rainbow và cập nhật thông tin
task.spawn(function()
    while true do
        local elapsed = os.time() - startTime
        local timeStr = formatTime(elapsed)
        local username = player.Name
        
        local tickTime = tick() * 2
        local r = math.floor(math.sin(tickTime) * 127 + 128)
        local g = math.floor(math.sin(tickTime + 2) * 127 + 128)
        local b = math.floor(math.sin(tickTime + 4) * 127 + 128)
        
        infoLabel.Text = string.format(
            '<font color="rgb(%d,%d,%d)">%d FPS</font>   <font color="rgb(255,60,60)">%s</font>   <font color="rgb(230,60,255)">%s</font>',
            r, g, b, currentFPS, timeStr, username
        )
        task.wait(0.05)
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
