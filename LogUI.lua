local Players = game:GetService("Players")
local LogService = game:GetService("LogService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

-- Copy Discord link to clipboard
setclipboard("https://discord.gg/EZHQRrZ8Vm")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "ServerLogUI"

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0.4, 0, 0.6, 0)
Frame.Position = UDim2.new(0.3, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(50, 50, 50)
Frame.Active = true -- Enables interaction

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🔍 Server Log"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = Frame
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = Frame
ScrollingFrame.Size = UDim2.new(1, 0, 1, -50)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Function to add logs to the UI
local function addLog(message)
    local LogLabel = Instance.new("TextLabel")
    LogLabel.Parent = ScrollingFrame
    LogLabel.Size = UDim2.new(1, -10, 0, 20)
    LogLabel.BackgroundTransparency = 1
    LogLabel.Text = message
    LogLabel.Font = Enum.Font.Gotham
    LogLabel.TextSize = 14
    LogLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left

    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

-- Dragging Functionality (PC + Mobile Support)
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Hook System for All Players (Instant Connection)
local function playerHook(player)
    addLog("[JOIN] " .. player.Name .. " has joined the game.")

    -- Listen for messages from the player
    player.Chatted:Connect(function(message)
        addLog("[CHAT] " .. player.Name .. ": " .. message)
    end)
end

-- Hook all existing players
for _, player in ipairs(Players:GetPlayers()) do
    playerHook(player)
end

-- Hook new players as they join
Players.PlayerAdded:Connect(playerHook)

Players.PlayerRemoving:Connect(function(player)
    addLog("[LEAVE] " .. player.Name .. " has left the game.")
end)

-- Capture Server Logs in Real-Time (No Delay)
LogService.MessageOut:Connect(function(message, messageType)
    local prefix = "[INFO]"
    if messageType == Enum.MessageType.MessageError then
        prefix = "[ERROR] ⚠️"
    elseif messageType == Enum.MessageType.MessageWarning then
        prefix = "[WARNING] ⚠️"
    end

    addLog(prefix .. " " .. message)
end)

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Notify player that the Discord link is copied
StarterGui:SetCore("SendNotification", {
    Title = "Copied to Clipboard!";
    Text = "Discord link copied!";
    Duration = 3;
})
