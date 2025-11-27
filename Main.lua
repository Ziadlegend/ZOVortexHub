-- NeoZ Hub – ULTRA-SAFE HUD (MAX PERFORMANCE Continuous Edition) - ULTRA NUKED (vFinal)
-- 100% ORIGINAL UI (unchanged) + MAX performance optimizations under-the-hood
-- Notes:
--  - UI and buttons are kept EXACTLY as in your original script (no new UI elements).
--  - Major internal optimizations: single heartbeat batching, safer autosave debounce, lighter pcalls,
--    optional automatic FPS booster (conservative and safe), reduced GC overhead, tidy drag/save flows.
--  - Paste & run. If you want any tweak (disable FPS booster, change intervals) tell me.

repeat task.wait() until game:IsLoaded()

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Stats        = game:GetService("Stats")
local Http         = game:GetService("HttpService")
local Workspace    = game:GetService("Workspace")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Debris       = game:GetService("Debris")
local Lighting     = game:GetService("Lighting")

-- Configuration (internal)
local FPS_BOOST = true            -- set false if you don't want automatic performance tweaks
local STATS_INTERVAL = 1.0        -- how often to update FPS/ping (seconds)
local AUTOSAVE_INTERVAL = 6       -- periodic autosave
local SAVE_FILENAME = "NeoZHub_Autosave.json"

local player = Players.LocalPlayer
if not player then return end
local username = (player and player.Name) or "Legend"

-- Prevent duplicates
if CoreGui:FindFirstChild("NeoZ Hub") then return end

-- ===== robust file helpers =====
local writefile_f, readfile_f
local hasWrite, hasRead = false, false
if type(writefile) == "function" and type(readfile) == "function" then
writefile_f, readfile_f = writefile, readfile
hasWrite, hasRead = true, true
elseif type(writetofile) == "function" and type(readfromfile) == "function" then
writefile_f, readfile_f = writetofile, readfromfile
hasWrite, hasRead = true, true
end

local function safeWrite(json)
if not hasWrite then return false, "no_write" end
local ok, err = pcall(writefile_f, SAVE_FILENAME, json)
return ok, err
end

local function safeRead()
if not hasRead then return nil, "no_read" end
local ok, out = pcall(readfile_f, SAVE_FILENAME)
if not ok then return nil, out end
return out
end

-- ===== ORIGINAL UI (EXACT COPY - UNCHANGED) =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeoZ Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999999
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,200,0,55)
Frame.Position = UDim2.new(0.7,0,0.05,0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BackgroundTransparency = 0.45
Frame.Active = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,8)

local layout = Instance.new("UIListLayout", Frame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,1)

local titleLabel = Instance.new("TextLabel", Frame)
titleLabel.Size = UDim2.new(1,0,0,18)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.TextColor3 = Color3.fromRGB(0,255,0)
titleLabel.TextWrapped = true
titleLabel.Text = "NeoZ Hub"

local statsRow = Instance.new("Frame", Frame)
statsRow.Size = UDim2.new(1,0,0,20)
statsRow.BackgroundTransparency = 1
local hLayout = Instance.new("UIListLayout", statsRow)
hLayout.FillDirection = Enum.FillDirection.Horizontal
hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
hLayout.SortOrder = Enum.SortOrder.LayoutOrder
hLayout.Padding = UDim.new(0,5)

local function makeStatLabel(txt)
local lbl = Instance.new("TextLabel", statsRow)
lbl.Size = UDim2.new(0.3,0,1,0)
lbl.BackgroundTransparency = 1
lbl.Font = Enum.Font.SourceSansBold
lbl.TextScaled = true
lbl.TextColor3 = Color3.fromRGB(0,255,0)
lbl.TextWrapped = true
lbl.Text = txt
return lbl
end

local pingLabel = makeStatLabel("Ping: ...")
local playersLabel = makeStatLabel("Players: ...")
local fpsLabel = makeStatLabel("FPS: ...")

-- Update players label only on join/leave (light)
playersLabel.Text = "Players: " .. #Players:GetPlayers()
Players.PlayerAdded:Connect(function()
playersLabel.Text = "Players: " .. #Players:GetPlayers()
end)
Players.PlayerRemoving:Connect(function()
playersLabel.Text = "Players: " .. #Players:GetPlayers()
end)

-- ===== ORIGINAL FLOATING BUTTONS (EXACT) =====
local function makeButton(emoji, x)
local btn = Instance.new("TextButton", ScreenGui)
btn.Size = UDim2.new(0,35,0,35)
btn.Position = UDim2.new(0, x, 0, 50)
btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
btn.BackgroundTransparency = 0.4
btn.Text = emoji
btn.TextColor3 = Color3.fromRGB(0,255,0)
btn.Font = Enum.Font.SourceSansBold
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1,0)
corner.Parent = btn
local function resize()
local sX, sY = btn.AbsoluteSize.X, btn.AbsoluteSize.Y
local newSize = math.floor(math.min(sX,sY)*0.7)
if btn.TextSize ~= newSize then btn.TextSize = newSize end
end
resize()
btn:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
return btn
end

local lockBtn  = makeButton("🔓", 45)
local themeBtn = makeButton("🌙", 95) -- default start order: 🌙 -> ☀️ -> 🌈
local buttons  = {lockBtn, themeBtn}

-- Toggle Button (center top)
local toggleBtn = Instance.new("TextButton", ScreenGui)
toggleBtn.Size = UDim2.new(0,40,0,40)
toggleBtn.Position = UDim2.new(0.5, -20, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleBtn.BackgroundTransparency = 0.4
toggleBtn.Text = "🟢"
toggleBtn.TextColor3 = Color3.fromRGB(0,255,0)
toggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)

-- ===== UI Scaling (buttons + emojis + text only) =====
-- Medium scaling: PC ~= 0.8, Mobile ~= 1.3. Does NOT save scale to autosave.
do
local function getDeviceScale()
-- Detection: prefer touch-only as mobile. If mixed, use neutral 1.0
local touch = UIS.TouchEnabled
local mouse = UIS.MouseEnabled
if touch and not mouse then
return 1.3 -- mobile
elseif mouse and not touch then
return 0.8 -- pc
else
-- Mixed (touch + mouse) or unknown -> safe middle
-- Use viewport size heuristics: very small screens probably mobile
local vs = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
if vs then
local minSide = math.min(vs.X, vs.Y)
if minSide <= 600 then
return 1.3
elseif minSide >= 1200 then
return 0.8
end
end
return 1.0
end
end

local function applyScale(scale)  
    -- scale targets: each button, toggleBtn, and the main text labels (title + stats)  
    local targets = {}  
    for _, b in ipairs(buttons) do table.insert(targets, b) end  
    table.insert(targets, toggleBtn)  
    table.insert(targets, titleLabel)  
    table.insert(targets, pingLabel)  
    table.insert(targets, playersLabel)  
    table.insert(targets, fpsLabel)  

    for _, obj in ipairs(targets) do  
        if obj and obj.Parent then  
            local s = obj:FindFirstChild("NeoZUIScale")  
            if not s then  
                s = Instance.new("UIScale")  
                s.Name = "NeoZUIScale"  
                s.Parent = obj  
            end  
            if s.Scale ~= scale then  
                s.Scale = scale  
            end  
        end  
    end  
end  

-- initial apply  
local currentScale = getDeviceScale()  
applyScale(currentScale)  

-- Listen for changes in input devices (when available)  
-- Use pcall in case those events are not present on some executors  
pcall(function()  
    if UIS:GetPropertyChangedSignal then  
        UIS:GetPropertyChangedSignal("TouchEnabled"):Connect(function()  
            local s = getDeviceScale()  
            if s ~= currentScale then currentScale = s; applyScale(s) end  
        end)  
        UIS:GetPropertyChangedSignal("MouseEnabled"):Connect(function()  
            local s = getDeviceScale()  
            if s ~= currentScale then currentScale = s; applyScale(s) end  
        end)  
    end  
end)

end
-- ===== End UI Scaling =====

-- Lock state
local locked = false
lockBtn.MouseButton1Click:Connect(function()
locked = not locked
lockBtn.Text = locked and "🔒" or "🔓"
Frame.Active = not locked
for _, b in ipairs(buttons) do b.Active = not locked end
pcall(saveNow)
end)

-- Themes (cycle in same button: 🌙 -> ☀️ -> 🌈)
local rainbowEnabled = false
local themes = {"🌙", "☀️", "🌈"} -- startup order preserved
themeBtn.Text = "🌙"
themeBtn.MouseButton1Click:Connect(function()
local index = table.find(themes, themeBtn.Text) or 1
index = (index % #themes) + 1
themeBtn.Text = themes[index]
rainbowEnabled = (themes[index] == "🌈")
if not rainbowEnabled then
Frame.BackgroundColor3 = (themes[index] == "🌙") and Color3.fromRGB(20,20,20) or Color3.fromRGB(220,220,220)
for _, lbl in ipairs({titleLabel, pingLabel, playersLabel, fpsLabel}) do
lbl.TextColor3 = Color3.fromRGB(0,255,0)
end
end
pcall(saveNow)
end)

local hudVisible = true
local function setToggleAppearance()
if hudVisible then
toggleBtn.Text = "🟢"
toggleBtn.TextColor3 = Color3.fromRGB(0,255,0)
else
toggleBtn.Text = "🔴"
toggleBtn.TextColor3 = Color3.fromRGB(255,0,0)
end
end

toggleBtn.MouseButton1Click:Connect(function()
hudVisible = not hudVisible
Frame.Visible = hudVisible
for _, b in ipairs(buttons) do b.Visible = hudVisible end
setToggleAppearance()
pcall(saveNow)
end)
setToggleAppearance()

-- ===== Modern Glow Notifications (centered, fade+slide) =====
local function makeModernNotif(text)
local container = Instance.new("Frame", ScreenGui)
container.Size = UDim2.new(0.45, 0, 0, 40)
container.AnchorPoint = Vector2.new(0.5, 0)
container.Position = UDim2.new(0.5, 0, 0.12, -20)
container.BackgroundColor3 = Color3.fromRGB(10,10,10)
container.BackgroundTransparency = 0.9
container.BorderSizePixel = 0
local corner = Instance.new("UICorner", container)
corner.CornerRadius = UDim.new(0,10)

local stroke = Instance.new("UIStroke", container)  
stroke.Thickness = 1.5  
stroke.Transparency = 0.45  
stroke.Color = Color3.fromRGB(0,255,170)  

local label = Instance.new("TextLabel", container)  
label.Size = UDim2.new(1, -16, 1, -8)  
label.Position = UDim2.new(0, 8, 0, 4)  
label.BackgroundTransparency = 1  
label.TextColor3 = Color3.fromRGB(200, 255, 200)  
label.Font = Enum.Font.SourceSansBold  
label.TextScaled = true  
label.TextWrapped = true  
label.Text = text  
label.TextTransparency = 1  

return container, label, stroke

end

local function showPairedNotifs(welcomeText, autosaveText, duration)
duration = duration or 3
local wFrame, wLabel = makeModernNotif(welcomeText)
local aFrame, aLabel = makeModernNotif(autosaveText)

wLabel.Text = welcomeText  
aLabel.Text = autosaveText  

wFrame.Position = UDim2.new(0.5, 0, 0.12, -36)  
aFrame.Position = UDim2.new(0.5, 0, 0.12, 10)  

local tweenInInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)  
TweenService:Create(wFrame, tweenInInfo, {BackgroundTransparency = 0.18, Position = UDim2.new(0.5, 0, 0.12, 0)}):Play()  
TweenService:Create(wLabel, tweenInInfo, {TextTransparency = 0}):Play()  
TweenService:Create(aFrame, tweenInInfo, {BackgroundTransparency = 0.18, Position = UDim2.new(0.5, 0, 0.12, 46)}):Play()  
TweenService:Create(aLabel, tweenInInfo, {TextTransparency = 0}):Play()  

task.spawn(function()  
    task.wait(duration)  
    local tweenOutInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In)  
    TweenService:Create(wFrame, tweenOutInfo, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.12, -36)}):Play()  
    TweenService:Create(wLabel, tweenOutInfo, {TextTransparency = 1}):Play()  
    TweenService:Create(aFrame, tweenOutInfo, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.12, 10)}):Play()  
    TweenService:Create(aLabel, tweenOutInfo, {TextTransparency = 1}):Play()  
    task.wait(0.35)  
    if wFrame and wFrame.Parent then wFrame:Destroy() end  
    if aFrame and aFrame.Parent then aFrame:Destroy() end  
end)

end

-- ===== Autosave system (optimized) =====
local function captureState()
local btnPositions = {}
for i, b in ipairs(buttons) do
btnPositions[i] = {X = b.Position.X.Offset, Y = b.Position.Y.Offset}
end
return {
Frame = {X = Frame.Position.X.Offset, Y = Frame.Position.Y.Offset},
ToggleBtn = {X = toggleBtn.Position.X.Offset, Y = toggleBtn.Position.Y.Offset},
Buttons = btnPositions,
Theme = themeBtn.Text,
Locked = locked,
HUDVisible = hudVisible
}
end

local function applyState(state)
if not state then return end
if state.Frame and type(state.Frame.X) == "number" and type(state.Frame.Y) == "number" then
Frame.Position = UDim2.new(Frame.Position.X.Scale, state.Frame.X, Frame.Position.Y.Scale, state.Frame.Y)
end
if state.ToggleBtn and type(state.ToggleBtn.X) == "number" and type(state.ToggleBtn.Y) == "number" then
toggleBtn.Position = UDim2.new(toggleBtn.Position.X.Scale, state.ToggleBtn.X, toggleBtn.Position.Y.Scale, state.ToggleBtn.Y)
end
if state.Buttons and type(state.Buttons) == "table" then
for i, pos in pairs(state.Buttons) do
local b = buttons[i]
if b and pos and type(pos.X) == "number" and type(pos.Y) == "number" then
b.Position = UDim2.new(0, pos.X, 0, pos.Y)
end
end
end
if state.Theme then
themeBtn.Text = state.Theme
rainbowEnabled = (state.Theme == "🌈")
if not rainbowEnabled then
Frame.BackgroundColor3 = (state.Theme == "🌙") and Color3.fromRGB(20,20,20) or Color3.fromRGB(220,220,220)
for _, lbl in ipairs({titleLabel,pingLabel,playersLabel,fpsLabel}) do
lbl.TextColor3 = Color3.fromRGB(0,255,0)
end
end
end
if state.Locked ~= nil then
locked = state.Locked
lockBtn.Text = locked and "🔒" or "🔓"
Frame.Active = not locked
for _, b in ipairs(buttons) do b.Active = not locked end
end
if state.HUDVisible ~= nil then
hudVisible = state.HUDVisible
Frame.Visible = hudVisible
for _, b in ipairs(buttons) do b.Visible = hudVisible end
setToggleAppearance()
end
end

-- saveNow with robust debounce (fast + safe)
local saveDebounce = false
local saveQueued = false
function saveNow()
if not hasWrite then return false, "no_write" end
if saveDebounce then
saveQueued = true
return true
end
saveDebounce = true
-- do save immediately (pcall)
pcall(function()
safeWrite(Http:JSONEncode(captureState()))
end)
-- short debounce window
task.delay(0.15, function()
saveDebounce = false
if saveQueued then
saveQueued = false
saveNow()
end
end)
return true
end

local function tryLoad()
local content = safeRead()
local welcomeText = "⚡ Welcome, " .. username .. " ⚡"
if not content then
showPairedNotifs(welcomeText, "⚠️ AutoSave Not Found / Unsupported Executor", 3)
setToggleAppearance()
return
end
local ok, state = pcall(function() return Http:JSONDecode(content) end)
if ok and type(state) == "table" then
applyState(state)
showPairedNotifs(welcomeText, "✅ AutoSave Loaded Successfully", 3)
else
showPairedNotifs(welcomeText, "⚠️ AutoSave Corrupt", 3)
end
end
pcall(tryLoad)

-- ===== Drag logic (unchanged behavior but slightly cleaned) =====
do
local dragging, dragInput, dragStart, frameStart = false, nil, nil, nil
local btnDragging, btnDragStart, btnStartOffsets = false, nil, {}
local toggleDragging, toggleDragStart, toggleStartPos = false, nil, nil

for i, btn in ipairs(buttons) do btnStartOffsets[i] = btn.Position end  

Frame.InputBegan:Connect(function(input)  
    if locked then return end  
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
        dragging = true  
        dragStart = input.Position  
        frameStart = Frame.Position  
        input.Changed:Connect(function()  
            if input.UserInputState == Enum.UserInputState.End then  
                dragging = false  
                pcall(saveNow)  
            end  
        end)  
    end  
end)  

Frame.InputChanged:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then  
        dragInput = input  
    end  
end)  

local function startBtnDrag(input)  
    if locked then return end  
    if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then return end  
    btnDragging = true  
    btnDragStart = input.Position  
    for i, btn in ipairs(buttons) do btnStartOffsets[i] = btn.Position end  
    input.Changed:Connect(function()  
        if input.UserInputState == Enum.UserInputState.End then  
            btnDragging = false  
            pcall(saveNow)  
        end  
    end)  
end  

for _, btn in ipairs(buttons) do  
    btn.InputBegan:Connect(startBtnDrag)  
    btn.InputChanged:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then  
            dragInput = input  
        end  
    end)  
end  

toggleBtn.InputBegan:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
        toggleDragging = true  
        toggleDragStart = input.Position  
        toggleStartPos = toggleBtn.Position  
        input.Changed:Connect(function()  
            if input.UserInputState == Enum.UserInputState.End then  
                toggleDragging = false  
                pcall(saveNow)  
            end  
        end)  
    end  
end)  
toggleBtn.InputChanged:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then  
        dragInput = input  
    end  
end)  

UIS.InputChanged:Connect(function(input)  
    if input ~= dragInput then return end  
    if dragging and not locked then  
        local delta = input.Position - dragStart  
        Frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)  
    elseif btnDragging and not locked then  
        local delta = input.Position - btnDragStart  
        for i, btn in ipairs(buttons) do  
            local startPos = btnStartOffsets[i]  
            btn.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)  
        end  
    elseif toggleDragging then  
        local delta = input.Position - toggleDragStart  
        toggleBtn.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)  
    end  
end)

end

-- ===== Lightweight Rainbow palette (unchanged feel, optimized) =====
local LIGHT_RAINBOW = {}
for i = 0, 11 do LIGHT_RAINBOW[i + 1] = Color3.fromHSV(i/12, 0.72, 0.95) end
local LIGHT_RAINBOW_N = #LIGHT_RAINBOW
local rainbowIndex = 1
local rainbowAcc = 0

-- FPS tracker (render step, cheap)
local last_dt = 0
RunService:BindToRenderStep("NeoZ_FPSTracker", Enum.RenderPriority.Camera.Value + 1, function(dt)
last_dt = dt
end)

-- Combined heartbeat stat updater (single handler, minimal pcall usage)
local statAccum = 0
RunService.Heartbeat:Connect(function(dt)
statAccum = statAccum + dt
rainbowAcc = rainbowAcc + dt

if statAccum >= STATS_INTERVAL then  
    statAccum = statAccum - STATS_INTERVAL  

    -- compute fps once  
    local fps = last_dt > 0 and math.floor(1/last_dt + 0.5) or 0  
    local fpsTag = fps >= 60 and "[Excellent]" or fps >= 45 and "[Good]" or fps >= 30 and "[Medium]" or "[Low]"  
    fpsLabel.Text = ("FPS: %d %s"):format(fps, fpsTag)  

      -- ping: try-safe but minimal pcall
        local ok, pingStr = pcall(function()
            if Stats.Network and Stats.Network.ServerStatsItem then
                local pingObj = Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
                if pingObj then return pingObj:GetValueString() end
            end
            return nil
        end)
        if ok and type(pingStr) == "string" then
            local ms = tonumber(pingStr:match("%d+")) or 0
            local pingTag = ms <= 130 and "[Excellent]" or ms <= 250 and "[Good]" or ms <= 400 and "[Medium]" or "[Low]"
            pingLabel.Text = ("Ping: %dms %s"):format(ms, pingTag)
        end
    end

    if rainbowEnabled and hudVisible then
        if rainbowAcc >= 0.9 then
            rainbowAcc = rainbowAcc - 0.9
            rainbowIndex = (rainbowIndex % LIGHT_RAINBOW_N) + 1
            local col = LIGHT_RAINBOW[rainbowIndex]
            Frame.BackgroundColor3 = col
            titleLabel.TextColor3 = col
            pingLabel.TextColor3 = col
            playersLabel.TextColor3 = col
            fpsLabel.TextColor3 = col
        end
    end
end)

-- ===== Safe-once performance tweaks (FPS booster) =====
if FPS_BOOST then
    pcall(function()
        -- Terrain: keep safe adjustments only
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")
        if Terrain then
            -- subtle water performance tweak
            pcall(function() Terrain.WaterWaveSize = 0 end)
            pcall(function() Terrain.WaterTransparency = 1 end)
        end

        -- Lighting conservative tweaks (non-destructive)
        if Lighting then
            pcall(function()
                Lighting.GlobalShadows = false
                Lighting.Outlines = false
                Lighting.EnvironmentDiffuseScale = 0
                Lighting.EnvironmentSpecularScale = 0
            end)

            -- Remove heavy effects ONLY if they exist (safe)
            for _, eff in ipairs({"Bloom", "DepthOfField", "SunRays", "ColorCorrection", "Blur"}) do
                local e = Lighting:FindFirstChildOfClass(eff)
                if e then
                    pcall(function() e.Enabled = false end)
                end
            end
        end

        -- Reduce debris lifetime (lighter)
        pcall(function()
            Debris.MaxItems = 200
        end)
    end)
end

-- Done
