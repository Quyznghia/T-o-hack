local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then return end

-- 1. Create Safe Floor Under Player To Prevent Falling Into Void
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

-- 2. Create GUI 
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "ExtremeOptimization"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2000000000

-- Vòng lặp liên tục ép GUI này lên trên cùng, không cho menu khác đè
task.spawn(function()
    while true do
        pcall(function()
            local maxOrder = 2000000000
            for _, child in ipairs(playerGui:GetChildren()) do
                if child:IsA("ScreenGui") and child ~= gui then
                    if child.DisplayOrder and child.DisplayOrder >= maxOrder then
                        maxOrder = child.DisplayOrder + 100
                    end
                end
            end
            gui.DisplayOrder = maxOrder
        end)
        task.wait(0.5)
    end
end)

local blackFrame = Instance.new("Frame", gui)
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 99998
blackFrame.Visible = true

local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 160, 0, 40)
button.Position = UDim2.new(0.05, 0, 0.15, 0)
button.Text = "Black Screen: ON"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 16
button.Font = Enum.Font.SourceSansBold
button.ZIndex = 99999
button.Active = true
button.Draggable = true

local btnCorner = Instance.new("UICorner", button)
btnCorner.CornerRadius = UDim.new(0, 8)

-- 3. Rounded FPS & Ping Display Frame
local statsFrame = Instance.new("Frame", gui)
statsFrame.Size = UDim2.new(0, 200, 0, 65)
statsFrame.Position = UDim2.new(0.05, 0, 0.23, 0)
statsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statsFrame.BackgroundTransparency = 0.2
statsFrame.BorderSizePixel = 0
statsFrame.ZIndex = 99999
statsFrame.Active = true
statsFrame.Draggable = true

local statsCorner = Instance.new("UICorner", statsFrame)
statsCorner.CornerRadius = UDim.new(0, 12)

local statsStroke = Instance.new("UIStroke", statsFrame)
statsStroke.Thickness = 2
statsStroke.Color = Color3.fromRGB(255, 255, 255)

local statsLabel = Instance.new("TextLabel", statsFrame)
statsLabel.Size = UDim2.new(1, 0, 1, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statsLabel.TextSize = 22
statsLabel.Font = Enum.Font.SourceSansBold
statsLabel.Text = "FPS: --\nPing: -- ms"
statsLabel.ZIndex = 100000

-- Rainbow Animation for Rounded Frame Stroke & Text
RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local rainbowColor = Color3.fromHSV(hue, 1, 1)
    statsStroke.Color = rainbowColor
    statsLabel.TextColor3 = rainbowColor
end)

-- Update FPS & Ping Counter Safely
task.spawn(function()
    while true do
        local startTime = os.clock()
        RunService.RenderStepped:Wait()
        local fps = math.floor(1 / (os.clock() - startTime))
        
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        
        statsLabel.Text = string.format("FPS: %d\nPing: %d ms", fps, ping)
        task.wait(1)
    end
end)

-- 4. Safe Map Wiping Function (Chunked to prevent lag/freeze)
local function clearMap()
    task.spawn(function()
        pcall(function()
            local terrain = Workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain:Clear()
            end
            
            Lighting.GlobalShadows = false
            Lighting.Brightness = 0
            for _, v in ipairs(Lighting:GetChildren()) do
                v:Destroy()
            end

            local count = 0
            for _, item in ipairs(Workspace:GetDescendants()) do
                if item ~= safeFloor and item ~= Workspace.CurrentCamera then
                    local isPlayerPart = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character and (item == p.Character or item:IsDescendantOf(p.Character)) then
                            isPlayerPart = true
                            break
                        end
                    end

                    if not isPlayerPart then
                        pcall(function()
                            if item:IsA("BasePart") or item:IsA("MeshPart") or item:IsA("Texture") or item:IsA("Decal") then
                                item:Destroy()
                                count = count + 1
                                if count % 100 == 0 then
                                    task.wait() -- Prevent lagging by pausing every 100 deletions
                                end
                            end
                        end)
                    end
                end
            end
        end)
    end)
end

-- Run cleaning safely after 40 seconds
task.spawn(function()
    task.wait(40)
    clearMap()
end)

-- 5. Toggle Button Functionality
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
        clearMap()
    end
end)
