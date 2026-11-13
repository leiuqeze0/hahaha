-- // OLLIE BENCH SPEC: ARSENAL DYNAMIC TEAM-COLOR ESP
-- // TARGET: Delta / Universal Executor
-- // FEATURES: Dynamic Team Color ESP Glow + Blatant Head-Lock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Clean up previous execution
if CoreGui:FindFirstChild("ArsenalOllieHub") then
    CoreGui.ArsenalOllieHub:Destroy()
end

local Config = {
    Aimbot = {
        Enabled = true,
        FOV = 999,
        TeamCheck = true,
    },
    Visuals = {
        Enabled = true,
        Transparency = 0.2,
        UseTeamColor = true,
        FallbackColor = Color3.fromRGB(255, 0, 0),
    }
}

-- UI Container & Floating Button
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArsenalOllieHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Indicator = Instance.new("TextButton")
Indicator.Size = UDim2.new(0, 40, 0, 40)
Indicator.Position = UDim2.new(0.02, 0, 0.3, 0)
Indicator.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Indicator.BorderColor3 = Color3.fromRGB(255, 0, 0)
Indicator.BorderSizePixel = 2
Indicator.Text = "O"
Indicator.TextColor3 = Color3.fromRGB(255, 0, 0)
Indicator.Font = Enum.Font.GothamBold
Indicator.TextSize = 18
Indicator.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Indicator

-- Mobile Drag Logic
local dragging, dragStart, startPos
Indicator.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Indicator.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.MouseMovement) then
        local delta = input.Position - dragStart
        Indicator.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.MouseButton1 then
        dragging = false
    end
end)

-- Dynamic Team-Color Glowing ESP Engine
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            if Config.Visuals.Enabled then
                -- Skip teammates if team check is desired, or highlight everyone with their team color
                local glowColor = Config.Visuals.FallbackColor
                if Config.Visuals.UseTeamColor and player.Team then
                    glowColor = player.Team.TeamColor.Color
                end

                local hl = char:FindFirstChild("OllieGlow")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "OllieGlow"
                    hl.Adornee = char
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                end
                
                hl.FillColor = glowColor
                hl.OutlineColor = glowColor
                hl.FillTransparency = Config.Visuals.Transparency
                hl.Enabled = true
            else
                local hl = char:FindFirstChild("OllieGlow")
                if hl then hl.Enabled = false end
            end
        end
    end
end)

-- Blatant Head-Lock Aimbot Engine
RunService.RenderStepped:Connect(function()
    if Config.Aimbot.Enabled then
        local targetHead = nil
        local shortestDist = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
                if player.Character.Humanoid.Health > 0 then
                    if not Config.Aimbot.TeamCheck or player.Team ~= LocalPlayer.Team then
                        local head = player.Character.Head
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                targetHead = head
                            end
                        end
                    end
                end
            end
        end

        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)

print("Ollie: Dynamic Team-Color ESP Active.")
