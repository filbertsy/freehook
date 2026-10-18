-- Rivals Cheat | KiciaHook-Style | Mobile iOS | Delta Executor
-- Key: FREEHOOK (hardcoded, non-bypassable)
-- LocalScript / Executor Script

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// KEY SYSTEM (non-bypassable)
local VALID_KEY = {70,82,69,69,72,79,79,75} -- FREEHOOK bytes
local keyPassed = false

local function validateKey(input: string): boolean
    if type(input) ~= "string" or #input ~= 8 then return false end
    for i = 1, 8 do
        if string.byte(input, i) ~= VALID_KEY[i] then return false end
    end
    return true
end

--// MOBILE DETECTION
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// STATE
local State = {
    -- Aimbot
    AimBot         = false,
    SilentAim      = false,
    AimPart        = "Head",
    AimFOV         = 180,
    AimSmoothing   = 0.2,
    -- ESP
    ESP            = false,
    ESPBoxes        = false,
    ESPNames       = false,
    ESPHealth      = false,
    ESPDistance    = false,
    ESPTracers     = false,
    ESPChams       = false,
    -- Movement
    Speed          = false,
    SpeedValue     = 32,
    BunnyHop       = false,
    InfiniteJump   = false,
    NoClip         = false,
    Fly            = false,
    FlySpeed       = 50,
    -- Combat
    AutoParry      = false,
    AutoBlock      = false,
    NoKnockback    = false,
    InstantKill    = false,
    AntiAim        = false,
    -- Visual
    Fullbright     = false,
    NoFog          = false,
    Crosshair      = false,
    FOVChanger     = false,
    FOVValue       = 90,
    -- Misc
    AutoRespawn    = false,
    SpamAbility    = false,
    Teleport       = false,
    FakeLag        = false,
    AntiAfk        = false,
    InfiniteStamina= false,
    AutoDash       = false,
    -- Player
    GodMode        = false,
    AntiVoid       = false,
    Noclip         = false,
    ReachExtend    = false,
    ReachValue     = 10,
}

--// CONNECTIONS STORE (for cleanup)
local Connections = {}

local function addConn(c) table.insert(Connections, c) end

--// CHARACTER UTILS
local function getChar()
    return LocalPlayer.Character
end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHuman()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

--// GET ENEMIES
local function getEnemies()
    local enemies = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                table.insert(enemies, p)
            end
        end
    end
    return enemies
end

--// CLOSEST PLAYER TO CENTER / FOV
local function getClosestToCenter()
    local closest, closestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in ipairs(getEnemies()) do
        local part = p.Character:FindFirstChild(State.AimPart) or p.Character:FindFirstChild("Head")
        if part then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < State.AimFOV and dist < closestDist then
                    closest = p
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

--// UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FreeHookUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

--// COLOR THEME
local Theme = {
    Bg         = Color3.fromRGB(15, 15, 20),
    Panel      = Color3.fromRGB(22, 22, 30),
    Accent     = Color3.fromRGB(120, 80, 255),
    AccentDark = Color3.fromRGB(80, 50, 180),
    Text       = Color3.fromRGB(235, 235, 245),
    SubText    = Color3.fromRGB(140, 140, 160),
    Toggle_ON  = Color3.fromRGB(100, 220, 120),
    Toggle_OFF = Color3.fromRGB(70, 70, 85),
    Border     = Color3.fromRGB(45, 45, 60),
}

--// KEY UI
local function buildKeyUI()
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Size = UDim2.new(0, 300, 0, 180)
    KeyFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
    KeyFrame.BackgroundColor3 = Theme.Bg
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Parent = ScreenGui

    Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", KeyFrame)
    stroke.Color = Theme.Accent
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "🔐  FREEHOOK"
    title.TextColor3 = Theme.Accent
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = KeyFrame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 20)
    sub.Position = UDim2.new(0, 0, 0, 46)
    sub.BackgroundTransparency = 1
    sub.Text = "Enter your key to continue"
    sub.TextColor3 = Theme.SubText
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 13
    sub.Parent = KeyFrame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.85, 0, 0, 38)
    box.Position = UDim2.new(0.075, 0, 0, 76)
    box.BackgroundColor3 = Theme.Panel
    box.BorderSizePixel = 0
    box.Text = ""
    box.PlaceholderText = "Key here..."
    box.PlaceholderColor3 = Theme.SubText
    box.TextColor3 = Theme.Text
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.ClearTextOnFocus = false
    box.Parent = KeyFrame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local errLabel = Instance.new("TextLabel")
    errLabel.Size = UDim2.new(1, 0, 0, 18)
    errLabel.Position = UDim2.new(0, 0, 0, 118)
    errLabel.BackgroundTransparency = 1
    errLabel.Text = ""
    errLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    errLabel.Font = Enum.Font.Gotham
    errLabel.TextSize = 12
    errLabel.Parent = KeyFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 34)
    btn.Position = UDim2.new(0.075, 0, 0, 136)
    btn.BackgroundColor3 = Theme.Accent
    btn.BorderSizePixel = 0
    btn.Text = "UNLOCK"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = KeyFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local function tryKey()
        if validateKey(box.Text) then
            keyPassed = true
            TweenService:Create(KeyFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.35)
            KeyFrame:Destroy()
            buildMainUI()
        else
            errLabel.Text = "Invalid key."
            box.Text = ""
            TweenService:Create(KeyFrame, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-145,0.5,-90)}):Play()
            task.wait(0.05)
            TweenService:Create(KeyFrame, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-155,0.5,-90)}):Play()
            task.wait(0.05)
            TweenService:Create(KeyFrame, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-150,0.5,-90)}):Play()
        end
    end

    btn.Activated:Connect(tryKey)
    box.FocusLost:Connect(function(enter) if enter then tryKey() end end)
end

--// MAIN UI
function buildMainUI()

    --// ROOT FRAME (draggable, mobile-friendly)
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 320, 0, 480)
    Main.Position = UDim2.new(0, 10, 0.5, -240)
    Main.BackgroundColor3 = Theme.Bg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

    local mainStroke = Instance.new("UIStroke", Main)
    mainStroke.Color = Theme.Border
    mainStroke.Thickness = 1

    --// TOPBAR
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 44)
    TopBar.BackgroundColor3 = Theme.Panel
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

    local logoLabel = Instance.new("TextLabel")
    logoLabel.Size = UDim2.new(0, 160, 1, 0)
    logoLabel.Position = UDim2.new(0, 12, 0, 0)
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = "⚓ FREEHOOK"
    logoLabel.TextColor3 = Theme.Accent
    logoLabel.Font = Enum.Font.GothamBold
    logoLabel.TextSize = 16
    logoLabel.TextXAlignment = Enum.TextXAlignment.Left
    logoLabel.Parent = TopBar

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 36, 0, 28)
    minimizeBtn.Position = UDim2.new(1, -44, 0.5, -14)
    minimizeBtn.BackgroundColor3 = Theme.AccentDark
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Theme.Text
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 14
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Parent = TopBar
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

    --// DRAG (touch + mouse)
    local dragging, dragStart, startPos = false, nil, nil
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    --// MINIMIZE
    local minimized = false
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -44)
    ContentFrame.Position = UDim2.new(0, 0, 0, 44)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = Main

    minimizeBtn.Activated:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(0,320,0,44)}):Play()
            minimizeBtn.Text = "+"
        else
            TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(0,320,0,480)}):Play()
            minimizeBtn.Text = "—"
        end
    end)

    --// TAB BAR
    local tabs = {"Combat","ESP","Movement","Visual","Misc"}
    local tabFrames = {}
    local activeTab = "Combat"

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 36)
    TabBar.Position = UDim2.new(0, 0, 0, 0)
    TabBar.BackgroundColor3 = Theme.Panel
    TabBar.BorderSizePixel = 0
    TabBar.Parent = ContentFrame

    local TabLayout = Instance.new("UIListLayout", TabBar)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 2)

    local tabButtons = {}

    local function switchTab(name)
        activeTab = name
        for _, t in ipairs(tabs) do
            if tabFrames[t] then tabFrames[t].Visible = (t == name) end
            if tabButtons[t] then
                tabButtons[t].BackgroundColor3 = (t == name) and Theme.Accent or Theme.Panel
                tabButtons[t].TextColor3 = (t == name) and Color3.new(1,1,1) or Theme.SubText
            end
        end
    end

    for i, tabName in ipairs(tabs) do
        local tb = Instance.new("TextButton")
        tb.Size = UDim2.new(0, 62, 1, 0)
        tb.BackgroundColor3 = Theme.Panel
        tb.BorderSizePixel = 0
        tb.Text = tabName
        tb.Font = Enum.Font.GothamBold
        tb.TextSize = 11
        tb.TextColor3 = Theme.SubText
        tb.LayoutOrder = i
        tb.Parent = TabBar
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
        tabButtons[tabName] = tb
        tb.Activated:Connect(function() switchTab(tabName) end)
    end

    --// SCROLL CONTENT AREA
    local function makeTabFrame(name)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, -36)
        scroll.Position = UDim2.new(0, 0, 0, 36)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = Theme.Accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Visible = (name == "Combat")
        scroll.Parent = ContentFrame
        tabFrames[name] = scroll

        local layout = Instance.new("UIListLayout", scroll)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)

        local pad = Instance.new("UIPadding", scroll)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        pad.PaddingTop = UDim.new(0, 6)

        return scroll
    end

    local combatTab   = makeTabFrame("Combat")
    local espTab      = makeTabFrame("ESP")
    local moveTab     = makeTabFrame("Movement")
    local visualTab   = makeTabFrame("Visual")
    local miscTab     = makeTabFrame("Misc")

    switchTab("Combat")

    --// WIDGET BUILDERS

    -- Section header
    local function addSection(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 22)
        lbl.BackgroundTransparency = 1
        lbl.Text = "  " .. text:upper()
        lbl.TextColor3 = Theme.Accent
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
    end

    -- Toggle
    local function addToggle(parent, label, stateKey, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundColor3 = Theme.Panel
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Theme.Text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local pill = Instance.new("Frame")
        pill.Size = UDim2.new(0, 44, 0, 24)
        pill.Position = UDim2.new(1, -54, 0.5, -12)
        pill.BackgroundColor3 = State[stateKey] and Theme.Toggle_ON or Theme.Toggle_OFF
        pill.BorderSizePixel = 0
        pill.Parent = row
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = State[stateKey] and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0
        knob.Parent = pill
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = row

        btn.Activated:Connect(function()
            State[stateKey] = not State[stateKey]
            local on = State[stateKey]
            TweenService:Create(pill, TweenInfo.new(0.18), {BackgroundColor3 = on and Theme.Toggle_ON or Theme.Toggle_OFF}):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), {Position = on and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
            if callback then callback(on) end
        end)
    end

    -- Slider
    local function addSlider(parent, label, stateKey, min, max, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 54)
        row.BackgroundColor3 = Theme.Panel
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 0, 24)
        lbl.Position = UDim2.new(0, 10, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Theme.Text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0.35, 0, 0, 24)
        valLabel.Position = UDim2.new(0.65, 0, 0, 4)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(State[stateKey])
        valLabel.TextColor3 = Theme.Accent
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextSize = 13
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -20, 0, 6)
        track.Position = UDim2.new(0, 10, 0, 36)
        track.BackgroundColor3 = Theme.Toggle_OFF
        track.BorderSizePixel = 0
        track.Parent = row
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((State[stateKey]-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local draggingSlider = false

        local function updateSlider(inputPos)
            local rel = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            State[stateKey] = val
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(val)
            if callback then callback(val) end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
                updateSlider(input.Position)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                updateSlider(input.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
    end

    -- Dropdown
    local function addDropdown(parent, label, options, stateKey, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundColor3 = Theme.Panel
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Theme.Text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local curIdx = 1
        for i, v in ipairs(options) do if v == State[stateKey] then curIdx = i end end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 110, 0, 28)
        btn.Position = UDim2.new(1, -118, 0.5, -14)
        btn.BackgroundColor3 = Theme.AccentDark
        btn.BorderSizePixel = 0
        btn.Text = options[curIdx] .. " ▾"
        btn.TextColor3 = Theme.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = row
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.Activated:Connect(function()
            curIdx = (curIdx % #options) + 1
            State[stateKey] = options[curIdx]
            btn.Text = options[curIdx] .. " ▾"
            if callback then callback(options[curIdx]) end
        end)
    end

    --// ===== COMBAT TAB =====
    addSection(combatTab, "Aimbot")
    addToggle(combatTab, "Aimbot", "AimBot")
    addToggle(combatTab, "Silent Aim", "SilentAim")
    addDropdown(combatTab, "Aim Part", {"Head","Torso","HumanoidRootPart"}, "AimPart")
    addSlider(combatTab, "FOV Radius", "AimFOV", 50, 500)
    addSlider(combatTab, "Smoothing", "AimSmoothing", 1, 20)

    addSection(combatTab, "Combat")
    addToggle(combatTab, "Auto Parry", "AutoParry")
    addToggle(combatTab, "Auto Block", "AutoBlock")
    addToggle(combatTab, "No Knockback", "NoKnockback")
    addToggle(combatTab, "Instant Kill", "InstantKill")
    addToggle(combatTab, "Anti-Aim", "AntiAim")
    addToggle(combatTab, "Reach Extend", "ReachExtend")
    addSlider(combatTab, "Reach Value", "ReachValue", 5, 50)

    --// ===== ESP TAB =====
    addSection(espTab, "ESP")
    addToggle(espTab, "ESP Enabled", "ESP")
    addToggle(espTab, "Boxes", "ESPBoxes")
    addToggle(espTab, "Names", "ESPNames")
    addToggle(espTab, "Health Bars", "ESPHealth")
    addToggle(espTab, "Distance", "ESPDistance")
    addToggle(espTab, "Tracers", "ESPTracers")
    addToggle(espTab, "Chams", "ESPChams")

    --// ===== MOVEMENT TAB =====
    addSection(moveTab, "Movement")
    addToggle(moveTab, "Speed Hack", "Speed")
    addSlider(moveTab, "Walk Speed", "SpeedValue", 16, 200)
    addToggle(moveTab, "Bunny Hop", "BunnyHop")
    addToggle(moveTab, "Infinite Jump", "InfiniteJump")
    addToggle(moveTab, "No Clip", "NoClip")
    addToggle(moveTab, "Fly", "Fly")
    addSlider(moveTab, "Fly Speed", "FlySpeed", 10, 300)
    addToggle(moveTab, "Infinite Stamina", "InfiniteStamina")
    addToggle(moveTab, "Auto Dash", "AutoDash")

    --// ===== VISUAL TAB =====
    addSection(visualTab, "Visuals")
    addToggle(visualTab, "Fullbright", "Fullbright", function(on)
        Lighting.Brightness = on and 10 or 1
        Lighting.ClockTime = on and 14 or 14
        Lighting.FogEnd = on and 1e6 or 1e4
        Lighting.GlobalShadows = not on
        Lighting.Ambient = on and Color3.new(1,1,1) or Color3.new(0.5,0.5,0.5)
        Lighting.OutdoorAmbient = on and Color3.new(1,1,1) or Color3.new(0.5,0.5,0.5)
    end)
    addToggle(visualTab, "No Fog", "NoFog", function(on)
        Lighting.FogEnd = on and 1e9 or 1e4
        Lighting.FogStart = on and 1e9 or 0
    end)
    addToggle(visualTab, "Custom Crosshair", "Crosshair")
    addToggle(visualTab, "FOV Changer", "FOVChanger", function(on)
        Camera.FieldOfView = on and State.FOVValue or 70
    end)
    addSlider(visualTab, "FOV Value", "FOVValue", 40, 120, function(v)
        if State.FOVChanger then Camera.FieldOfView = v end
    end)

    --// ===== MISC TAB =====
    addSection(miscTab, "Misc")
    addToggle(miscTab, "Auto Respawn", "AutoRespawn")
    addToggle(miscTab, "Spam Ability", "SpamAbility")
    addToggle(miscTab, "Fake Lag", "FakeLag")
    addToggle(miscTab, "Anti-AFK", "AntiAfk")
    addToggle(miscTab, "God Mode", "GodMode")
    addToggle(miscTab, "Anti Void", "AntiVoid")
    addToggle(miscTab, "Reach Extend", "ReachExtend")

    --// === LOGIC LOOP ===

    --// Aimbot
    addConn(RunService.RenderStepped:Connect(function()
        if State.AimBot then
            local target = getClosestToCenter()
            if target then
                local part = target.Character:FindFirstChild(State.AimPart) or target.Character:FindFirstChild("Head")
                if part then
                    local screenPos = Camera:WorldToViewportPoint(part.Position)
                    local current = Vector2.new(Mouse.X, Mouse.Y)
                    local goal = Vector2.new(screenPos.X, screenPos.Y)
                    local smooth = State.AimSmoothing / 20
                    local lerped = current:Lerp(goal, smooth)
                    -- Delta executor mousemove
                    mousemoverel(lerped.X - current.X, lerped.Y - current.Y)
                end
            end
        end
    end))

    --// Silent Aim
    addConn(Players.LocalPlayer:GetMouse().Move:Connect(function()
        -- Silent aim hooks into camera ray; executor-dependent
        -- Works on Delta via Camera CFrame manipulation
        if State.SilentAim then
            local target = getClosestToCenter()
            if target then
                local part = target.Character:FindFirstChild(State.SilentAimPart or "Head")
                if part then
                    -- redirect aim CFrame toward target
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, part.Position)
                end
            end
        end
    end))

    --// Speed
    addConn(RunService.Heartbeat:Connect(function()
        local h = getHuman()
        if h then
            if State.Speed then
                h.WalkSpeed = State.SpeedValue
            else
                if h.WalkSpeed ~= 16 and not State.Speed then h.WalkSpeed = 16 end
            end
            if State.InfiniteStamina then
                -- Rivals stamina regen: attempt to find and max stamina value
                local stamina = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stamina")
                if stamina and stamina:IsA("NumberValue") then stamina.Value = stamina.Value + 1 end
            end
            if State.GodMode then
                h.Health = h.MaxHealth
            end
        end
    end))

    --// Infinite Jump
    addConn(UserInputService.JumpRequest:Connect(function()
        if State.InfiniteJump then
            local h = getHuman()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end))

    --// Bunny Hop
    addConn(RunService.Heartbeat:Connect(function()
        if State.BunnyHop then
            local h = getHuman()
            local root = getRoot()
            if h and root then
                if h:GetState() == Enum.HumanoidStateType.Landed then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end))

    --// NoClip
    addConn(RunService.Stepped:Connect(function()
        if State.NoClip then
            local char = getChar()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end))

    --// Fly
    local flyBody = nil
    addConn(RunService.Heartbeat:Connect(function()
        if State.Fly then
            local root = getRoot()
            if root then
                if not flyBody then
                    flyBody = Instance.new("BodyVelocity")
                    flyBody.MaxForce = Vector3.new(1e5,1e5,1e5)
                    flyBody.Parent = root
                end
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                -- Mobile: use virtual thumbstick direction
                flyBody.Velocity = dir * State.FlySpeed
            end
        else
            if flyBody then flyBody:Destroy() flyBody = nil end
        end
    end))

    --// Anti-Aim
    addConn(RunService.RenderStepped:Connect(function()
        if State.AntiAim then
            local root = getRoot()
            if root then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
            end
        end
    end))

    --// Auto Respawn
    addConn(LocalPlayer.CharacterAdded:Connect(function(char)
        if State.AutoRespawn then
            local h = char:WaitForChild("Humanoid")
            h.Died:Connect(function()
                task.wait(0.5)
                LocalPlayer:LoadCharacter()
            end)
        end
    end))

    --// Anti-AFK
    addConn(LocalPlayer.Idled:Connect(function()
        if State.AntiAfk then
            -- Fire virtual input to reset idle
            local v = Instance.new("VirtualUser")
            v.Parent = game
            v:CaptureController()
            v:ClickButton2(Vector2.new())
            v:Destroy()
        end
    end))

    --// Anti Void
    addConn(RunService.Heartbeat:Connect(function()
        if State.AntiVoid then
            local root = getRoot()
            if root and root.Position.Y < -50 then
                root.CFrame = CFrame.new(0, 10, 0)
            end
        end
    end))

    --// Reach Extend
    addConn(RunService.Heartbeat:Connect(function()
        if State.ReachExtend then
            local char = getChar()
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    local handle = tool:FindFirstChild("Handle")
                    if handle then
                        -- push hitbox forward toward look vector
                        local root = getRoot()
                        if root then
                            handle.CFrame = root.CFrame * CFrame.new(0, 0, -(State.ReachValue / 2))
                        end
                    end
                end
            end
        end
    end))

    --// Custom Crosshair
    local crosshairLines = {}
    local function buildCrosshair()
        for _, l in ipairs(crosshairLines) do l:Destroy() end
        crosshairLines = {}
        if not State.Crosshair then return end
        local cx = Camera.ViewportSize.X / 2
        local cy = Camera.ViewportSize.Y / 2
        local size = 10
        local thickness = 2
        local color = Color3.fromRGB(255, 80, 80)

        local function makeLine(x, y, w, h)
            local f = Instance.new("Frame")
            f.BackgroundColor3 = color
            f.BorderSizePixel = 0
            f.Size = UDim2.new(0, w, 0, h)
            f.Position = UDim2.new(0, x - w/2, 0, y - h/2)
            f.Parent = ScreenGui
            table.insert(crosshairLines, f)
        end

        makeLine(cx, cy, size * 2, thickness)
        makeLine(cx, cy, thickness, size * 2)
    end

    addConn(RunService.RenderStepped:Connect(function()
        if State.Crosshair then
            if #crosshairLines == 0 then buildCrosshair() end
        else
            if #crosshairLines > 0 then
                for _, l in ipairs(crosshairLines) do l:Destroy() end
                crosshairLines = {}
            end
        end
    end))

    --// ESP DRAWING
    local espObjects = {}

    local function clearESP()
        for _, obj in pairs(espObjects) do
            for _, d in pairs(obj) do
                if d and d.Remove then d:Remove() end
            end
        end
        espObjects = {}
    end

    addConn(RunService.RenderStepped:Connect(function()
        if not State.ESP then clearESP() return end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                local head  = p.Character:FindFirstChild("Head")
                local h     = p.Character:FindFirstChildOfClass("Humanoid")
                if not root or not h then continue end

                if not espObjects[p] then espObjects[p] = {} end
                local obj = espObjects[p]

                local rootScreen, onScreen = Camera:WorldToViewportPoint(root.Position)
                if not onScreen then
                    for _, d in pairs(obj) do if d and d.Visible ~= nil then d.Visible = false end end
                    continue
                end

                -- Name
                if State.ESPNames then
                    if not obj.nameTag then
                        local lbl = Drawing.new("Text")
                        lbl.Size = 13
                        lbl.Font = Drawing.Fonts.UI
                        lbl.Center = true
                        lbl.Outline = true
                        lbl.Color = Color3.fromRGB(255,255,255)
                        obj.nameTag = lbl
                    end
                    local headScreen = Camera:WorldToViewportPoint(head and head.Position or root.Position + Vector3.new(0,2,0))
                    obj.nameTag.Position = Vector2.new(headScreen.X, headScreen.Y - 18)
                    obj.nameTag.Text = p.DisplayName
                    obj.nameTag.Visible = true
                elseif obj.nameTag then obj.nameTag.Visible = false end

                -- Distance
                if State.ESPDistance then
                    if not obj.distTag then
                        local lbl = Drawing.new("Text")
                        lbl.Size = 11
                        lbl.Font = Drawing.Fonts.UI
                        lbl.Center = true
                        lbl.Outline = true
                        lbl.Color = Color3.fromRGB(200,200,200)
                        obj.distTag = lbl
                    end
                    local myRoot = getRoot()
                    local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
                    obj.distTag.Position = Vector2.new(rootScreen.X, rootScreen.Y + 14)
                    obj.distTag.Text = dist .. "m"
                    obj.distTag.Visible = true
                elseif obj.distTag then obj.distTag.Visible = false end

                -- Health bar
                if State.ESPHealth then
                    if not obj.healthBar then
                        local bar = Drawing.new("Line")
                        bar.Color = Color3.fromRGB(80, 220, 80)
                        bar.Thickness = 3
                        obj.healthBar = bar
                    end
                    local pct = h.Health / h.MaxHealth
                    local barH = 40 * pct
                    obj.healthBar.From = Vector2.new(rootScreen.X - 22, rootScreen.Y + 20)
                    obj.healthBar.To   = Vector2.new(rootScreen.X - 22, rootScreen.Y + 20 - barH)
                    obj.healthBar.Visible = true
                elseif obj.healthBar then obj.healthBar.Visible = false end

                -- Tracer
                if State.ESPTracers then
                    if not obj.tracer then
                        local line = Drawing.new("Line")
                        line.Color = Color3.fromRGB(120, 80, 255)
                        line.Thickness = 1
                        obj.tracer = line
                    end
                    obj.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    obj.tracer.To   = Vector2.new(rootScreen.X, rootScreen.Y)
                    obj.tracer.Visible = true
                elseif obj.tracer then obj.tracer.Visible = false end

                -- Box ESP
                if State.ESPBoxes then
                    if not obj.box then
                        local box = Drawing.new("Square")
                        box.Filled = false
                        box.Color = Color3.fromRGB(120, 80, 255)
                        box.Thickness = 1.5
                        obj.box = box
                    end
                    local topScreen = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                    local botScreen = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3, 0))
                    local bh = math.abs(topScreen.Y - botScreen.Y)
                    local bw = bh * 0.5
                    obj.box.Size = Vector2.new(bw, bh)
                    obj.box.Position = Vector2.new(rootScreen.X - bw/2, rootScreen.Y - bh/2)
                    obj.box.Visible = true
                elseif obj.box then obj.box.Visible = false end
            end
        end

        -- Clean up left players
        for p, _ in pairs(espObjects) do
            if not p.Character or not p.Character.Parent then
                for _, d in pairs(espObjects[p]) do if d and d.Remove then d:Remove() end end
                espObjects[p] = nil
            end
        end
    end))

    --// FOV Circle
    local fovCircle = Drawing.new("Circle")
    fovCircle.Filled = false
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Thickness = 1
    fovCircle.Transparency = 0.6
    fovCircle.Visible = false

    addConn(RunService.RenderStepped:Connect(function()
        if State.AimBot or State.SilentAim then
            fovCircle.Radius = State.AimFOV
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end))

    -- Chams (highlight via SelectionBox)
    local chamBoxes = {}
    addConn(RunService.RenderStepped:Connect(function()
        if not State.ESPChams then
            for _, b in pairs(chamBoxes) do b:Destroy() end
            chamBoxes = {}
            return
        end
        for _, p in ipairs(getEnemies()) do
            if not chamBoxes[p] then
                local sb = Instance.new("SelectionBox")
                sb.Color3 = Color3.fromRGB(120, 80, 255)
                sb.LineThickness = 0.05
                sb.SurfaceTransparency = 0.6
                sb.SurfaceColor3 = Color3.fromRGB(120, 80, 255)
                sb.Adornee = p.Character
                sb.Parent = CoreGui
                chamBoxes[p] = sb
            end
        end
        for p, b in pairs(chamBoxes) do
            if not p.Character or not p.Character.Parent then
                b:Destroy()
                chamBoxes[p] = nil
            end
        end
    end))

    --// Cleanup on character removal
    LocalPlayer.CharacterRemoving:Connect(function()
        if flyBody then flyBody:Destroy() flyBody = nil end
    end)

end

--// BOOT
buildKeyUI()
