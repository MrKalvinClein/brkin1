local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)

local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
    Title = "Dexter Scripts",
    Subtitle = "by nipcd",
    Size = isMobile and UDim2.fromOffset(780, 580) or UDim2.fromOffset(868, 650),
    DragStyle = isMobile and 2 or 1,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.K,
    AcrylicBlur = true,
})

local isOpen = true

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MacLibToggle"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local circle = Instance.new("TextButton")
circle.Size = UDim2.fromOffset(55, 55)
circle.Position = UDim2.new(0, 15, 0.85, 0)
circle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
circle.Text = "✦"
circle.TextColor3 = Color3.new(1, 1, 1)
circle.TextSize = 22
circle.Font = Enum.Font.Legacy
circle.BorderSizePixel = 0
circle.ZIndex = 999
circle.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = circle

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 100)
stroke.Thickness = 2
stroke.Parent = circle

local dragging = false
local dragOffset = Vector2.new()
local touchStartPos = Vector2.new()

circle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        touchStartPos = Vector2.new(input.Position.X, input.Position.Y)
        dragOffset = Vector2.new(circle.AbsolutePosition.X - input.Position.X, circle.AbsolutePosition.Y - input.Position.Y)
    end
end)

circle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X - touchStartPos.X, input.Position.Y - touchStartPos.Y)
        if delta.Magnitude > 10 then dragging = true end
        if dragging then
            circle.Position = UDim2.fromOffset(input.Position.X + dragOffset.X, input.Position.Y + dragOffset.Y)
        end
    end
end)

circle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not dragging then
            isOpen = not isOpen
            Window:SetState(isOpen)
        end
        dragging = false
    end
end)

local hasTruck = Workspace:FindFirstChild("Truck1") or Workspace:FindFirstChild("Truck2")

local TabGroup = Window:TabGroup()

if not hasTruck then
    local MainTab = TabGroup:Tab({ Name = "Main" })
    local MainSection = MainTab:Section({ Side = "Left" })
    local MainSection2 = MainTab:Section({ Side = "Right" })

    local selectedItem = "Apple"
    local getItemLoop = false

    MainSection:Dropdown({
        Name = "Items",
        Options = {
            "MedKit", "Bat", "TeddyBloxpin", "Cure", "Cookie", "Chips", "Pan",
            "BloxyCola", "Apple", "Pizza3", "Plank", "LinkedSword", "Lollipop",
            "ExpiredBloxyCola", "EpicPizza", "CarKey", "Pie"
        },
        Default = 9,
        Callback = function(option)
            selectedItem = option
        end
    })

    MainSection:Button({
        Name = "Get Item",
        Callback = function()
            ReplicatedStorage.RemoteEvents.GiveTool:FireServer(selectedItem)
        end
    })

    MainSection:Toggle({
        Name = "Get Item (Loop)",
        Default = false,
        Callback = function(state)
            getItemLoop = state
            if state then
                task.spawn(function()
                    while getItemLoop do
                        ReplicatedStorage.RemoteEvents.GiveTool:FireServer(selectedItem)
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    MainSection2:Header({ Text = "Weapons" })

    local selectedWeapon = "Crowbar"

    MainSection2:Dropdown({
        Name = "Weapons",
        Options = { "Crowbar", "Bat", "Hammer", "Pitchfork" },
        Default = 1,
        Callback = function(option)
            selectedWeapon = option
        end
    })

    MainSection2:Button({
        Name = "Get Weapon",
        Callback = function()
            ReplicatedStorage.RemoteEvents.BasementWeapon:FireServer(true, selectedWeapon)
        end
    })
end

if hasTruck then
    local RolesTab = TabGroup:Tab({ Name = "Roles" })
    local SpecialSection = RolesTab:Section({ Side = "Left" })
    local DefaultSection = RolesTab:Section({ Side = "Right" })

    SpecialSection:Header({ Text = "Special / Paid" })

    SpecialSection:Button({ Name = "Swat", Callback = function() ReplicatedStorage.RemoteEvents.OutsideRole:FireServer("SwatGun", true) end })
    SpecialSection:Button({ Name = "Police", Callback = function() ReplicatedStorage.RemoteEvents.OutsideRole:FireServer("Gun", true) end })
    SpecialSection:Button({ Name = "The Fighter", Callback = function() ReplicatedStorage.RemoteEvents.OutsideRole:FireServer("Sword", false) end })
    SpecialSection:Button({ Name = "The Hyper (Need 1 more badges)", Callback = function() ReplicatedStorage.RemoteEvents.OutsideRole:FireServer("Lollipop", true) end })
    SpecialSection:Button({ Name = "The Guest (Need 6 more badges)", Callback = function() ReplicatedStorage.RemoteEvents.OutsideRole:FireServer("LinkedSword", true) end })

    DefaultSection:Header({ Text = "Default" })

    DefaultSection:Button({ Name = "The Protector", Callback = function() ReplicatedStorage.RemoteEvents.MakeRole:FireServer("Bat", false, false) end })
    DefaultSection:Button({ Name = "The Medic", Callback = function() ReplicatedStorage.RemoteEvents.MakeRole:FireServer("MedKit", false, false) end })
    DefaultSection:Button({ Name = "The Hungry", Callback = function() ReplicatedStorage.RemoteEvents.MakeRole:FireServer("Chips", true, false) end })
    DefaultSection:Button({ Name = "The Stealthy", Callback = function() ReplicatedStorage.RemoteEvents.MakeRole:FireServer("TeddyBloxpin", true, false) end })
end

if not hasTruck then
    local TeleportTab = TabGroup:Tab({ Name = "Teleport" })
    local TeleportsSection = TeleportTab:Section({ Side = "Left" })
    local RoomsSection = TeleportTab:Section({ Side = "Right" })

    TeleportsSection:Header({ Text = "Teleports" })

    TeleportsSection:Button({ Name = "Basement", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(71, -15, -163) end })
    TeleportsSection:Button({ Name = "House", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-36, 3, -200) end })
    TeleportsSection:Button({ Name = "Hiding Spot", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-42.86, 6.43, -222.01) end })
    TeleportsSection:Button({ Name = "Attic", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-16, 35, -220) end })
    TeleportsSection:Button({ Name = "Store", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-422, 3, -121) end })
    TeleportsSection:Button({ Name = "Sewer", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(129, 3, -125) end })
    TeleportsSection:Button({ Name = "Boss Room", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-39, -287, -1480) end })

    RoomsSection:Header({ Text = "Rooms" })

    RoomsSection:Button({ Name = "Blue Room", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-47.87, 23.39, -201.47) end })
    RoomsSection:Button({ Name = "Green Room", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(7.27, 24.39, -194.08) end })
    RoomsSection:Button({ Name = "Pink Room", Callback = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(6.08, 23.39, -226.01) end })

    local PlayerTab = TabGroup:Tab({ Name = "Player" })
    local PlayerSection1 = PlayerTab:Section({ Side = "Left" })
    local PlayerSection2 = PlayerTab:Section({ Side = "Right" })

    local getEnergy = false

    PlayerSection1:Toggle({
        Name = "Get Energy",
        Default = false,
        Callback = function(state)
            getEnergy = state
            if state then
                task.spawn(function() while getEnergy do ReplicatedStorage.RemoteEvents.Energy:FireServer(15, "Cookie") task.wait(0.1) end end)
                task.spawn(function() while getEnergy do ReplicatedStorage.RemoteEvents.GiveTool:FireServer("Cookie") task.wait(0.1) end end)
            end
        end
    })

    PlayerSection1:Button({
        Name = "Get Energy Instantly",
        Callback = function()
            for i = 1, 7 do ReplicatedStorage.RemoteEvents.GiveTool:FireServer("Apple") end
            for i = 1, 7 do ReplicatedStorage.RemoteEvents.Energy:FireServer(15, "Apple") end
        end
    })

    PlayerSection1:Button({
        Name = "GodMode",
        Callback = function()
            ReplicatedStorage.RemoteEvents.MakeStealth:FireServer(5000000000)
            task.wait(1)
            ReplicatedStorage.RemoteEvents.MakeStealth:FireServer(5000000000)
        end
    })

    local noclipEnabled = false
    local noclipConnection = nil

    PlayerSection1:Toggle({
        Name = "No Clip",
        Default = false,
        Callback = function(state)
            noclipEnabled = state
            if state then
                noclipConnection = RunService.Heartbeat:Connect(function()
                    if LocalPlayer.Character then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end)
            else
                if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
                    end
                end
            end
        end
    })

    PlayerSection2:Header({ Text = "WalkSpeed" })

    local walkspeedValue = 16
    local walkspeedConnection = nil

    PlayerSection2:Slider({ Name = "WalkSpeed", Default = 16, Minimum = 16, Maximum = 500, DisplayMethod = "Value", Callback = function(v) walkspeedValue = v end })

    PlayerSection2:Toggle({
        Name = "Enable WalkSpeed",
        Default = false,
        Callback = function(state)
            if state then
                walkspeedConnection = RunService.Heartbeat:Connect(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.WalkSpeed = walkspeedValue
                    end
                end)
            else
                if walkspeedConnection then walkspeedConnection:Disconnect() walkspeedConnection = nil end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 16
                end
            end
        end
    })

    PlayerSection2:Divider()
    PlayerSection2:Header({ Text = "JumpPower" })

    local jumppowerValue = 50
    local jumppowerConnection = nil

    PlayerSection2:Slider({ Name = "JumpPower", Default = 50, Minimum = 50, Maximum = 500, DisplayMethod = "Value", Callback = function(v) jumppowerValue = v end })

    PlayerSection2:Toggle({
        Name = "Enable JumpPower",
        Default = false,
        Callback = function(state)
            if state then
                jumppowerConnection = RunService.Heartbeat:Connect(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.UseJumpPower = true
                        LocalPlayer.Character.Humanoid.JumpPower = jumppowerValue
                    end
                end)
            else
                if jumppowerConnection then jumppowerConnection:Disconnect() jumppowerConnection = nil end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.UseJumpPower = true
                    LocalPlayer.Character.Humanoid.JumpPower = 50
                end
            end
        end
    })

    local infiniteJumpEnabled = false

    PlayerSection2:Toggle({
        Name = "Infinite Jump",
        Default = false,
        Callback = function(state) infiniteJumpEnabled = state end
    })

    UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local MiscTab = TabGroup:Tab({ Name = "Misc" })
local MiscSection1 = MiscTab:Section({ Side = "Left" })
local MiscSection2 = MiscTab:Section({ Side = "Right" })

if not hasTruck then
    MiscSection1:Button({ Name = "Be Friends with Cat", Callback = function() ReplicatedStorage.RemoteEvents.Cattery:FireServer() end })
    MiscSection1:Button({
        Name = "Open Safe",
        Callback = function()
            local safeCode = Workspace.CodeNote.SurfaceGui.TextLabel.Text
            ReplicatedStorage.RemoteEvents.Safe:FireServer(safeCode)
        end
    })
    MiscSection1:Button({
        Name = "Unlock Door",
        Callback = function()
            ReplicatedStorage.RemoteEvents.FoundItem:FireServer("Key")
            ReplicatedStorage.RemoteEvents.UnlockDoor:FireServer()
            ReplicatedStorage.RemoteEvents.Door:FireServer("Basement", true)
        end
    })
    MiscSection1:Button({
        Name = "Kill Enemies",
        Callback = function()
            for _, enemy in pairs(Workspace.BadGuys:GetChildren()) do
                for i = 1, 50 do
                    ReplicatedStorage.RemoteEvents.HitBadguy:FireServer(enemy, 10)
                    ReplicatedStorage.RemoteEvents.HitBadguy:FireServer(enemy, 996)
                    ReplicatedStorage.RemoteEvents.HitBadguy:FireServer(enemy, 9)
                    ReplicatedStorage.RemoteEvents.HitBadguy:FireServer(enemy, 8)
                end
            end
        end
    })
    MiscSection1:Divider()
end

MiscSection1:Toggle({
    Name = "Anti-AFK",
    Default = false,
    Callback = function(state)
        if state then
            local VirtualUser = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
})

MiscSection1:Button({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

MiscSection1:Button({
    Name = "Server Hop",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end
    end
})

MiscSection2:Header({ Text = "Info" })
MiscSection2:Label({ Text = "Keybind UI: K" })
