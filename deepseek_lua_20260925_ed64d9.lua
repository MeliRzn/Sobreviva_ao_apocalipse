-- ============================================================
-- PALETA DE EMPURRÕES v2 - MENU COMPACTO + PUSH EM CAMADAS
-- ============================================================
print("[Empurrao] Carregando...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
if not LP then return end
local camera = Workspace.CurrentCamera
if not camera then
    repeat task.wait() until Workspace.CurrentCamera
    camera = Workspace.CurrentCamera
end

local guiParent
do
    local ok, r = pcall(function() return gethui() end)
    if ok and r then guiParent = r
    else
        local ok2, c = pcall(function() return game:GetService("CoreGui") end)
        if ok2 and c then guiParent = c
        else guiParent = LP:WaitForChild("PlayerGui") end
    end
end

for _, c in ipairs(guiParent:GetChildren()) do
    if c.Name == "PaletaEmpurrao" then c:Destroy() end
end

-- ============================================================
-- GUI COMPACTA 185 x 315
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "PaletaEmpurrao"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.Parent = guiParent

local tog = Instance.new("TextButton")
tog.Size = UDim2.new(0, 42, 0, 42)
tog.Position = UDim2.new(0, 12, 0.5, -21)
tog.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
tog.TextColor3 = Color3.new(1,1,1)
tog.Text = "🥊"
tog.Font = Enum.Font.GothamBold
tog.TextSize = 18
tog.Parent = SG
Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)

local MF = Instance.new("Frame")
MF.Size = UDim2.new(0, 185, 0, 315)
MF.Position = UDim2.new(0.5, -92, 0.5, -157)
MF.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
MF.BorderSizePixel = 0
MF.Visible = false
MF.Active = true
MF.Parent = SG
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
title.TextColor3 = Color3.new(1,1,1)
title.Text = "🥊 Empurrões"
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = MF
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -25, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Parent = MF
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, -12, 0, 16)
targetLabel.Position = UDim2.new(0, 6, 0, 30)
targetLabel.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
targetLabel.Text = "Alvo: ---"
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextSize = 10
targetLabel.Parent = MF
Instance.new("UICorner", targetLabel).CornerRadius = UDim.new(0, 5)

-- Slider Alcance
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(1, -12, 0, 12)
rangeLabel.Position = UDim2.new(0, 6, 0, 50)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
rangeLabel.Text = "Alcance: 40"
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 9
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = MF

local rangeBar = Instance.new("Frame")
rangeBar.Size = UDim2.new(1, -12, 0, 5)
rangeBar.Position = UDim2.new(0, 6, 0, 64)
rangeBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
rangeBar.BorderSizePixel = 0
rangeBar.Parent = MF
Instance.new("UICorner", rangeBar).CornerRadius = UDim.new(1, 0)

local rangeFill = Instance.new("Frame")
rangeFill.Size = UDim2.new(0.4, 0, 1, 0)
rangeFill.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
rangeFill.BorderSizePixel = 0
rangeFill.Parent = rangeBar
Instance.new("UICorner", rangeFill).CornerRadius = UDim.new(1, 0)

local rangeBtn = Instance.new("TextButton")
rangeBtn.Size = UDim2.new(1, -12, 0, 16)
rangeBtn.Position = UDim2.new(0, 6, 0, 64)
rangeBtn.BackgroundTransparency = 1
rangeBtn.Text = ""
rangeBtn.Parent = MF

-- Slider Força
local forceLabel = Instance.new("TextLabel")
forceLabel.Size = UDim2.new(1, -12, 0, 12)
forceLabel.Position = UDim2.new(0, 6, 0, 84)
forceLabel.BackgroundTransparency = 1
forceLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
forceLabel.Text = "Força: 80"
forceLabel.Font = Enum.Font.Gotham
forceLabel.TextSize = 9
forceLabel.TextXAlignment = Enum.TextXAlignment.Left
forceLabel.Parent = MF

local forceBar = Instance.new("Frame")
forceBar.Size = UDim2.new(1, -12, 0, 5)
forceBar.Position = UDim2.new(0, 6, 0, 98)
forceBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
forceBar.BorderSizePixel = 0
forceBar.Parent = MF
Instance.new("UICorner", forceBar).CornerRadius = UDim.new(1, 0)

local forceFill = Instance.new("Frame")
forceFill.Size = UDim2.new(0.4, 0, 1, 0)
forceFill.BackgroundColor3 = Color3.fromRGB(100, 160, 220)
forceFill.BorderSizePixel = 0
forceFill.Parent = forceBar
Instance.new("UICorner", forceFill).CornerRadius = UDim.new(1, 0)

local forceBtn = Instance.new("TextButton")
forceBtn.Size = UDim2.new(1, -12, 0, 16)
forceBtn.Position = UDim2.new(0, 6, 0, 98)
forceBtn.BackgroundTransparency = 1
forceBtn.Text = ""
forceBtn.Parent = MF

local rangeValue = 40
local forceValue = 80

-- 6 botões (3x2) - SEM emoji, mais compactos
local function mkModeBtn(text, x, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 55, 0, 30)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.Parent = MF
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local btnSimples = mkModeBtn("Empurrar", 6,  124, Color3.fromRGB(180, 60, 60))
local btnLancar  = mkModeBtn("Lançar",   65, 124, Color3.fromRGB(60, 130, 60))
local btnRodopio = mkModeBtn("Rodopio",  124,124, Color3.fromRGB(90, 80, 140))
local btnPuxar   = mkModeBtn("Puxar",    6,  158, Color3.fromRGB(70, 90, 160))
local btnMeteoro = mkModeBtn("Meteoro",  65, 158, Color3.fromRGB(220, 100, 40))
local btnArea    = mkModeBtn("Área",     124,158, Color3.fromRGB(40, 130, 180))

-- Auto-toggle
local autoTargetBtn = Instance.new("TextButton")
autoTargetBtn.Size = UDim2.new(1, -12, 0, 22)
autoTargetBtn.Position = UDim2.new(0, 6, 0, 194)
autoTargetBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
autoTargetBtn.TextColor3 = Color3.new(1,1,1)
autoTargetBtn.Text = "🎯 Auto: OFF"
autoTargetBtn.Font = Enum.Font.GothamBold
autoTargetBtn.TextSize = 10
autoTargetBtn.Parent = MF
Instance.new("UICorner", autoTargetBtn).CornerRadius = UDim.new(0, 6)
local autoTarget = false

-- Status
local statusL = Instance.new("TextLabel")
statusL.Size = UDim2.new(1, -12, 0, 40)
statusL.Position = UDim2.new(0, 6, 0, 220)
statusL.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
statusL.TextColor3 = Color3.fromRGB(160, 180, 200)
statusL.Text = "Mire e toque."
statusL.Font = Enum.Font.Gotham
statusL.TextSize = 9
statusL.TextWrapped = true
statusL.TextYAlignment = Enum.TextYAlignment.Top
statusL.Parent = MF
Instance.new("UICorner", statusL).CornerRadius = UDim.new(0, 6)

-- Modo de "forçar" (qual técnica usar)
local forceModeBtn = Instance.new("TextButton")
forceModeBtn.Size = UDim2.new(1, -12, 0, 20)
forceModeBtn.Position = UDim2.new(0, 6, 0, 264)
forceModeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
forceModeBtn.TextColor3 = Color3.new(1,1,1)
forceModeBtn.Text = "⚡ Modo: Automático"
forceModeBtn.Font = Enum.Font.GothamBold
forceModeBtn.TextSize = 9
forceModeBtn.Parent = MF
Instance.new("UICorner", forceModeBtn).CornerRadius = UDim.new(0, 5)
local forceMode = "auto" -- auto / cf / vel

-- Histórico simplificado
local histLabel = Instance.new("TextLabel")
histLabel.Size = UDim2.new(1, -12, 0, 24)
histLabel.Position = UDim2.new(0, 6, 1, -28)
histLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
histLabel.TextColor3 = Color3.fromRGB(140, 160, 180)
histLabel.Text = "..."
histLabel.Font = Enum.Font.Gotham
histLabel.TextSize = 9
histLabel.TextXAlignment = Enum.TextXAlignment.Left
histLabel.TextTruncate = Enum.TextTruncate.AtEnd
histLabel.Parent = MF
Instance.new("UICorner", histLabel).CornerRadius = UDim.new(0, 5)

-- Arrastar
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end
makeDraggable(MF, title)

tog.MouseButton1Click:Connect(function() MF.Visible = not MF.Visible end)
closeBtn.MouseButton1Click:Connect(function() MF.Visible = false end)

-- Sliders
local function bindSlider(btn, fill, isRange)
    local dragging = false
    local function update(x)
        local bar = btn.Parent
        local ap = bar.AbsolutePosition
        local as = bar.AbsoluteSize
        local rel = math.clamp((x - ap.X) / as.X, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        if isRange then
            rangeValue = math.floor(10 + rel * 110)
            rangeLabel.Text = "Alcance: " .. rangeValue
        else
            forceValue = math.floor(20 + rel * 280)
            forceLabel.Text = "Força: " .. forceValue
        end
    end
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
bindSlider(rangeBtn, rangeFill, true)
bindSlider(forceBtn, forceFill, false)

autoTargetBtn.MouseButton1Click:Connect(function()
    autoTarget = not autoTarget
    if autoTarget then
        autoTargetBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 60)
        autoTargetBtn.Text = "🎯 Auto: ON"
    else
        autoTargetBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        autoTargetBtn.Text = "🎯 Auto: OFF"
    end
end)

forceModeBtn.MouseButton1Click:Connect(function()
    if forceMode == "auto" then
        forceMode = "cf"
        forceModeBtn.Text = "⚡ Modo: CFrame"
        forceModeBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 140)
    elseif forceMode == "cf" then
        forceMode = "vel"
        forceModeBtn.Text = "⚡ Modo: Velocity"
        forceModeBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 140)
    else
        forceMode = "auto"
        forceModeBtn.Text = "⚡ Modo: Automático"
        forceModeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
    end
end)

-- Histórico
local function setHist(txt)
    histLabel.Text = txt
end

-- ============================================================
-- ALVO
-- ============================================================
local function isPlayerPart(inst)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and inst:IsDescendantOf(p.Character) then
            return p
        end
    end
    return nil
end

local function getTarget()
    local unitRay = camera:ScreenPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * rangeValue, params)
    if result then
        local plr = isPlayerPart(result.Instance)
        if plr then return plr end
    end
    if autoTarget then
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        local best, bestDist = nil, rangeValue
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - myRoot.Position).Magnitude
                    if d < bestDist then best, bestDist = plr, d end
                end
            end
        end
        return best
    end
    return nil
end

-- ============================================================
-- PUSH EM CAMADAS
-- ============================================================
-- Estratégia:
--   1. Tenta SetNetworkOwner (rápido)
--   2. Independente do resultado, aplica:
--      a) CFrame delta pequeno (o server aceita se for pequeno)
--      b) AssemblyLinearVelocity
--      c) BodyVelocity (force físico direto)
--   3. Aplica em LOOP por ~0.5s (o server aceita várias pequenas mudanças)

local function attemptOwnership(hrp)
    local ok = pcall(function() hrp:SetNetworkOwner(LP) end)
    return ok
end

local function applyPush(hrp, direction, force, upBias, spin)
    -- CAMADA 1: CFrame delta
    pcall(function()
        local delta = direction * (force * 0.005) + Vector3.new(0, upBias * 0.005, 0)
        hrp.CFrame = hrp.CFrame + delta
    end)
    -- CAMADA 2: Velocity direto
    pcall(function()
        hrp.AssemblyLinearVelocity = direction * force + Vector3.new(0, upBias, 0)
    end)
    -- CAMADA 3: BodyVelocity (força contínua)
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = direction * force + Vector3.new(0, upBias, 0)
    bv.P = 100000
    bv.Parent = hrp
    -- CAMADA 4: BodyAngularVelocity (giro)
    local bav
    if spin then
        bav = Instance.new("BodyAngularVelocity")
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bav.AngularVelocity = spin
        bav.P = 100000
        bav.Parent = hrp
    end
    task.delay(0.6, function()
        pcall(function() bv:Destroy() end)
        if bav then pcall(function() bav:Destroy() end) end
    end)
end

local function pushTarget(targetPlayer, mode)
    if not targetPlayer or not targetPlayer.Character then
        statusL.Text = "⚠ Sem alvo na mira"
        statusL.TextColor3 = Color3.fromRGB(220, 120, 120)
        return
    end
    local char = targetPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        statusL.Text = "⚠ Alvo inválido"
        statusL.TextColor3 = Color3.fromRGB(220, 120, 120)
        return
    end

    -- 1) Ownership (tenta)
    local ownOk = attemptOwnership(hrp)

    -- 2) Desativa Humanoid (impede counter-force)
    pcall(function()
        hum.PlatformStand = true
    end)

    -- 3) Direção
    local camLook = camera.CFrame.LookVector
    local backDir = -camLook
    local upDir = Vector3.new(0, 1, 0)
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local F = forceValue

    -- 4) Loop de aplicação por 0.5s (aplica várias vezes)
    local endTime = tick() + 0.5
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() > endTime then
            conn:Disconnect()
            pcall(function()
                if hum and hum.Parent then
                    hum.PlatformStand = false
                end
            end)
            return
        end
        if not hrp.Parent then
            conn:Disconnect()
            return
        end

        local spin = Vector3.new(math.random(-60,60), math.random(-60,60), math.random(-60,60))

        if mode == "simples" then
            applyPush(hrp, backDir, F, F * 0.15, nil)
        elseif mode == "lancar" then
            applyPush(hrp, backDir, F * 0.3, F * 1.4, nil)
        elseif mode == "rodopio" then
            applyPush(hrp, backDir, F * 0.2, F * 1.2, spin)
        elseif mode == "puxar" then
            if myRoot then
                local dir = (myRoot.Position - hrp.Position).Unit
                applyPush(hrp, dir, F * 1.1, F * 0.2, nil)
            end
        elseif mode == "meteoro" then
            applyPush(hrp, Vector3.zero, F * 2.5, nil, nil)
        elseif mode == "area" then
            -- trata todos no raio
            if myRoot then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character and plr ~= targetPlayer then
                        local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                        local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if tHRP and tHum then
                            local d = (tHRP.Position - myRoot.Position).Magnitude
                            if d <= rangeValue then
                                pcall(function() tHRP:SetNetworkOwner(LP) end)
                                local away = (tHRP.Position - myRoot.Position).Unit
                                applyPush(tHRP, away, F, F * 0.5, spin)
                                pcall(function() tHum.PlatformStand = true end)
                                task.delay(0.6, function()
                                    pcall(function() tHum.PlatformStand = false end)
                                end)
                            end
                        end
                    end
                end
                -- e o alvo principal
                local away = (hrp.Position - myRoot.Position).Unit
                applyPush(hrp, away, F, F * 0.5, spin)
            end
        end
    end)

    -- 5) Devolve ownership
    task.delay(1.5, function()
        pcall(function()
            if hrp and hrp.Parent then
                hrp:SetNetworkOwner(nil)
            end
        end)
    end)

    local ownText = ownOk and "own OK" or "own falhou"
    statusL.Text = "✔ " .. targetPlayer.Name .. " (" .. ownText .. ")"
    statusL.TextColor3 = ownOk and Color3.fromRGB(120, 220, 120) or Color3.fromRGB(220, 180, 100)

    setHist(mode .. " → " .. targetPlayer.Name)
end

-- ============================================================
-- BOTÕES
-- ============================================================
local function handleMode(mode)
    local target = getTarget()
    if target then
        targetLabel.Text = "Alvo: " .. target.Name
        targetLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
    else
        targetLabel.Text = "Alvo: ---"
        targetLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    end
    pushTarget(target, mode)
end

btnSimples.MouseButton1Click:Connect(function() handleMode("simples") end)
btnLancar.MouseButton1Click:Connect(function() handleMode("lancar") end)
btnRodopio.MouseButton1Click:Connect(function() handleMode("rodopio") end)
btnPuxar.MouseButton1Click:Connect(function() handleMode("puxar") end)
btnMeteoro.MouseButton1Click:Connect(function() handleMode("meteoro") end)
btnArea.MouseButton1Click:Connect(function() handleMode("area") end)

print("[Empurrao] Pronto!")