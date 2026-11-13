-- Arsenal Full Script: Core Aimbot & Glowing Enemy ESP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    AimbotEnabled = true,
    TeamCheck = true,
    FOV = 150,
    Smoothness = 0.25,
    GlowColor = Color3.fromRGB(255, 30, 30),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    Transparency = 0.3
}

-- ESP Highlight Management
local function applyHighlight(character)
    if not character:FindFirstChild("OllieFullESP") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "OllieFullESP"
        highlight.Adornee = character
        highlight.FillColor = Config.GlowColor
        highlight.FillTransparency = Config.Transparency
        highlight.OutlineColor = Config.OutlineColor
        highlight.OutlineTransparency = 0
        highlight.AlwaysOnTop = true
        highlight.Parent = character
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                if not Config.TeamCheck or player.Team ~= LocalPlayer.Team then
                    applyHighlight(character)
                else
                    local existingHighlight = character:FindFirstChild("OllieFullESP")
                    if existingHighlight then
                        existingHighlight:Destroy()
                    end
                end
            end
        end
    end
end

-- Aimbot Targeting Logic
local function getClosestPlayer()
    local closestTarget = nil
    local shortestDistance = Config.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Config.TeamCheck or player.Team ~= LocalPlayer.Team then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local rootPart = character.HumanoidRootPart
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
                    
                    if onScreen then
                        local mouseLocation = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude
                        
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = rootPart
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Main Execution Loops
RunService.RenderStepped:Connect(function()
    pcall(function()
        updateESP()
        
        if Config.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getClosestPlayer()
            if target then
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, Config.Smoothness)
            end
        end
    end)
end)
