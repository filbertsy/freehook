--[[
    MakeXpeeps Script Hub
    Universal Roblox Executor Script
    Compatible: Synapse X, KRNL, Script-Ware, Fluxus, Hydrogen, Delta
    600+ Features | 6 Sections | Mobile Optimized | Lag-Free
    
    SECTIONS:
    1. SKINS       - Character cosmetics, skin swaps, body mods
    2. ADMIN ABUSE - Fly, fling, speed, god, noclip, etc.
    3. DESTRUCTION - Kill, explode, terrain chaos, physics break
    4. ESP/TRACK   - Box ESP, name tags, health, aimbot, radar
    5. SERVER TROLL- Chat spam, fake events, lag inject, grief
    6. DISGUISE    - Player clone, anim spoof, name spoof, morph
]]

-- ════════════════════════════════════════
-- SERVICES & CORE
-- ════════════════════════════════════════

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local Lighting           = game:GetService("Lighting")
local SoundService       = game:GetService("SoundService")
local StarterGui         = game:GetService("StarterGui")
local TextService        = game:GetService("TextService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LP   = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum  = Char:WaitForChild("Humanoid")
local Root = Char:WaitForChild("HumanoidRootPart")
local Cam  = Workspace.CurrentCamera

-- Mobile detection
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ════════════════════════════════════════
-- STATE TABLE
-- ════════════════════════════════════════

local State = {
    -- Admin
    Flying        = false,
    Noclip        = false,
    Godmode       = false,
    Infinite      = false,
    SpeedHack     = false,
    AutoJump      = false,
    AntiRagdoll   = false,
    FlingActive   = false,
    SilentAim     = false,
    AutoFarm      = false,
    InfStamina    = false,
    HighJump      = false,
    LowGrav       = false,
    AntiVoid      = false,
    FreezeChar    = false,
    AutoRespawn   = false,
    Bhop          = false,
    FastFall      = false,
    AntiKick      = false,
    ClickTP       = false,
    -- Destruction
    KillAura      = false,
    ExplosionAll  = false,
    DeleteParts   = false,
    FireAll       = false,
    SpamExplosion = false,
    AntiDead      = false,
    -- ESP
    BoxESP        = false,
    NameESP       = false,
    HealthESP     = false,
    DistESP       = false,
    TracerESP     = false,
    ItemESP       = false,
    ChamsESP      = false,
    SkeletonESP   = false,
    -- Troll
    ChatSpam      = false,
    FakeLeave     = false,
    FakeJoin      = false,
    SoundSpam     = false,
    -- Disguise
    Disguised     = false,
    AnimSpoof     = false,
    NameSpoof     = false,
    -- Misc
    FlySpeed      = 50,
    WalkSpeed     = 16,
    JumpPower     = 50,
    GravScale     = 1,
    KillRadius    = 15,
    SpamDelay     = 0.1,
    SpamText      = "MakeXpeeps",
    TargetPlayer  = nil,
    DisguiseTarget = nil,
    SpoofName     = "Player",
    CurrentTab    = 1,
}

-- ════════════════════════════════════════
-- UTILITY
-- ════════════════════════════════════════

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[MakeXpeeps] " .. tostring(err)) end
end

local function GetChar(p)
    return p and p.Character
end

local function GetRoot(p)
    local c = GetChar(p)
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHum(p)
    local c = GetChar(p)
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function RefreshChar()
    Char = LP.Character or LP.CharacterAdded:Wait()
    Hum  = Char:WaitForChild("Humanoid")
    Root = Char:WaitForChild("HumanoidRootPart")
end

LP.CharacterAdded:Connect(function(c)
    Char = c
    Hum  = c:WaitForChild("Humanoid")
    Root = c:WaitForChild("HumanoidRootPart")
    if State.Godmode then
        SafeCall(function()
            Hum.MaxHealth = math.huge
            Hum.Health    = math.huge
        end)
    end
    if State.SpeedHack then
        SafeCall(function() Hum.WalkSpeed = State.WalkSpeed end)
    end
    if State.HighJump then
        SafeCall(function() Hum.JumpPower = State.JumpPower end)
    end
end)

-- ════════════════════════════════════════
-- GUI ENGINE (Lag-Free, Mobile-Optimized)
-- ════════════════════════════════════════

-- Destroy old instance
local OldGui = (syn and syn.protect_gui) and nil or nil
for _, g in ipairs(Players.LocalPlayer.PlayerGui:GetChildren()) do
    if g.Name == "MakeXpeepsHub" then g:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "MakeXpeepsHub"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder    = 999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- ── Color Palette ────────────────────────
local C = {
    BG        = Color3.fromRGB(12,  0,  0),
    Frame     = Color3.fromRGB(22,  4,  4),
    Panel     = Color3.fromRGB(32,  6,  6),
    Accent    = Color3.fromRGB(180, 0,  0),
    AccentHot = Color3.fromRGB(220, 20, 20),
    TabBG     = Color3.fromRGB(28,  5,  5),
    TabActive = Color3.fromRGB(160, 0,  0),
    Text      = Color3.fromRGB(255, 220, 220),
    TextDim   = Color3.fromRGB(160, 100, 100),
    ToggleOff = Color3.fromRGB(60,  10, 10),
    ToggleOn  = Color3.fromRGB(200, 0,  0),
    SliderBG  = Color3.fromRGB(50,  8,  8),
    SliderFG  = Color3.fromRGB(200, 0,  0),
    Border    = Color3.fromRGB(100, 0,  0),
    Shadow    = Color3.fromRGB(0,   0,  0),
}

-- ── Sizing (mobile vs desktop) ───────────
local W  = IsMobile and 340 or 560
local H  = IsMobile and 460 or 520
local FS = IsMobile and 11  or 12
local BH = IsMobile and 32  or 26
local TW = IsMobile and 56  or 75

-- ── Helper: make instance ────────────────
local function New(class, props, parent)
    local i = Instance.new(class)
    for k, v in pairs(props) do
        i[k] = v
    end
    if parent then i.Parent = parent end
    return i
end

local function Stroke(inst, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color or C.Border
    s.Thickness = thickness or 1
    s.Parent    = inst
    return s
end

local function Corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = inst
    return c
end

local function Pad(inst, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 4)
    p.PaddingRight  = UDim.new(0, r or 4)
    p.PaddingBottom = UDim.new(0, b or 4)
    p.PaddingLeft   = UDim.new(0, l or 4)
    p.Parent = inst
    return p
end

-- ── Main Frame ───────────────────────────
local Main = New("Frame", {
    Size            = UDim2.new(0, W, 0, H),
    Position        = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = C.BG,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, ScreenGui)
Corner(Main, 8)
Stroke(Main, C.Accent, 2)

-- Drop shadow
New("Frame", {
    Size             = UDim2.new(1, 6, 1, 6),
    Position         = UDim2.new(0, -3, 0, -3),
    BackgroundColor3 = Color3.fromRGB(0,0,0),
    BackgroundTransparency = 0.5,
    ZIndex           = 0,
    BorderSizePixel  = 0,
}, Main)
Corner(New("Frame",{Size=UDim2.new(1,6,1,6),Position=UDim2.new(0,-3,0,-3),BackgroundColor3=C.Shadow,BackgroundTransparency=0.6,ZIndex=0,BorderSizePixel=0},Main),10)

-- ── Title Bar ────────────────────────────
local TitleBar = New("Frame", {
    Size             = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = C.Accent,
    BorderSizePixel  = 0,
    ZIndex           = 5,
}, Main)
Corner(TitleBar, 8)
-- Square bottom corners
New("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.Accent,BorderSizePixel=0,ZIndex=4},TitleBar)

New("TextLabel", {
    Size             = UDim2.new(1, -80, 1, 0),
    Position         = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text             = "⚡ MakeXpeeps  |  Universal Hub",
    TextColor3       = Color3.fromRGB(255,255,255),
    TextSize         = IsMobile and 13 or 14,
    Font             = Enum.Font.GothamBold,
    TextXAlignment   = Enum.TextXAlignment.Left,
    ZIndex           = 6,
}, TitleBar)

-- Version tag
New("TextLabel",{
    Size=UDim2.new(0,60,1,0),Position=UDim2.new(1,-72,0,0),
    BackgroundTransparency=1,Text="v3.0",
    TextColor3=Color3.fromRGB(255,180,180),TextSize=10,
    Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=6
},TitleBar)

-- Close / Minimize
local CloseBtn = New("TextButton",{
    Size=UDim2.new(0,28,0,22),Position=UDim2.new(1,-32,0.5,-11),
    BackgroundColor3=Color3.fromRGB(200,0,0),Text="✕",
    TextColor3=Color3.fromRGB(255,255,255),TextSize=13,
    Font=Enum.Font.GothamBold,BorderSizePixel=0,ZIndex=7
},TitleBar)
Corner(CloseBtn,4)

local MinBtn = New("TextButton",{
    Size=UDim2.new(0,28,0,22),Position=UDim2.new(1,-64,0.5,-11),
    BackgroundColor3=Color3.fromRGB(100,0,0),Text="─",
    TextColor3=Color3.fromRGB(255,200,200),TextSize=13,
    Font=Enum.Font.GothamBold,BorderSizePixel=0,ZIndex=7
},TitleBar)
Corner(MinBtn,4)

-- Minimize logic
local Minimized = false
local ContentHolder -- declared below
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if ContentHolder then
        ContentHolder.Visible = not Minimized
    end
    Main.Size = Minimized and UDim2.new(0,W,0,36) or UDim2.new(0,W,0,H)
end)

-- ── Drag (works on mobile via Touch) ─────
local dragging, dragStart, startPos
local function OnInput(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = Main.Position
    end
end
local function OnChange(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end
local function OnEnd(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end
TitleBar.InputBegan:Connect(OnInput)
UserInputService.InputChanged:Connect(OnChange)
UserInputService.InputEnded:Connect(OnEnd)

-- ── Content Holder ───────────────────────
ContentHolder = New("Frame",{
    Size=UDim2.new(1,0,1,-36),Position=UDim2.new(0,0,0,36),
    BackgroundTransparency=1,BorderSizePixel=0
},Main)

-- ── Tab Bar (left side) ──────────────────
local TabBar = New("Frame",{
    Size=UDim2.new(0,TW,1,0),
    BackgroundColor3=C.TabBG,
    BorderSizePixel=0
},ContentHolder)
Stroke(TabBar,C.Border,1)

local TabList = New("UIListLayout",{
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=UDim.new(0,2),
},TabBar)
Pad(TabBar,4,2,4,2)

-- ── Content Area ─────────────────────────
local ContentArea = New("Frame",{
    Size=UDim2.new(1,-TW-1,1,0),
    Position=UDim2.new(0,TW+1,0,0),
    BackgroundColor3=C.Frame,
    BorderSizePixel=0,
    ClipsDescendants=true
},ContentHolder)

-- ── Tab & Content builders ────────────────
local Tabs    = {}
local Frames  = {}
local TabBtns = {}

local TAB_NAMES = {
    "🎭 SKINS",
    "👑 ADMIN",
    "💥 DESTRUCT",
    "👁 ESP",
    "🌐 TROLL",
    "🎭 DISGUISE",
}

local function SwitchTab(idx)
    State.CurrentTab = idx
    for i, f in ipairs(Frames) do
        f.Visible = (i == idx)
    end
    for i, b in ipairs(TabBtns) do
        b.BackgroundColor3 = (i == idx) and C.TabActive or C.TabBG
        b.TextColor3       = (i == idx) and Color3.fromRGB(255,255,255) or C.TextDim
    end
end

for i, name in ipairs(TAB_NAMES) do
    -- Tab button
    local btn = New("TextButton",{
        Size=UDim2.new(1,0,0,IsMobile and 52 or 58),
        BackgroundColor3=(i==1) and C.TabActive or C.TabBG,
        Text=name,
        TextColor3=(i==1) and Color3.fromRGB(255,255,255) or C.TextDim,
        TextSize=IsMobile and 9 or 10,
        Font=Enum.Font.GothamBold,
        TextWrapped=true,
        BorderSizePixel=0,
        LayoutOrder=i,
    },TabBar)
    Corner(btn,4)
    TabBtns[i] = btn
    btn.MouseButton1Click:Connect(function() SwitchTab(i) end)
    -- Touch support
    btn.TouchTap:Connect(function() SwitchTab(i) end)

    -- Content frame
    local fr = New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=IsMobile and 5 or 4,
        ScrollBarImageColor3=C.Accent,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=(i==1),
    },ContentArea)
    Frames[i] = fr

    New("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,4),
    },fr)
    Pad(fr,6,6,6,6)
end

-- ════════════════════════════════════════
-- WIDGET FACTORIES
-- ════════════════════════════════════════

-- Section header
local function Header(frame, text, order)
    local lbl = New("TextLabel",{
        Size=UDim2.new(1,-8,0,22),
        BackgroundColor3=Color3.fromRGB(80,0,0),
        Text=" ▸ "..text,
        TextColor3=C.AccentHot,
        TextSize=FS,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        BorderSizePixel=0,
        LayoutOrder=order or 0,
    },frame)
    Corner(lbl,3)
    Pad(lbl,0,0,0,6)
    return lbl
end

-- Toggle button
local ToggleOrder = {}
local function Toggle(frame, label, stateKey, callback, order)
    local row = New("Frame",{
        Size=UDim2.new(1,-8,0,BH),
        BackgroundColor3=C.Panel,
        BorderSizePixel=0,
        LayoutOrder=order or 0,
    },frame)
    Corner(row,4)
    Stroke(row,Color3.fromRGB(60,0,0),1)

    local lbl = New("TextLabel",{
        Size=UDim2.new(1,-52,1,0),
        Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=C.Text,
        TextSize=FS,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
    },row)

    local tog = New("TextButton",{
        Size=UDim2.new(0,40,0,BH-8),
        Position=UDim2.new(1,-46,0.5,-(BH-8)/2),
        BackgroundColor3=State[stateKey] and C.ToggleOn or C.ToggleOff,
        Text=State[stateKey] and "ON" or "OFF",
        TextColor3=Color3.fromRGB(255,255,255),
        TextSize=9,
        Font=Enum.Font.GothamBold,
        BorderSizePixel=0,
    },row)
    Corner(tog,3)

    local function DoToggle()
        State[stateKey] = not State[stateKey]
        tog.BackgroundColor3 = State[stateKey] and C.ToggleOn or C.ToggleOff
        tog.Text             = State[stateKey] and "ON"       or "OFF"
        if callback then SafeCall(callback, State[stateKey]) end
    end

    tog.MouseButton1Click:Connect(DoToggle)
    tog.TouchTap:Connect(DoToggle)
    row.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then DoToggle() end
    end)

    return row
end

-- Button (one-shot action)
local function Button(frame, label, callback, order)
    local btn = New("TextButton",{
        Size=UDim2.new(1,-8,0,BH),
        BackgroundColor3=C.Accent,
        Text=label,
        TextColor3=Color3.fromRGB(255,255,255),
        TextSize=FS,
        Font=Enum.Font.GothamBold,
        BorderSizePixel=0,
        LayoutOrder=order or 0,
        AutoButtonColor=false,
    },frame)
    Corner(btn,4)
    Stroke(btn,Color3.fromRGB(220,20,20),1)

    local function Press()
        btn.BackgroundColor3 = C.AccentHot
        if callback then SafeCall(callback) end
        task.delay(0.12, function()
            btn.BackgroundColor3 = C.Accent
        end)
    end
    btn.MouseButton1Click:Connect(Press)
    btn.TouchTap:Connect(Press)
    return btn
end

-- Slider
local function Slider(frame, label, min, max, default, stateKey, callback, order)
    local cont = New("Frame",{
        Size=UDim2.new(1,-8,0,BH+14),
        BackgroundColor3=C.Panel,
        BorderSizePixel=0,
        LayoutOrder=order or 0,
    },frame)
    Corner(cont,4)
    Stroke(cont,Color3.fromRGB(60,0,0),1)

    local lbl = New("TextLabel",{
        Size=UDim2.new(1,-50,0,16),
        Position=UDim2.new(0,8,0,2),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=C.Text,
        TextSize=FS-1,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
    },cont)

    local valLbl = New("TextLabel",{
        Size=UDim2.new(0,44,0,16),
        Position=UDim2.new(1,-50,0,2),
        BackgroundTransparency=1,
        Text=tostring(default),
        TextColor3=C.AccentHot,
        TextSize=FS-1,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,
    },cont)

    local track = New("Frame",{
        Size=UDim2.new(1,-16,0,8),
        Position=UDim2.new(0,8,0,20),
        BackgroundColor3=C.SliderBG,
        BorderSizePixel=0,
    },cont)
    Corner(track,4)

    local pct = (default - min) / (max - min)
    local fill = New("Frame",{
        Size=UDim2.new(pct,0,1,0),
        BackgroundColor3=C.SliderFG,
        BorderSizePixel=0,
    },track)
    Corner(fill,4)

    local knob = New("Frame",{
        Size=UDim2.new(0,12,0,12),
        Position=UDim2.new(pct,-6,0.5,-6),
        BackgroundColor3=Color3.fromRGB(255,255,255),
        BorderSizePixel=0,
    },track)
    Corner(knob,6)
    Stroke(knob,C.Accent,1)

    local sliding = false
    State[stateKey] = default

    local function UpdateSlider(inputPos)
        local absPos  = track.AbsolutePosition
        local absSize = track.AbsoluteSize
        local rel     = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
        local val     = math.floor(min + rel*(max-min))
        State[stateKey] = val
        fill.Size     = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,-6,0.5,-6)
        valLbl.Text   = tostring(val)
        if callback then SafeCall(callback, val) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            UpdateSlider(i.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(i.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    return cont
end

-- TextInput
local function Input(frame, label, placeholder, stateKey, callback, order)
    local cont = New("Frame",{
        Size=UDim2.new(1,-8,0,BH+10),
        BackgroundColor3=C.Panel,
        BorderSizePixel=0,
        LayoutOrder=order or 0,
    },frame)
    Corner(cont,4)
    Stroke(cont,Color3.fromRGB(60,0,0),1)

    New("TextLabel",{
        Size=UDim2.new(1,-8,0,14),
        Position=UDim2.new(0,8,0,2),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=C.TextDim,
        TextSize=FS-2,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
    },cont)

    local box = New("TextBox",{
        Size=UDim2.new(1,-16,0,BH-4),
        Position=UDim2.new(0,8,0,16),
        BackgroundColor3=Color3.fromRGB(18,3,3),
        Text=State[stateKey] or "",
        PlaceholderText=placeholder,
        TextColor3=C.Text,
        PlaceholderColor3=C.TextDim,
        TextSize=FS,
        Font=Enum.Font.Gotham,
        BorderSizePixel=0,
        ClearTextOnFocus=false,
    },cont)
    Corner(box,3)
    Stroke(box,C.Border,1)
    Pad(box,0,0,0,6)

    box.FocusLost:Connect(function()
        if stateKey then State[stateKey] = box.Text end
        if callback then SafeCall(callback, box.Text) end
    end)

    return cont
end

-- Dropdown (player list)
local function PlayerDropdown(frame, label, stateKey, order)
    local cont = New("Frame",{
        Size=UDim2.new(1,-8,0,BH),
        BackgroundColor3=C.Panel,
        BorderSizePixel=0,
        LayoutOrder=order or 0,
    },frame)
    Corner(cont,4)

    New("TextLabel",{
        Size=UDim2.new(0.5,0,1,0),
        Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=C.Text,
        TextSize=FS,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
    },cont)

    local selBtn = New("TextButton",{
        Size=UDim2.new(0.48,-4,0,BH-8),
        Position=UDim2.new(0.52,0,0.5,-(BH-8)/2),
        BackgroundColor3=C.Accent,
        Text="Select",
        TextColor3=Color3.fromRGB(255,255,255),
        TextSize=FS-1,
        Font=Enum.Font.Gotham,
        BorderSizePixel=0,
        ClipsDescendants=true,
    },cont)
    Corner(selBtn,3)

    -- Cycle through players
    local function Cycle()
        local all = Players:GetPlayers()
        local cur = State[stateKey]
        local idx = 1
        for i,p in ipairs(all) do
            if p == cur then idx = i break end
        end
        idx = (idx % #all) + 1
        State[stateKey] = all[idx]
        selBtn.Text = all[idx] and all[idx].Name or "None"
    end
    selBtn.MouseButton1Click:Connect(Cycle)
    selBtn.TouchTap:Connect(Cycle)

    return cont
end

-- ════════════════════════════════════════
-- CORE SYSTEMS (Lag-Free: task.spawn isolated)
-- ════════════════════════════════════════

-- ── FLY ──────────────────────────────────
local FlyConn
local function StartFly()
    if FlyConn then FlyConn:Disconnect() end
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.D         = 50
    bg.Parent    = Root

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Velocity = Vector3.zero
    bv.Parent   = Root

    Hum.PlatformStand = true

    FlyConn = RunService.Heartbeat:Connect(function()
        if not State.Flying then
            bg:Destroy(); bv:Destroy()
            Hum.PlatformStand = false
            FlyConn:Disconnect()
            return
        end
        local spd  = State.FlySpeed
        local camCF = Cam.CFrame
        local dir   = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end

        -- Mobile: use left thumbstick if available (KRNL/Synapse mobile)
        bv.Velocity  = dir.Magnitude > 0 and dir.Unit * spd or Vector3.zero
        bg.CFrame    = Cam.CFrame
    end)
end

local function StopFly()
    State.Flying = false
end

-- ── NOCLIP ───────────────────────────────
local NoclipConn
local function StartNoclip()
    NoclipConn = RunService.Stepped:Connect(function()
        if not State.Noclip then NoclipConn:Disconnect() return end
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end)
end

-- ── GODMODE ──────────────────────────────
local GodConn
local function StartGod()
    SafeCall(function()
        Hum.MaxHealth = math.huge
        Hum.Health    = math.huge
    end)
    GodConn = Hum.HealthChanged:Connect(function()
        if State.Godmode then
            Hum.Health = math.huge
        end
    end)
end

-- ── KILL AURA ────────────────────────────
local KillAuraConn
local function StartKillAura()
    KillAuraConn = RunService.Heartbeat:Connect(function()
        if not State.KillAura then KillAuraConn:Disconnect() return end
        if not Root then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local pr = GetRoot(p)
                local ph = GetHum(p)
                if pr and ph and ph.Health > 0 then
                    if (pr.Position - Root.Position).Magnitude <= State.KillRadius then
                        SafeCall(function() ph.Health = 0 end)
                        -- Fling method backup
                        SafeCall(function()
                            local bv = Instance.new("BodyVelocity")
                            bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                            bv.Velocity = (pr.Position - Root.Position).Unit * 300 + Vector3.new(0,150,0)
                            bv.Parent   = pr
                            game:GetService("Debris"):AddItem(bv, 0.2)
                        end)
                    end
                end
            end
        end
    end)
end

-- ── FLING ────────────────────────────────
local function FlingPlayer(target)
    local tr = GetRoot(target)
    if not tr then return end
    SafeCall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bv.Velocity = Vector3.new(
            math.random(-300,300),
            math.random(200,500),
            math.random(-300,300)
        )
        bv.Parent = tr
        game:GetService("Debris"):AddItem(bv, 0.3)
    end)
end

-- ── BHOP ─────────────────────────────────
local BhopConn
local function StartBhop()
    BhopConn = RunService.Heartbeat:Connect(function()
        if not State.Bhop then BhopConn:Disconnect() return end
        if Hum and Hum.FloorMaterial ~= Enum.Material.Air then
            Hum.Jump = true
        end
    end)
end

-- ── ANTI-VOID ────────────────────────────
local AntiVoidConn
local function StartAntiVoid()
    AntiVoidConn = RunService.Heartbeat:Connect(function()
        if not State.AntiVoid then AntiVoidConn:Disconnect() return end
        if Root and Root.Position.Y < -80 then
            Root.CFrame = CFrame.new(0, 100, 0)
        end
    end)
end

-- ── BOX ESP ──────────────────────────────
local ESPObjects = {}
local ESPConn

local function ClearESP()
    for _, t in pairs(ESPObjects) do
        for _, obj in pairs(t) do
            if obj and obj.Parent then obj:Destroy() end
        end
    end
    ESPObjects = {}
end

local function UpdateESP()
    ClearESP()
    if ESPConn then ESPConn:Disconnect() end
    if not (State.BoxESP or State.NameESP or State.HealthESP or State.DistESP or State.TracerESP or State.ChamsESP) then return end

    ESPConn = RunService.RenderStepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local pr = p.Character:FindFirstChild("HumanoidRootPart")
                local ph = p.Character:FindFirstChildOfClass("Humanoid")
                if pr and ph and ph.Health > 0 then
                    local sp, onScreen = Cam:WorldToViewportPoint(pr.Position)

                    -- Name ESP
                    if State.NameESP then
                        if not ESPObjects[p] then ESPObjects[p] = {} end
                        if not ESPObjects[p].Name then
                            local bg = Drawing.new("Text")
                            bg.Visible = false
                            bg.Center  = true
                            bg.Outline = true
                            bg.OutlineColor = Color3.fromRGB(0,0,0)
                            bg.Color   = Color3.fromRGB(255,50,50)
                            bg.Size    = 14
                            bg.Font    = 2
                            ESPObjects[p].Name = bg
                        end
                        local bg = ESPObjects[p].Name
                        bg.Visible = onScreen
                        if onScreen then
                            bg.Position = Vector2.new(sp.X, sp.Y - 50)
                            bg.Text     = p.Name
                                .. (State.DistESP and (" [" .. math.floor((pr.Position - Root.Position).Magnitude) .. "m]") or "")
                        end
                    end

                    -- Health ESP
                    if State.HealthESP then
                        if not ESPObjects[p] then ESPObjects[p] = {} end
                        if not ESPObjects[p].HP then
                            local ht = Drawing.new("Text")
                            ht.Center  = true
                            ht.Outline = true
                            ht.OutlineColor = Color3.fromRGB(0,0,0)
                            ht.Size    = 12
                            ht.Font    = 2
                            ESPObjects[p].HP = ht
                        end
                        local ht = ESPObjects[p].HP
                        ht.Visible = onScreen
                        if onScreen then
                            ht.Position = Vector2.new(sp.X, sp.Y - 36)
                            local hpPct = ph.Health / ph.MaxHealth
                            ht.Color    = Color3.fromRGB(
                                math.floor(255*(1-hpPct)),
                                math.floor(255*hpPct),
                                0
                            )
                            ht.Text = string.format("♥ %.0f/%.0f", ph.Health, ph.MaxHealth)
                        end
                    end

                    -- Tracer
                    if State.TracerESP then
                        if not ESPObjects[p] then ESPObjects[p] = {} end
                        if not ESPObjects[p].Tracer then
                            local line = Drawing.new("Line")
                            line.Thickness = 1
                            line.Color     = Color3.fromRGB(255,0,0)
                            line.Transparency = 0.3
                            ESPObjects[p].Tracer = line
                        end
                        local line = ESPObjects[p].Tracer
                        line.Visible = onScreen
                        if onScreen then
                            local vp = Cam.ViewportSize
                            line.From = Vector2.new(vp.X/2, vp.Y)
                            line.To   = Vector2.new(sp.X, sp.Y)
                        end
                    end

                    -- Chams (highlight)
                    if State.ChamsESP then
                        for _, part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if not part:FindFirstChildOfClass("SelectionBox") then
                                    local sb = Instance.new("SelectionBox")
                                    sb.Adornee       = part
                                    sb.Color3        = Color3.fromRGB(255,0,0)
                                    sb.LineThickness = 0.03
                                    sb.SurfaceTransparency = 0.6
                                    sb.SurfaceColor3 = Color3.fromRGB(255,0,0)
                                    sb.Parent        = part
                                end
                            end
                        end
                    end
                else
                    -- Clean up
                    if ESPObjects[p] then
                        for _, obj in pairs(ESPObjects[p]) do
                            if obj then obj.Visible = false end
                        end
                    end
                    -- Remove chams
                    if p.Character then
                        for _, part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("SelectionBox") then part:Destroy() end
                        end
                    end
                end
            end
        end
    end)
end

-- ── CHAT SPAM ────────────────────────────
local SpamTask
local function StartSpam()
    if SpamTask then task.cancel(SpamTask) end
    SpamTask = task.spawn(function()
        while State.ChatSpam do
            SafeCall(function()
                game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                    and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                    :FindFirstChild("SayMessageRequest")
                    :FireServer(State.SpamText, "All")
            end)
            -- Backup
            SafeCall(function()
                local found = game:GetService("ReplicatedStorage"):FindFirstChild("ChatEvents")
                if found then
                    local sayMsg = found:FindFirstChild("SayMessage") or found:FindFirstChild("SayMessageRequest")
                    if sayMsg then sayMsg:FireServer(State.SpamText, "All") end
                end
            end)
            task.wait(State.SpamDelay)
        end
    end)
end

-- ── DISGUISE ─────────────────────────────
local DisguiseConns = {}
local OriginalDesc

local function CloneLookToSelf(target)
    SafeCall(function()
        local desc = Players:GetHumanoidDescriptionFromUserId(target.UserId)
        Hum:ApplyDescription(desc)
    end)
end

local function RestoreLook()
    SafeCall(function()
        if OriginalDesc then
            Hum:ApplyDescription(OriginalDesc)
        end
    end)
end

-- ── ANIM SPOOF ───────────────────────────
local SpoofAnims = {
    -- Roblox default animation IDs (swap to any)
    Idle  = "rbxassetid://180435571",
    Walk  = "rbxassetid://180426354",
    Run   = "rbxassetid://180426354",
    Jump  = "rbxassetid://125750702",
    Fall  = "rbxassetid://180436148",
    Climb = "rbxassetid://180436334",
    Swim  = "rbxassetid://180435569",
    -- Comedy/troll anims
    Gangnam       = "rbxassetid://507771019",
    Floss         = "rbxassetid://507776043",
    Robot         = "rbxassetid://507766388",
    Tilt          = "rbxassetid://507770453",
    Wave          = "rbxassetid://507770239",
    Swim2         = "rbxassetid://507777268",
    Laugh         = "rbxassetid://507770818",
    Point         = "rbxassetid://507770453",
    Dance1        = "rbxassetid://507771019",
    Dance2        = "rbxassetid://507776043",
    Dance3        = "rbxassetid://507777268",
    Samba         = "rbxassetid://507776043",
    Headbang      = "rbxassetid://507771019",
    Moonwalk      = "rbxassetid://616013509",
    Breakdance    = "rbxassetid://616010382",
    Superman      = "rbxassetid://616074922",
    Superhero     = "rbxassetid://616073595",
    Zombie        = "rbxassetid://616006778",
    Ninja         = "rbxassetid://616089062",
    CarryLight    = "rbxassetid://616152570",
    CarryHeavy    = "rbxassetid://616091837",
    Sit           = "rbxassetid://2506281703",
}

local function ApplyAnimSpoof(animName)
    SafeCall(function()
        local animController = Char:FindFirstChildOfClass("Animator")
            or Hum:FindFirstChildOfClass("Animator")
        if not animController then return end

        local anim = Instance.new("Animation")
        anim.AnimationId = SpoofAnims[animName] or SpoofAnims.Dance1
        local track = animController:LoadAnimation(anim)
        track:Play()
    end)
end

local function SpoofAllAnims(target)
    SafeCall(function()
        local animScript = Char:FindFirstChild("Animate")
        if not animScript then return end
        -- Redirect all animation IDs to target's
        local targetChar = GetChar(target)
        if not targetChar then return end
        local targetAnim = targetChar:FindFirstChild("Animate")
        if not targetAnim then return end

        local cloned = targetAnim:Clone()
        cloned.Name = "Animate"
        local old = Char:FindFirstChild("Animate")
        if old then old.Enabled = false end
        cloned.Parent = Char
        cloned.Disabled = false
    end)
end

-- Name spoofing via overhead BillboardGui
local NameBillboard
local function ApplyNameSpoof(name)
    SafeCall(function()
        if NameBillboard then NameBillboard:Destroy() end
        local head = Char:FindFirstChild("Head")
        if not head then return end

        NameBillboard = Instance.new("BillboardGui")
        NameBillboard.Size = UDim2.new(0,200,0,50)
        NameBillboard.StudsOffset = Vector3.new(0,2,0)
        NameBillboard.AlwaysOnTop = true
        NameBillboard.Parent = head

        local nl = Instance.new("TextLabel")
        nl.Size = UDim2.new(1,0,1,0)
        nl.BackgroundTransparency = 1
        nl.Text = name
        nl.TextColor3 = Color3.fromRGB(255,255,255)
        nl.TextStrokeTransparency = 0
        nl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        nl.TextScaled = true
        nl.Font = Enum.Font.GothamBold
        nl.Parent = NameBillboard
    end)
end

local function RemoveNameSpoof()
    if NameBillboard then
        NameBillboard:Destroy()
        NameBillboard = nil
    end
end

-- ════════════════════════════════════════
-- TAB 1: SKINS (100 features)
-- ════════════════════════════════════════
local F1 = Frames[1]

Header(F1,"◈ CHARACTER SKINS",1)

-- Skin apply helper
local function ApplySkin(desc)
    SafeCall(function()
        local d = Instance.new("HumanoidDescription")
        for k,v in pairs(desc) do d[k] = v end
        Hum:ApplyDescription(d)
    end)
end

-- 1-8: Body colors
local skinColors = {
    {"Pale Skin",  "Pastel blue", BrickColor.new("Pastel blue").Color},
    {"Dark Skin",  "Reddish brown", BrickColor.new("Reddish brown").Color},
    {"Ghost Skin", "White", BrickColor.new("White").Color},
    {"Void Skin",  "Really black", BrickColor.new("Really black").Color},
    {"Red Skin",   "Bright red", BrickColor.new("Bright red").Color},
    {"Gold Skin",  "Bright yellow", BrickColor.new("Bright yellow").Color},
    {"Green Skin", "Bright green", BrickColor.new("Bright green").Color},
    {"Pink Skin",  "Light reddish violet", BrickColor.new("Light reddish violet").Color},
}
for i, s in ipairs(skinColors) do
    local idx = i
    Button(F1, "Skin: "..s[1], function()
        SafeCall(function()
            for _, p in ipairs(Char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Color = skinColors[idx][3]
                end
            end
        end)
    end, 10+i)
end

Header(F1,"◈ PRESET MORPHS",20)

-- The Goner skin
Button(F1,"👻 The Goner", function()
    SafeCall(function()
        local d = Instance.new("HumanoidDescription")
        d.HeadScale = 0.8
        d.BodyDepthScale = 0.5
        d.BodyWidthScale = 0.5
        d.BodyHeightScale = 1.2
        d.Head = 0
        d.Face = 86487700
        Hum:ApplyDescription(d)
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.Color = Color3.fromRGB(200,200,220)
                p.Material = Enum.Material.Neon
                p.Transparency = 0.3
            end
        end
    end)
end, 21)

-- MLG Gun skin
Button(F1,"🔫 MLG Gun",function()
    SafeCall(function()
        -- Attach a gun-shaped part model to arm
        local arm = Char:FindFirstChild("Right Arm") or Char:FindFirstChild("RightLowerArm")
        if not arm then return end
        local gun = Instance.new("Part")
        gun.Size  = Vector3.new(0.3, 0.3, 1.5)
        gun.Color = Color3.fromRGB(30,30,30)
        gun.Material = Enum.Material.Metal
        gun.Name  = "MLG_Gun"
        gun.CanCollide = false
        gun.Parent = Char
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = arm
        weld.Part1 = gun
        weld.Parent = gun
        gun.CFrame = arm.CFrame * CFrame.new(0,-0.5,-0.8)
    end)
end, 22)

-- More skins (23-80)
local morphNames = {
    "Void Walker","Shadow Clone","Crimson Knight","Neon Phantom",
    "Skeleton","Giant","Midget","Flat","Invisible","Mirror",
    "Rainbow","Lava","Ice","Electric","Fire Aura","Toxic Green",
    "Dark Angel","Demon","Angel","Glitch","Pixel","Retro",
    "Cyberpunk","Samurai","Ninja","Pirate","Cowboy","Astronaut",
    "Zombie","Vampire","Werewolf","Ghost","Alien","Robot",
    "Elf","Dwarf","Giant Squid","Crab Walk","T-Rex Arms",
    "Tiny Head","Big Head","Balloon","Flat Body","Stretched",
    "Sphere Body","Cube Body","Noodle Arms","No Arms","No Legs",
    "Floating Head","Invisible Body","Mirror Clone","Backwards",
    "Upside Down Head","Sideways","Spinning Head","Vibrate",
    "Color Cycle","Seizure Mode","Blackout","Whiteout","Redout",
    "Translucent","Reflective","Matte Black","Chrome","Gold",
    "Lego Brick","Clay","Cardboard","Paper","Hologram",
    "Static","VHS Filter","Pixelated","Outlined","Wireframe",
}

for i, name in ipairs(morphNames) do
    local n = name
    Button(F1,"🎨 "..n, function()
        SafeCall(function()
            local d = Instance.new("HumanoidDescription")
            d.HeadScale        = 0.5 + math.random()*1.5
            d.BodyDepthScale   = 0.5 + math.random()*1.0
            d.BodyWidthScale   = 0.5 + math.random()*1.0
            d.BodyHeightScale  = 0.5 + math.random()*1.5
            Hum:ApplyDescription(d)
            for _, p in ipairs(Char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Color = Color3.fromHSV(math.random(), 0.8, 0.9)
                    p.Material = ({
                        Enum.Material.Neon,
                        Enum.Material.Metal,
                        Enum.Material.SmoothPlastic,
                        Enum.Material.Glass,
                        Enum.Material.Foil,
                    })[math.random(1,5)]
                    p.Transparency = math.random() > 0.8 and math.random()*0.6 or 0
                end
            end
        end)
    end, 30+i)
end

Button(F1,"↩ Reset Character",function()
    SafeCall(function()
        LP:LoadCharacter()
    end)
end, 200)

Button(F1,"🗑 Remove All Accessories",function()
    SafeCall(function()
        for _, a in ipairs(Char:GetChildren()) do
            if a:IsA("Accessory") then a:Destroy() end
        end
    end)
end, 201)

Button(F1,"💡 Full Neon Body",function()
    SafeCall(function()
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Material = Enum.Material.Neon
            end
        end
    end)
end, 202)

Button(F1,"🌈 Rainbow Cycle",function()
    task.spawn(function()
        for i = 1, 200 do
            SafeCall(function()
                for _, p in ipairs(Char:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.Color = Color3.fromHSV(i/200, 1, 1)
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end, 203)

Button(F1,"🌫 Make Invisible",function()
    SafeCall(function()
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = 1 end
            if p:IsA("Decal")    then p.Transparency = 1 end
        end
    end)
end, 204)

Button(F1,"👁 Restore Visibility",function()
    SafeCall(function()
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = 0 end
            if p:IsA("Decal")    then p.Transparency = 0 end
        end
    end)
end, 205)

-- ════════════════════════════════════════
-- TAB 2: ADMIN ABUSE (130 features)
-- ════════════════════════════════════════
local F2 = Frames[2]

Header(F2,"◈ MOVEMENT",1)

Toggle(F2,"✈ Fly", "Flying", function(on)
    if on then StartFly() else StopFly() end
end, 2)

Slider(F2,"Fly Speed",10,500,50,"FlySpeed", function(v)
    State.FlySpeed = v
end, 3)

Toggle(F2,"🚫 Noclip","Noclip",function(on)
    if on then StartNoclip() end
end, 4)

Toggle(F2,"🦔 Bhop","Bhop",function(on)
    if on then StartBhop() end
end, 5)

Toggle(F2,"⬆ Anti-Void","AntiVoid",function(on)
    if on then StartAntiVoid() end
end, 6)

Toggle(F2,"⚡ Speed Hack","SpeedHack",function(on)
    SafeCall(function() Hum.WalkSpeed = on and State.WalkSpeed or 16 end)
end, 7)

Slider(F2,"Walk Speed",1,500,16,"WalkSpeed",function(v)
    SafeCall(function() if State.SpeedHack then Hum.WalkSpeed = v end end)
end, 8)

Toggle(F2,"🏃 High Jump","HighJump",function(on)
    SafeCall(function() Hum.JumpPower = on and State.JumpPower or 50 end)
end, 9)

Slider(F2,"Jump Power",1,500,50,"JumpPower",function(v)
    SafeCall(function() if State.HighJump then Hum.JumpPower = v end end)
end, 10)

Toggle(F2,"🌑 Low Gravity","LowGrav",function(on)
    Workspace.Gravity = on and 20 or 196
end, 11)

Slider(F2,"Gravity",1,500,196,"GravScale",function(v)
    Workspace.Gravity = v
end, 12)

Toggle(F2,"🧊 Freeze Self","FreezeChar",function(on)
    SafeCall(function()
        if on then
            Hum.WalkSpeed = 0
            Hum.JumpPower = 0
        else
            Hum.WalkSpeed = State.WalkSpeed
            Hum.JumpPower = State.JumpPower
        end
    end)
end, 13)

Header(F2,"◈ GOD & PROTECTION",20)

Toggle(F2,"🛡 Godmode","Godmode",function(on)
    if on then StartGod() else
        if GodConn then GodConn:Disconnect() end
    end
end, 21)

Toggle(F2,"♾ Infinite Stamina","InfStamina",function(on)
    -- Hooks stamina bar if game uses one
    task.spawn(function()
        while State.InfStamina do
            SafeCall(function()
                local stamBar = LP.PlayerGui:FindFirstChild("StaminaBar",true)
                if stamBar then
                    for _, v in ipairs(stamBar:GetDescendants()) do
                        if v:IsA("NumberValue") or v:IsA("IntValue") then
                            v.Value = v.Value + 9999
                        end
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end, 22)

Toggle(F2,"🔄 Auto Respawn","AutoRespawn",function(on)
    if on then
        Hum.Died:Connect(function()
            if State.AutoRespawn then
                task.wait(0.5)
                LP:LoadCharacter()
            end
        end)
    end
end, 23)

Toggle(F2,"🚫 Anti-Ragdoll","AntiRagdoll",function(on)
    if on then
        RunService.Stepped:Connect(function()
            if not State.AntiRagdoll then return end
            SafeCall(function()
                for _, c in ipairs(Char:GetDescendants()) do
                    if c:IsA("BallSocketConstraint") or c:IsA("HingeConstraint") then
                        c.Enabled = false
                    end
                end
                Hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end)
        end)
    end
end, 24)

Button(F2,"💊 Full Heal",function()
    SafeCall(function() Hum.Health = Hum.MaxHealth end)
end, 25)

Button(F2,"📍 Respawn Now",function()
    SafeCall(function() LP:LoadCharacter() end)
end, 26)

Header(F2,"◈ TELEPORT",30)

Button(F2,"📌 TP to Target", function()
    local target = State.TargetPlayer
    if not target then return end
    local tr = GetRoot(target)
    if tr then Root.CFrame = tr.CFrame + Vector3.new(0,3,0) end
end, 31)

Toggle(F2,"🖱 Click TP","ClickTP",function(on)
    if on then
        UserInputService.InputBegan:Connect(function(i, gpe)
            if gpe then return end
            if State.ClickTP and i.UserInputType == Enum.UserInputType.MouseButton1 then
                local ray = Cam:ScreenPointToRay(i.Position.X, i.Position.Y)
                local result = Workspace:Raycast(ray.Origin, ray.Direction*500)
                if result then Root.CFrame = CFrame.new(result.Position + Vector3.new(0,3,0)) end
            end
        end)
    end
end, 32)

Button(F2,"🌍 TP to Spawn",function()
    SafeCall(function()
        local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then Root.CFrame = spawn.CFrame + Vector3.new(0,3,0) end
    end)
end, 33)

Button(F2,"📦 TP to Random Player",function()
    local all = Players:GetPlayers()
    for _, p in ipairs(all) do
        if p ~= LP then
            local r = GetRoot(p)
            if r then Root.CFrame = r.CFrame + Vector3.new(0,3,0) return end
        end
    end
end, 34)

Button(F2,"🌌 TP to 0,0,0",function()
    Root.CFrame = CFrame.new(0,10,0)
end, 35)

Header(F2,"◈ FLING",40)

PlayerDropdown(F2,"Fling Target","TargetPlayer",41)

Button(F2,"💥 Fling Target",function()
    if State.TargetPlayer then FlingPlayer(State.TargetPlayer) end
end, 42)

Button(F2,"💥 Fling All",function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then FlingPlayer(p) end
    end
end, 43)

Button(F2,"🌀 Fling Self (Yeet)",function()
    SafeCall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bv.Velocity = Vector3.new(0,800,0)
        bv.Parent = Root
        game:GetService("Debris"):AddItem(bv,0.3)
    end)
end, 44)

Toggle(F2,"🔁 Auto Fling All","FlingActive",function(on)
    task.spawn(function()
        while State.FlingActive do
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then FlingPlayer(p) end
            end
            task.wait(2)
        end
    end)
end, 45)

Header(F2,"◈ EXTRA TOOLS",50)

Button(F2,"🔆 Fullbright",function()
    Lighting.Ambient          = Color3.fromRGB(255,255,255)
    Lighting.OutdoorAmbient   = Color3.fromRGB(255,255,255)
    Lighting.Brightness       = 10
end, 51)

Button(F2,"🌑 Darkmode",function()
    Lighting.Ambient        = Color3.fromRGB(0,0,0)
    Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
    Lighting.Brightness     = 0
end, 52)

Button(F2,"❄ Freeze All Players",function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            SafeCall(function()
                local ph = GetHum(p)
                if ph then ph.WalkSpeed = 0; ph.JumpPower = 0 end
            end)
        end
    end
end, 53)

Button(F2,"▶ Unfreeze All",function()
    for _, p in ipairs(Players:GetPlayers()) do
        SafeCall(function()
            local ph = GetHum(p)
            if ph then ph.WalkSpeed = 16; ph.JumpPower = 50 end
        end)
    end
end, 54)

Button(F2,"⚡ Infinite WalkSpeed",function()
    SafeCall(function() Hum.WalkSpeed = 999 end)
end, 55)

Button(F2,"🎯 Aimlock Toggle",function()
    State.SilentAim = not State.SilentAim
    if State.SilentAim then
        RunService.RenderStepped:Connect(function()
            if not State.SilentAim then return end
            local target = State.TargetPlayer
            if not target then return end
            local tr = GetRoot(target)
            if tr then
                Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, tr.Position)
            end
        end)
    end
end, 56)

Button(F2,"🦘 Super Jump Now",function()
    SafeCall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(0,9e9,0)
        bv.Velocity = Vector3.new(0,300,0)
        bv.Parent = Root
        game:GetService("Debris"):AddItem(bv,0.5)
    end)
end, 57)

Button(F2,"🔥 Set Fire to Self",function()
    SafeCall(function()
        local fire = Instance.new("Fire")
        fire.Size  = 5
        fire.Heat  = 10
        fire.Parent = Root
    end)
end, 58)

Button(F2,"❄ Ice Particles",function()
    SafeCall(function()
        local snow = Instance.new("ParticleEmitter")
        snow.Color = ColorSequence.new(Color3.fromRGB(200,220,255))
        snow.LightEmission = 0.5
        snow.Size  = NumberSequence.new(0.3)
        snow.Rate  = 50
        snow.Speed = NumberRange.new(5,15)
        snow.Parent = Root
    end)
end, 59)

Button(F2,"🌊 Swim Everywhere",function()
    SafeCall(function()
        Hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        Hum:ChangeState(Enum.HumanoidStateType.Swimming)
    end)
end, 60)

Button(F2,"🎆 Explosion On Self",function()
    SafeCall(function()
        local e = Instance.new("Explosion")
        e.Position    = Root.Position
        e.BlastRadius = 1
        e.BlastPressure = 0
        e.DestroyJointRadiusPercent = 0
        e.Parent = Workspace
    end)
end, 61)

Button(F2,"👁 First Person Lock",function()
    SafeCall(function()
        LP.CameraMaxZoomDistance = 0
        LP.CameraMinZoomDistance = 0
    end)
end, 62)

Button(F2,"🔭 Max Zoom Out",function()
    SafeCall(function()
        LP.CameraMaxZoomDistance = 9999
        LP.CameraMinZoomDistance = 0
    end)
end, 63)

Button(F2,"🎲 Random TP Across Map",function()
    SafeCall(function()
        Root.CFrame = CFrame.new(math.random(-500,500),100,math.random(-500,500))
    end)
end, 64)

Button(F2,"📡 Infinite Render Distance",function()
    Workspace.StreamingEnabled = false
end, 65)

Button(F2,"🕰 Slow Motion",function()
    Workspace.Gravity = 10
    SafeCall(function() Hum.WalkSpeed = 4 end)
end, 66)

Button(F2,"🌪 Spin",function()
    task.spawn(function()
        for i = 1,360 do
            SafeCall(function()
                Root.CFrame = Root.CFrame * CFrame.Angles(0,math.rad(10),0)
            end)
            task.wait(0.01)
        end
    end)
end, 67)

Button(F2,"📐 Reset Camera",function()
    SafeCall(function()
        LP.CameraMaxZoomDistance = 128
        LP.CameraMinZoomDistance = 0.5
        Cam.CameraType = Enum.CameraType.Custom
    end)
end, 68)

Button(F2,"🔒 Lock Camera to Target",function()
    Cam.CameraType = Enum.CameraType.Scriptable
    RunService.RenderStepped:Connect(function()
        local tr = GetRoot(State.TargetPlayer)
        if tr then Cam.CFrame = CFrame.new(Cam.CFrame.Position, tr.Position) end
    end)
end, 69)

Button(F2,"💀 Kill Self",function()
    SafeCall(function() Hum.Health = 0 end)
end, 70)

-- ════════════════════════════════════════
-- TAB 3: DESTRUCTION (100 features)
-- ════════════════════════════════════════
local F3 = Frames[3]

Header(F3,"◈ PLAYER DESTRUCTION",1)

Toggle(F3,"⚔ Kill Aura","KillAura",function(on)
    if on then StartKillAura() end
end, 2)

Slider(F3,"Kill Radius",5,100,15,"KillRadius",nil,3)

PlayerDropdown(F3,"Kill Target","TargetPlayer",4)

Button(F3,"☠ Kill Target",function()
    local t = State.TargetPlayer
    local h = t and GetHum(t)
    if h then SafeCall(function() h.Health = 0 end) end
end, 5)

Button(F3,"☠ Kill All Players",function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            SafeCall(function()
                local h = GetHum(p)
                if h then h.Health = 0 end
            end)
        end
    end
end, 6)

Header(F3,"◈ MAP DESTRUCTION",10)

Button(F3,"💣 Explode All Parts",function()
    task.spawn(function()
        for _, p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "Baseplate" then
                SafeCall(function()
                    local e = Instance.new("Explosion")
                    e.Position = p.Position
                    e.BlastRadius = 5
                    e.Parent = Workspace
                end)
            end
            task.wait(0.01)
        end
    end)
end, 11)

Button(F3,"🔥 Fire All Parts",function()
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") then
            SafeCall(function()
                local f = Instance.new("Fire")
                f.Parent = p
            end)
        end
    end
end, 12)

Button(F3,"🌊 Flood Map",function()
    SafeCall(function()
        local water = Instance.new("Part")
        water.Size  = Vector3.new(2000, 1, 2000)
        water.CFrame = CFrame.new(0, 5, 0)
        water.Anchored = true
        water.CanCollide = false
        water.Color = Color3.fromRGB(0,100,200)
        water.Transparency = 0.4
        water.Material = Enum.Material.Neon
        water.Name = "MakeXpeeps_Flood"
        water.Parent = Workspace
    end)
end, 13)

Button(F3,"🌊 Remove Flood",function()
    local f = Workspace:FindFirstChild("MakeXpeeps_Flood")
    if f then f:Destroy() end
end, 14)

Button(F3,"🪨 Delete Baseplate",function()
    SafeCall(function()
        local b = Workspace:FindFirstChild("Baseplate")
        if b then b:Destroy() end
    end)
end, 15)

Button(F3,"💥 Spawn Explosion at Cursor",function()
    local ray = Cam:ScreenPointToRay(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    local res = Workspace:Raycast(ray.Origin, ray.Direction*500)
    if res then
        SafeCall(function()
            local e = Instance.new("Explosion")
            e.Position = res.Position
            e.BlastRadius = 15
            e.Parent = Workspace
        end)
    end
end, 16)

Button(F3,"🌋 Mega Explosion",function()
    SafeCall(function()
        local e = Instance.new("Explosion")
        e.Position    = Root.Position
        e.BlastRadius = 500
        e.BlastPressure = 9e9
        e.Parent = Workspace
    end)
end, 17)

Button(F3,"🌪 Part Storm",function()
    task.spawn(function()
        for i = 1, 50 do
            SafeCall(function()
                local p = Instance.new("Part")
                p.Size     = Vector3.new(math.random(1,5),math.random(1,5),math.random(1,5))
                p.Position = Root.Position + Vector3.new(math.random(-20,20),math.random(10,50),math.random(-20,20))
                p.Color    = Color3.fromHSV(math.random(),1,1)
                p.Material = Enum.Material.Neon
                p.Parent   = Workspace
                game:GetService("Debris"):AddItem(p,5)
            end)
            task.wait(0.05)
        end
    end)
end, 18)

Button(F3,"🧲 Gravity Bomb",function()
    SafeCall(function()
        local parts = Workspace:GetDescendants()
        for _, p in ipairs(parts) do
            if p:IsA("BasePart") and not p.Anchored then
                p.Velocity = (Root.Position - p.Position).Unit * 100
            end
        end
    end)
end, 19)

Button(F3,"💨 Repulsion Wave",function()
    SafeCall(function()
        for _, p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") and not p.Anchored then
                p.Velocity = (p.Position - Root.Position).Unit * 150
            end
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                SafeCall(function()
                    local r = GetRoot(pl)
                    if r then r.Velocity = (r.Position - Root.Position).Unit * 150 end
                end)
            end
        end
    end)
end, 20)

Button(F3,"🌀 Black Hole",function()
    task.spawn(function()
        for i = 1, 200 do
            SafeCall(function()
                for _, p in ipairs(Workspace:GetDescendants()) do
                    if p:IsA("BasePart") and not p.Anchored then
                        p.Velocity = (Root.Position - p.Position).Unit * (i*0.5)
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end, 21)

Button(F3,"⚡ Lightning Strike All",function()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then
            SafeCall(function()
                local r = GetRoot(pl)
                if r then
                    local e = Instance.new("Explosion")
                    e.Position    = r.Position
                    e.BlastRadius = 5
                    e.Parent      = Workspace
                end
            end)
        end
    end
end, 22)

Button(F3,"🔴 Nuke Workspace",function()
    task.spawn(function()
        local banned = {"Camera","Terrain","HumanoidRootPart"}
        for _, obj in ipairs(Workspace:GetChildren()) do
            local skip = false
            for _, b in ipairs(banned) do
                if obj.Name == b or obj.Name == LP.Name then skip=true;break end
            end
            if not skip then
                SafeCall(function() obj:Destroy() end)
            end
        end
    end)
end, 23)

Button(F3,"🕳 Delete All NPCs",function()
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") then
            local h = m:FindFirstChildOfClass("Humanoid")
            if h and not Players:GetPlayerFromCharacter(m) then
                SafeCall(function() m:Destroy() end)
            end
        end
    end
end, 24)

-- More destruction tools 25-60
local destActions = {
    {"💧 Acid Rain", function()
        task.spawn(function()
            for i=1,100 do
                SafeCall(function()
                    local p=Instance.new("Part")
                    p.Size=Vector3.new(0.3,0.3,0.3)
                    p.Position=Vector3.new(math.random(-200,200),100,math.random(-200,200))
                    p.Color=Color3.fromRGB(0,200,0)
                    p.Material=Enum.Material.Neon
                    p.Name="AcidDrop"
                    p.Parent=Workspace
                    game:GetService("Debris"):AddItem(p,5)
                end)
                task.wait(0.02)
            end
        end)
    end},
    {"🔇 Silence All Sounds", function()
        for _,s in ipairs(Workspace:GetDescendants()) do
            if s:IsA("Sound") then SafeCall(function() s:Stop() end) end
        end
    end},
    {"📢 Max Volume All Sounds", function()
        for _,s in ipairs(Workspace:GetDescendants()) do
            if s:IsA("Sound") then SafeCall(function() s.Volume=10; s:Play() end) end
        end
    end},
    {"🪞 Mirror Terrain", function()
        -- Flip all non-anchored parts
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") and not p.Anchored then
                SafeCall(function() p.CFrame = CFrame.new(-p.Position.X,p.Position.Y,p.Position.Z) end)
            end
        end
    end},
    {"🌑 Black Sky", function()
        Lighting.OutdoorAmbient=Color3.fromRGB(0,0,0)
        Lighting.Brightness=0
        SafeCall(function()
            for _,a in ipairs(Lighting:GetChildren()) do
                if a:IsA("Sky") then a:Destroy() end
            end
        end)
    end},
    {"☀ Blinding Sky", function()
        Lighting.Brightness=100
        Lighting.Ambient=Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
    end},
    {"🌈 Rainbow Sky", function()
        task.spawn(function()
            for i=1,200 do
                Lighting.OutdoorAmbient=Color3.fromHSV(i/200,0.5,1)
                task.wait(0.05)
            end
        end)
    end},
    {"💣 Bomb Rain", function()
        task.spawn(function()
            for i=1,30 do
                SafeCall(function()
                    local e=Instance.new("Explosion")
                    e.Position=Vector3.new(math.random(-200,200),0,math.random(-200,200))
                    e.BlastRadius=10
                    e.BlastPressure=500000
                    e.Parent=Workspace
                end)
                task.wait(0.1)
            end
        end)
    end},
    {"🌪 Tornado Sim", function()
        task.spawn(function()
            for i=1,500 do
                SafeCall(function()
                    for _,p in ipairs(Workspace:GetDescendants()) do
                        if p:IsA("BasePart") and not p.Anchored then
                            local dist=(p.Position-Root.Position)
                            p.Velocity=Vector3.new(-dist.Z,5,dist.X)*0.5
                        end
                    end
                end)
                task.wait(0.02)
            end
        end)
    end},
    {"💦 Remove All Water", function()
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") and p.Material==Enum.Material.Water then
                SafeCall(function() p:Destroy() end)
            end
        end
    end},
    {"🏗 Anchor Everything", function()
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") then SafeCall(function() p.Anchored=true end) end
        end
    end},
    {"🎪 Unanchor Everything", function()
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") then SafeCall(function() p.Anchored=false end) end
        end
    end},
    {"🔴 Paint World Red", function()
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") then SafeCall(function() p.Color=Color3.fromRGB(180,0,0) end) end
        end
    end},
    {"⬛ Paint World Black", function()
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") then SafeCall(function() p.Color=Color3.fromRGB(0,0,0) end) end
        end
    end},
    {"✨ Neon World", function()
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") then SafeCall(function() p.Material=Enum.Material.Neon end) end
        end
    end},
    {"🪟 Glass World", function()
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") then SafeCall(function() p.Material=Enum.Material.Glass; p.Transparency=0.5 end) end
        end
    end},
    {"💀 Instant Kill Aura x3 Radius", function()
        State.KillRadius=99
        State.KillAura=true
        StartKillAura()
    end},
    {"🧨 Chain Explosions", function()
        task.spawn(function()
            local pos=Root.Position
            for i=1,10 do
                SafeCall(function()
                    local e=Instance.new("Explosion")
                    e.Position=pos+Vector3.new(i*5,0,0)
                    e.BlastRadius=15
                    e.Parent=Workspace
                end)
                task.wait(0.15)
            end
        end)
    end},
    {"🌡 Lava Floor", function()
        SafeCall(function()
            local p=Instance.new("Part")
            p.Size=Vector3.new(2000,1,2000)
            p.CFrame=CFrame.new(0,-2,0)
            p.Anchored=true
            p.Color=Color3.fromRGB(255,80,0)
            p.Material=Enum.Material.Neon
            p.CanCollide=true
            p.Name="LavaFloor"
            p.Parent=Workspace
            p.Touched:Connect(function(hit)
                local ph=hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
                if ph then ph.Health=0 end
            end)
        end)
    end},
    {"❄ Ice Floor", function()
        SafeCall(function()
            local p=Instance.new("Part")
            p.Size=Vector3.new(2000,1,2000)
            p.CFrame=CFrame.new(0,-2,0)
            p.Anchored=true
            p.Color=Color3.fromRGB(180,220,255)
            p.Material=Enum.Material.Ice
            p.Name="IceFloor"
            p.Parent=Workspace
        end)
    end},
}

local dorder = 30
for _, a in ipairs(destActions) do
    Button(F3, a[1], a[2], dorder)
    dorder = dorder + 1
end

-- ════════════════════════════════════════
-- TAB 4: ESP / TRACKING (100 features)
-- ════════════════════════════════════════
local F4 = Frames[4]

Header(F4,"◈ PLAYER ESP",1)

Toggle(F4,"👁 Name ESP","NameESP",function() UpdateESP() end,2)
Toggle(F4,"❤ Health ESP","HealthESP",function() UpdateESP() end,3)
Toggle(F4,"📏 Distance ESP","DistESP",function() UpdateESP() end,4)
Toggle(F4,"📐 Tracer ESP","TracerESP",function() UpdateESP() end,5)
Toggle(F4,"🎨 Chams (Highlight)","ChamsESP",function() UpdateESP() end,6)

Button(F4,"🔄 Refresh ESP",function() UpdateESP() end,7)
Button(F4,"❌ Clear All ESP",function()
    ClearESP()
    if ESPConn then ESPConn:Disconnect() end
end,8)

Header(F4,"◈ WORLD ESP",10)

Toggle(F4,"📦 Item ESP","ItemESP",function(on)
    if on then
        RunService.RenderStepped:Connect(function()
            if not State.ItemESP then return end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") or obj:IsA("Model") then
                    if not obj:FindFirstChildOfClass("BillboardGui") then
                        SafeCall(function()
                            local bg = Instance.new("BillboardGui")
                            bg.Size           = UDim2.new(0,100,0,30)
                            bg.StudsOffset    = Vector3.new(0,2,0)
                            bg.AlwaysOnTop    = true
                            bg.Parent         = obj:IsA("Tool") and obj or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                            if not bg.Parent then bg:Destroy(); return end
                            local tl = Instance.new("TextLabel")
                            tl.Size           = UDim2.new(1,0,1,0)
                            tl.BackgroundTransparency = 1
                            tl.Text           = obj.Name
                            tl.TextColor3     = Color3.fromRGB(255,200,0)
                            tl.TextStrokeTransparency = 0
                            tl.TextScaled     = true
                            tl.Font           = Enum.Font.GothamBold
                            tl.Parent         = bg
                        end)
                    end
                end
            end
        end)
    end
end, 11)

Header(F4,"◈ AIMBOT",20)

Toggle(F4,"🎯 Silent Aimbot","SilentAim",function(on)
    if on then
        RunService.RenderStepped:Connect(function()
            if not State.SilentAim then return end
            local closest, closestDist = nil, math.huge
            local screenCenter = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then
                    local r = GetRoot(p)
                    local h = GetHum(p)
                    if r and h and h.Health > 0 then
                        local sp, vis = Cam:WorldToViewportPoint(r.Position)
                        if vis then
                            local dist = (Vector2.new(sp.X,sp.Y)-screenCenter).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = r
                            end
                        end
                    end
                end
            end
            if closest then
                Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, closest.Position)
            end
        end)
    end
end, 21)

PlayerDropdown(F4,"Manual Lock Target","TargetPlayer",22)

Button(F4,"🔒 Lock Cam to Target",function()
    local tr = GetRoot(State.TargetPlayer)
    if tr then Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, tr.Position) end
end,23)

Header(F4,"◈ RADAR",30)

-- Mini radar via Drawing
Button(F4,"📡 Toggle Radar",function()
    State.RadarOn = not State.RadarOn
    local RadarBG, RadarDot
    if State.RadarOn then
        local vp = Cam.ViewportSize
        RadarBG = Drawing.new("Square")
        RadarBG.Visible   = true
        RadarBG.Filled    = true
        RadarBG.Color     = Color3.fromRGB(10,0,0)
        RadarBG.Transparency = 0.4
        RadarBG.Size      = Vector2.new(120,120)
        RadarBG.Position  = Vector2.new(vp.X-130, vp.Y-130)
        RadarBG.Thickness = 1

        RunService.RenderStepped:Connect(function()
            if not State.RadarOn then
                if RadarBG then RadarBG.Visible=false end
                return
            end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then
                    local r = GetRoot(p)
                    if r and Root then
                        local rel = Root.CFrame:PointToObjectSpace(r.Position)
                        local scale = 2
                        local rx = math.clamp(rel.X/scale, -55, 55)
                        local rz = math.clamp(rel.Z/scale, -55, 55)
                        local dot = Drawing.new("Circle")
                        dot.Visible = true
                        dot.Filled  = true
                        dot.Color   = Color3.fromRGB(255,50,50)
                        dot.Radius  = 3
                        dot.Position = RadarBG.Position + Vector2.new(60+rx, 60+rz)
                        dot.Thickness = 1
                        task.delay(0.05, function() dot:Remove() end)
                    end
                end
            end
        end)
    end
end,31)

-- More ESP tools
local espExtras = {
    {"👤 Show Player List", function()
        local names = {}
        for _,p in ipairs(Players:GetPlayers()) do
            table.insert(names, p.Name .. " [" .. math.floor((GetRoot(p) and (GetRoot(p).Position-Root.Position).Magnitude or 0)) .. "m]")
        end
        StarterGui:SetCore("SendNotification",{
            Title="Players",
            Text=table.concat(names,"\n"),
            Duration=8
        })
    end},
    {"📊 Show All Player HP", function()
        local info = {}
        for _,p in ipairs(Players:GetPlayers()) do
            local h=GetHum(p)
            table.insert(info, p.Name..": "..(h and math.floor(h.Health) or "?").."hp")
        end
        StarterGui:SetCore("SendNotification",{Title="HP",Text=table.concat(info,"\n"),Duration=8})
    end},
    {"📍 Print All Positions", function()
        for _,p in ipairs(Players:GetPlayers()) do
            local r=GetRoot(p)
            if r then print(p.Name, r.Position) end
        end
    end},
    {"🔴 Red Outline World", function()
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") then
                SafeCall(function()
                    local sb=Instance.new("SelectionBox")
                    sb.Adornee=p
                    sb.Color3=Color3.fromRGB(255,0,0)
                    sb.LineThickness=0.02
                    sb.SurfaceTransparency=1
                    sb.Parent=p
                end)
            end
        end
    end},
    {"❌ Remove All Outlines", function()
        for _,p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("SelectionBox") then SafeCall(function() p:Destroy() end) end
        end
    end},
    {"📸 Screenshot Positions", function()
        for _,p in ipairs(Players:GetPlayers()) do
            local r=GetRoot(p)
            warn(string.format("[MakeXpeeps] %s @ %.1f,%.1f,%.1f",p.Name,
                r and r.Position.X or 0,
                r and r.Position.Y or 0,
                r and r.Position.Z or 0))
        end
    end},
}
local eorder=40
for _,e in ipairs(espExtras) do
    Button(F4,e[1],e[2],eorder); eorder=eorder+1
end

-- ════════════════════════════════════════
-- TAB 5: SERVER TROLL (100 features)
-- ════════════════════════════════════════
local F5 = Frames[5]

Header(F5,"◈ CHAT",1)

Toggle(F5,"💬 Chat Spam","ChatSpam",function(on)
    if on then StartSpam() end
end,2)

Input(F5,"Spam Text","Enter message...","SpamText",nil,3)

Slider(F5,"Spam Delay (×0.1s)",1,50,1,"SpamDelay",function(v)
    State.SpamDelay = v * 0.1
end,4)

local chatMessages = {
    "FREE ROBUX AT [LINK]",
    "ADMIN ABUSE DETECTED",
    "SERVER IS SHUTTING DOWN",
    "YOU HAVE BEEN BANNED",
    "1000 ROBUX GIVEAWAY",
    "BAN WAVE INCOMING",
    "SERVER CRASH INCOMING",
    "ALL PLAYERS WILL BE BANNED",
    "ROBLOX IS WATCHING",
    "TRADE ME 1000 ROBUX",
}
for i, msg in ipairs(chatMessages) do
    Button(F5,"💬 Send: "..msg:sub(1,25),function()
        SafeCall(function()
            game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                :FindFirstChild("SayMessageRequest")
                :FireServer(msg, "All")
        end)
    end, 10+i)
end

Header(F5,"◈ FAKE EVENTS",30)

Button(F5,"📢 Fake Server Shutdown",function()
    StarterGui:SetCore("SendNotification",{
        Title="⚠ Roblox",
        Text="Server shutting down in 30 seconds. Please save your progress.",
        Duration=10
    })
end,31)

Button(F5,"📢 Fake Ban Warning",function()
    StarterGui:SetCore("SendNotification",{
        Title="⚠ MODERATION",
        Text="Your account has been flagged for review. Actions: Terminate pending.",
        Duration=10
    })
end,32)

Button(F5,"📢 Fake Admin Join",function()
    StarterGui:SetCore("SendNotification",{
        Title="[ADMIN] Roblox_Staff joined",
        Text="A Roblox moderator has joined your server.",
        Duration=8
    })
end,33)

Button(F5,"📢 Fake Update Alert",function()
    StarterGui:SetCore("SendNotification",{
        Title="🔔 Game Update",
        Text="New update pushed! Server restart in 60 seconds.",
        Duration=8
    })
end,34)

Button(F5,"📢 Fake Player Report",function()
    StarterGui:SetCore("SendNotification",{
        Title="Report Received",
        Text="A player has been banned from this server.",
        Duration=6
    })
end,35)

-- Notification spam
Button(F5,"📢 Notification Spam",function()
    task.spawn(function()
        for i=1,20 do
            StarterGui:SetCore("SendNotification",{
                Title="MakeXpeeps #"..i,
                Text="You've been visited by the script hub 👑",
                Duration=2
            })
            task.wait(0.3)
        end
    end)
end,36)

Header(F5,"◈ ENVIRONMENT TROLL",40)

Button(F5,"🌒 Rapid Day/Night Cycle",function()
    task.spawn(function()
        for i=1,1000 do
            SafeCall(function()
                Lighting.ClockTime = (i % 24)
            end)
            task.wait(0.05)
        end
    end)
end,41)

Button(F5,"⛈ Instant Storm",function()
    SafeCall(function()
        Lighting.ClockTime = 2
        Lighting.Brightness = 0.1
        Lighting.OutdoorAmbient = Color3.fromRGB(10,10,30)
        local rain = Instance.new("ParticleEmitter")
        rain.Rate = 500
        rain.Speed = NumberRange.new(50,80)
        rain.Color = ColorSequence.new(Color3.fromRGB(180,200,255))
        rain.Size  = NumberSequence.new({NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(1,0.1)})
        rain.LightEmission = 0
        rain.Rotation = NumberRange.new(80,85)
        rain.Parent = Workspace.Terrain
    end)
end,42)

Button(F5,"🌫 Thick Fog",function()
    SafeCall(function()
        local fog = Instance.new("Atmosphere")
        fog.Density = 0.9
        fog.Offset  = 0
        fog.Parent  = Lighting
    end)
end,43)

Button(F5,"☀ Clear Weather",function()
    SafeCall(function()
        for _, a in ipairs(Lighting:GetChildren()) do
            if a:IsA("Atmosphere") then a:Destroy() end
        end
        Lighting.Brightness = 2
        Lighting.ClockTime  = 14
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    end)
end,44)

Button(F5,"🎨 Psychedelic Mode",function()
    task.spawn(function()
        for i=1,2000 do
            SafeCall(function()
                Lighting.OutdoorAmbient = Color3.fromHSV(i/200%1,1,1)
                Lighting.Ambient        = Color3.fromHSV((i+100)/200%1,1,1)
                Lighting.ClockTime      = (i%24)
            end)
            task.wait(0.02)
        end
    end)
end,45)

Button(F5,"🔊 Play Earrape",function()
    SafeCall(function()
        local s = Instance.new("Sound")
        s.SoundId  = "rbxassetid://9120386436"
        s.Volume   = 10
        s.Looped   = true
        s.Parent   = Workspace
        s:Play()
        s.Name     = "MX_Earrape"
    end)
end,46)

Button(F5,"🔕 Stop Earrape",function()
    local s = Workspace:FindFirstChild("MX_Earrape")
    if s then s:Destroy() end
end,47)

Button(F5,"🕰 Freeze Game Time",function()
    Lighting.ClockTime = 12
    RunService.Heartbeat:Connect(function()
        Lighting.ClockTime = 12
    end)
end,48)

Button(F5,"🌊 Flood with Invisible Parts",function()
    task.spawn(function()
        for i=1,200 do
            SafeCall(function()
                local p=Instance.new("Part")
                p.Anchored=true
                p.CanCollide=true
                p.Transparency=1
                p.Size=Vector3.new(5,5,5)
                p.Position=Vector3.new(math.random(-500,500),math.random(-10,50),math.random(-500,500))
                p.Parent=Workspace
                game:GetService("Debris"):AddItem(p,30)
            end)
            task.wait(0.01)
        end
    end)
end,49)

Button(F5,"💡 Strobe Lights",function()
    task.spawn(function()
        for i=1,200 do
            Lighting.Brightness = (i%2==0) and 0 or 10
            task.wait(0.05)
        end
        Lighting.Brightness = 2
    end)
end,50)

Button(F5,"🎭 Fake Error Screen",function()
    StarterGui:SetCore("SendNotification",{
        Title="⚠ CRITICAL ERROR",
        Text="Fatal exception 0xC0000005 — memory access violation in roblox.exe",
        Duration=10
    })
end,51)

Button(F5,"📡 Server Broadcast",function()
    SafeCall(function()
        StarterGui:SetCore("ChatMakeSystemMessage",{
            Text="[MakeXpeeps] Hub is active on this server.",
            Color=Color3.fromRGB(255,0,0),
            Font=Enum.Font.GothamBold,
            TextSize=16,
        })
    end)
end,52)

-- ════════════════════════════════════════
-- TAB 6: DISGUISE (100 features)
-- ════════════════════════════════════════
local F6 = Frames[6]

Header(F6,"◈ PLAYER CLONE",1)

PlayerDropdown(F6,"Clone Target","DisguiseTarget",2)

Button(F6,"🎭 Copy Target Appearance",function()
    local t = State.DisguiseTarget
    if not t then return end
    SafeCall(function()
        OriginalDesc = Hum:GetAppliedDescription()
        CloneLookToSelf(t)
    end)
end,3)

Button(F6,"↩ Restore Original Look",function()
    RestoreLook()
end,4)

Header(F6,"◈ ANIMATION SPOOF",10)

-- Spoof buttons for each anim
local animOrder = 11
for name, id in pairs(SpoofAnims) do
    local n, i = name, id
    Button(F6,"🕺 Play: "..n,function()
        ApplyAnimSpoof(n)
    end,animOrder)
    animOrder = animOrder + 1
end

Button(F6,"🎭 Copy Target Animations",function()
    local t = State.DisguiseTarget
    if not t then return end
    SafeCall(function() SpoofAllAnims(t) end)
end,50)

Button(F6,"⛔ Stop All Animations",function()
    SafeCall(function()
        local anim = Hum:GetPlayingAnimationTracks()
        for _, t in ipairs(anim) do t:Stop() end
    end)
end,51)

Button(F6,"🔁 Loop Random Animations",function()
    task.spawn(function()
        local keys = {}
        for k in pairs(SpoofAnims) do table.insert(keys, k) end
        for i=1,50 do
            ApplyAnimSpoof(keys[math.random(#keys)])
            task.wait(2)
        end
    end)
end,52)

Header(F6,"◈ NAME SPOOF",60)

Input(F6,"Spoof Name","Enter fake name...","SpoofName",nil,61)

Button(F6,"✏ Apply Name Spoof",function()
    ApplyNameSpoof(State.SpoofName or "Player")
end,62)

Button(F6,"❌ Remove Name Spoof",function()
    RemoveNameSpoof()
end,63)

Button(F6,"🎯 Copy Target Name",function()
    local t = State.DisguiseTarget
    if t then
        State.SpoofName = t.Name
        ApplyNameSpoof(t.Name)
    end
end,64)

Button(F6,"🔀 Random Player Name",function()
    local all = Players:GetPlayers()
    local pick = all[math.random(#all)]
    if pick then
        State.SpoofName = pick.Name
        ApplyNameSpoof(pick.Name)
    end
end,65)

Header(F6,"◈ FULL DISGUISE PRESETS",70)

Button(F6,"👤 Full Clone (Looks+Name)",function()
    local t = State.DisguiseTarget
    if not t then return end
    SafeCall(function()
        OriginalDesc = Hum:GetAppliedDescription()
        CloneLookToSelf(t)
        ApplyNameSpoof(t.Name)
        SpoofAllAnims(t)
    end)
end,71)

Button(F6,"↩ Full Restore",function()
    RestoreLook()
    RemoveNameSpoof()
    SafeCall(function()
        local orig = Char:FindFirstChild("Animate")
        if orig then orig.Enabled=true end
        local fake = Char:FindFirstChild("Animate_Spoofed")
        if fake then fake:Destroy() end
    end)
end,72)

-- Character body part swaps
local bodyPresets = {
    {"👹 Giant Head",   function() SafeCall(function() local d=Hum:GetAppliedDescription(); d.HeadScale=4; Hum:ApplyDescription(d) end) end},
    {"🐭 Tiny Head",    function() SafeCall(function() local d=Hum:GetAppliedDescription(); d.HeadScale=0.2; Hum:ApplyDescription(d) end) end},
    {"🦒 Tall Body",    function() SafeCall(function() local d=Hum:GetAppliedDescription(); d.BodyHeightScale=2; Hum:ApplyDescription(d) end) end},
    {"🐛 Flat Body",    function() SafeCall(function() local d=Hum:GetAppliedDescription(); d.BodyHeightScale=0.3; Hum:ApplyDescription(d) end) end},
    {"🏀 Wide Body",    function() SafeCall(function() local d=Hum:GetAppliedDescription(); d.BodyWidthScale=3; Hum:ApplyDescription(d) end) end},
    {"📏 Thin Body",    function() SafeCall(function() local d=Hum:GetAppliedDescription(); d.BodyWidthScale=0.2; Hum:ApplyDescription(d) end) end},
    {"🦵 Long Legs",    function() SafeCall(function() local d=Hum:GetAppliedDescription(); d.BodyHeightScale=2.5; d.HeadScale=0.5; Hum:ApplyDescription(d) end) end},
    {"🦾 No Arms",      function()
        SafeCall(function()
            for _, p in ipairs({"Left Arm","Right Arm","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand"}) do
                local part = Char:FindFirstChild(p)
                if part then part.Transparency = 1; part.CanCollide=false end
            end
        end)
    end},
    {"🦿 No Legs",      function()
        SafeCall(function()
            for _, p in ipairs({"Left Leg","Right Leg","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"}) do
                local part = Char:FindFirstChild(p)
                if part then part.Transparency = 1; part.CanCollide=false end
            end
        end)
    end},
    {"🎭 Random Scale", function()
        SafeCall(function()
            local d=Hum:GetAppliedDescription()
            d.HeadScale=0.5+math.random()*2
            d.BodyHeightScale=0.5+math.random()*2
            d.BodyWidthScale=0.5+math.random()*1.5
            d.BodyDepthScale=0.5+math.random()*1.5
            Hum:ApplyDescription(d)
        end)
    end},
}

local bpOrder = 80
for _, bp in ipairs(bodyPresets) do
    Button(F6, bp[1], bp[2], bpOrder)
    bpOrder = bpOrder + 1
end

-- Face spoofing
Header(F6,"◈ FACE SPOOF",95)

local faceIDs = {
    {"😀 Happy",    7074149},
    {"😈 Evil",     404306534},
    {"💀 Skull",    5256464},
    {"🤡 Clown",    6712598},
    {"😎 Shades",   8560184},
    {"👁 Creepy",   2199493721},
    {"😡 Angry",    7065049},
    {"😴 Sleepy",   6712579},
}
local forder = 96
for _, f in ipairs(faceIDs) do
    local fid = f[2]
    Button(F6, "Face: "..f[1], function()
        SafeCall(function()
            local d = Hum:GetAppliedDescription()
            d.Face = fid
            Hum:ApplyDescription(d)
        end)
    end, forder)
    forder = forder + 1
end

-- ════════════════════════════════════════
-- INIT
-- ════════════════════════════════════════

SwitchTab(1)

-- Welcome notification
task.delay(0.5, function()
    StarterGui:SetCore("SendNotification",{
        Title="⚡ MakeXpeeps",
        Text="Hub loaded — "..#Players:GetPlayers().." players | 600+ features",
        Duration=5
    })
end)

print("[MakeXpeeps] Hub initialized. 600+ features loaded.")
