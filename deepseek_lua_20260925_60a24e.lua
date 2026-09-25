-- ============================================================
-- 🚀 BLOCO MÍSSIL v1 - FÍSICA REAL
-- ============================================================
print("[Missil] Carregando...")

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
    if c.Name == "BlocoMissil" then c:Destroy() end
end

-- ============================================================
-- GUI COMPACTA 195 x 340
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "BlocoMissil"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.Parent = guiParent

local tog = Instance.new("TextButton")
tog.Size = UDim2.new(0, 42, 0, 42)
tog.Position = UDim2.new(0, 12, 0.5, -21)
tog.BackgroundColor3 = Color3.fromRGB(220, 100, 40)
tog.TextColor3 = Color3.new(1,1,1)
tog.Text = "🚀"
tog.Font = Enum.Font.GothamBold
tog.TextSize = 18
tog.Parent = SG
Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)

local MF = Instance.new("Frame")
MF.Size = UDim2.new(0, 195, 0, 340)
MF.Position = UDim2.new(0.5, -97, 0.5, -170)
MF.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
MF.BorderSizePixel = 0
MF.Visible = false
MF.Active = true
MF.Parent = SG
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundColor3 = Color3.fromRGB(80, 40, 20)
title.TextColor3 = Color3.new(1,1,1)
title.Text = "🚀 Bloco Míssil"
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

-- Slider Velocidade
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -12, 0, 12)
speedLabel.Position = UDim2.new(0, 6, 0, 50)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
speedLabel.Text = "Velocidade: 250"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 9
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = MF

local speedBar = Instance.new("Frame")
speedBar.Size = UDim2.new(1, -12, 0, 5)
speedBar.Position = UDim2.new(0, 6, 0, 64)
speedBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
speedBar.BorderSizePixel = 0
speedBar.Parent = MF
Instance.new("UICorner", speedBar).CornerRadius = UDim.new(1, 0)

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0.5, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(220, 120, 60)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedBar
Instance.new("UICorner", speedFill).CornerRadius = UDim.new(1, 0)

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -12, 0, 16)
speedBtn.Position = UDim2.new(0, 6, 0, 64)
speedBtn.BackgroundTransparency = 1
speedBtn.Text = ""
speedBtn.Parent = MF

-- Slider Alcance da busca
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(1, -12, 0, 12)
rangeLabel.Position = UDim2.new(0, 6, 0, 84)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
rangeLabel.Text = "Busca: 60 studs"
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 9
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = MF

local rangeBar = Instance.new("Frame")
rangeBar.Size = UDim2.new(1, -12, 0, 5)
rangeBar.Position = UDim2.new(0, 6, 0, 98)
rangeBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
rangeBar.BorderSizePixel = 0
rangeBar.Parent = MF
Instance.new("UICorner", rangeBar).CornerRadius = UDim.new(1, 0)

local rangeFill = Instance.new("Frame")
rangeFill.Size = UDim2.new(0.3, 0, 1, 0)
rangeFill.BackgroundColor3 = Color3.fromRGB(100, 160, 220)
rangeFill.BorderSizePixel = 0
rangeFill.Parent = rangeBar
Instance.new("UICorner", rangeFill).CornerRadius = UDim.new(1, 0)

local rangeBtn = Instance.new("TextButton")
rangeBtn.Size = UDim2.new(1, -12, 0, 16)
rangeBtn.Position = UDim2.new(0, 6, 0, 98)
rangeBtn.BackgroundTransparency = 1
rangeBtn.Text = ""
rangeBtn.Parent = MF

local speedValue = 250
local rangeValue = 60

-- Botão Auto ON/OFF
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -12, 0, 20)
autoBtn.Position = UDim2.new(0, 6, 0, 118)
autoBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.Text = "🎯 Auto-mira: OFF"
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 10
autoBtn.Parent = MF
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 5)
local autoAim = false

-- Botão Lançar
local fireBtn = Instance.new("TextButton")
fireBtn.Size = UDim2.new(1, -12, 0, 30)
fireBtn.Position = UDim2.new(0, 6, 0, 142)
fireBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 40)
fireBtn.TextColor3 = Color3.new(1,1,1)
fireBtn.Text = "🚀 LANÇAR"
fireBtn.Font = Enum.Font.GothamBold
fireBtn.TextSize = 13
fireBtn.Parent = MF
Instance.new("UICorner", fireBtn).CornerRadius = UDim.new(0, 6)

-- Linha 2 de botões extras
local function mkSmallBtn(text, x, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 57, 0, 26)
    b.Position = UDim2.new(0, x, 0, 176)
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.Parent = MF
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local btnGiant = mkSmallBtn("💥 Gigante", 6, Color3.fromRGB(140, 60, 140))
local btnRapid = mkSmallBtn("⚡ Metralha", 66, Color3.fromRGB(180, 140, 40))
local btnSelect = mkSmallBtn("🔍 Escolher", 126, Color3.fromRGB(60, 110, 160))

-- Scroll de blocos
local scrollLbl = Instance.new("TextLabel")
scrollLbl.Size = UDim2.new(1, -12, 0, 12)
scrollLbl.Position = UDim2.new(0, 6, 0, 208)
scrollLbl.BackgroundTransparency = 1
scrollLbl.TextColor3 = Color3.fromRGB(160, 160, 180)
scrollLbl.Text = "Blocos próximos:"
scrollLbl.Font = Enum.Font.Gotham
scrollLbl.TextSize = 9
scrollLbl.TextXAlignment = Enum.TextXAlignment.Left
scrollLbl.Parent = MF

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 0, 90)
scroll.Position = UDim2.new(0, 6, 0, 222)
scroll.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = MF
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

local listL = Instance.new("UIListLayout")
listL.Padding = UDim.new(0, 2)
listL.SortOrder = Enum.SortOrder.LayoutOrder
listL.Parent = scroll

-- Status
local statusL = Instance.new("TextLabel")
statusL.Size = UDim2.new(1, -12, 0, 20)
statusL.Position = UDim2.new(0, 6, 1, -24)
statusL.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
statusL.TextColor3 = Color3.fromRGB(160, 180, 200)
statusL.Text = "Escolha um bloco"
statusL.Font = Enum.Font.Gotham
statusL.TextSize = 9
statusL.TextWrapped = true
statusL.Parent = MF
Instance.new("UICorner", statusL).CornerRadius = UDim.new(0, 5)

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
local function bindSlider(btn, fill, isSpeed)
    local dragging = false
    local function update(x)
        local bar = btn.Parent
        local ap = bar.AbsolutePosition
        local as = bar.AbsoluteSize
        local rel = math.clamp((x - ap.X) / as.X, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        if isSpeed then
            speedValue = math.floor(50 + rel * 450) -- 50 a 500
            speedLabel.Text = "Velocidade: " .. speedValue
        else
            rangeValue = math.floor(30 + rel * 170) -- 30 a 200
            rangeLabel.Text = "Busca: " .. rangeValue .. " studs"
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
bindSlider(speedBtn, speedFill, true)
bindSlider(rangeBtn, rangeFill, false)

autoBtn.MouseButton1Click:Connect(function()
    autoAim = not autoAim
    if autoAim then
        autoBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 60)
        autoBtn.Text = "🎯 Auto-mira: ON"
    else
        autoBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        autoBtn.Text = "🎯 Auto-mira: OFF"
    end
end)

-- ============================================================
-- BLOCO SELECIONADO
-- ============================================================
local selectedBlock = nil

local function isMyOrPlayerPart(part)
    local c = LP.Character
    if c and part:IsDescendantOf(c) then return true end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and part:IsDescendantOf(plr.Character) then
            return true
        end
    end
    return false
end

local function canBeMissile(part)
    if not part or not part.Parent then return false end
    if not part:IsA("BasePart") then return false end
    if part.Anchored then return false end
    if part.Name == "HumanoidRootPart" then return false end
    if isMyOrPlayerPart(part) then return false end
    return true
end

local function selectBlock(part)
    selectedBlock = part
    if part then
        statusL.Text = "Selecionado: " .. part.Name
        statusL.TextColor3 = Color3.fromRGB(120, 220, 120)
    else
        statusL.Text = "Escolha um bloco"
        statusL.TextColor3 = Color3.fromRGB(160, 180, 200)
    end
end

-- ============================================================
-- LISTA DE BLOCOS
-- ============================================================
local blockBtns = {}

local function refreshBlocks()
    for _, b in ipairs(blockBtns) do pcall(function() b:Destroy() end) end
    blockBtns = {}

    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local origin = root.Position
    local found = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if canBeMissile(obj) then
                local d = (obj.Position - origin).Magnitude
                if d <= rangeValue then
                    table.insert(found, {part = obj, dist = d})
                end
            end
        end)
    end

    table.sort(found, function(a,b) return a.dist < b.dist end)

    if #found == 0 then
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -6, 0, 22)
        l.BackgroundTransparency = 1
        l.Text = "Nenhum bloco solto perto"
        l.TextColor3 = Color3.fromRGB(150, 150, 170)
        l.Font = Enum.Font.Gotham
        l.TextSize = 9
        l.Parent = scroll
        blockBtns[#blockBtns+1] = l
    end

    for i = 1, math.min(#found, 50) do
        local entry = found[i]
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 22)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Text = string.format("%s  (%.0fs)", entry.part.Name, entry.dist)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 9
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            for _, o in ipairs(blockBtns) do
                if o:IsA("TextButton") then
                    o.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            selectBlock(entry.part)
        end)

        blockBtns[#blockBtns+1] = btn
    end

    task.wait()
    scroll.CanvasSize = UDim2.new(0, 0, 0, listL.AbsoluteContentSize.Y + 4)
end

-- ============================================================
-- ENCONTRAR ALVO
-- ============================================================
local function isPlayerPart(inst)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and inst:IsDescendantOf(p.Character) then
            return p
        end
    end
    return nil
end

local function getAimTarget()
    -- Se autoAim ON: mais próximo
    if autoAim then
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        local best, bestD = nil, rangeValue * 2
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - myRoot.Position).Magnitude
                    if d < bestD then best, bestD = p, d end
                end
            end
        end
        return best
    end
    -- Senão: raycast da câmera
    local unitRay = camera:ScreenPointToRay(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, selectedBlock }
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, params)
    if result then
        return isPlayerPart(result.Instance)
    end
    return nil
end

-- ============================================================
-- LANÇAR MÍSSIL
-- ============================================================
local function launchBlock(block, targetPlayer, giant)
    if not block or not block.Parent then return false end
    if not canBeMissile(block) then return false end

    -- Pega ownership
    pcall(function() block:SetNetworkOwner(LP) end)
    pcall(function() block.Massless = false end)

    -- Opção gigante: aumenta tamanho
    if giant then
        pcall(function()
            block.Size = block.Size * 2.5
        end)
    end

    -- Ponto de partida: 6 studs na frente da câmera
    local camCF = camera.CFrame
    local startPos = camCF.Position + camCF.LookVector * 6

    -- Direção: pro alvo, ou pra onde a câmera olha
    local direction
    if targetPlayer and targetPlayer.Character then
        local tHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tHRP then
            direction = (tHRP.Position - startPos).Unit
        end
    end
    if not direction then
        direction = camCF.LookVector
    end

    -- Aplica
    pcall(function()
        block.CFrame = CFrame.new(startPos, startPos + direction)
        block.AssemblyLinearVelocity = direction * speedValue
        block.AssemblyAngularVelocity = Vector3.new(
            math.random(-40, 40),
            math.random(-40, 40),
            math.random(-40, 40)
        )
    end)

    -- Rastreia por 3s: se bater em jogador, aplica um empurrão extra
    local trackedStart = tick()
    local touchedSet = {}
    local conn
    conn = block.Touched:Connect(function(hit)
        if tick() - trackedStart > 5 then
            pcall(function() conn:Disconnect() end)
            return
        end
        if touchedSet[hit] then return end
        local plr = isPlayerPart(hit)
        if plr then
            touchedSet[hit] = true
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                -- Empurra na direção do bloco
                local pushDir = block.AssemblyLinearVelocity.Unit
                pcall(function() hrp:SetNetworkOwner(LP) end)
                pcall(function()
                    hum.PlatformStand = true
                end)
                -- BodyVelocity garante o arremesso
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = pushDir * math.max(80, speedValue * 0.6) + Vector3.new(0, 50, 0)
                bv.P = 100000
                bv.Parent = hrp
                local bav = Instance.new("BodyAngularVelocity")
                bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bav.AngularVelocity = Vector3.new(
                    math.random(-60,60), math.random(-60,60), math.random(-60,60))
                bav.P = 100000
                bav.Parent = hrp
                task.delay(0.8, function()
                    pcall(function() bv:Destroy() end)
                    pcall(function() bav:Destroy() end)
                    pcall(function() hum.PlatformStand = false end)
                    pcall(function() hrp:SetNetworkOwner(nil) end)
                end)
            end
        end
    end)

    task.delay(6, function()
        pcall(function() conn:Disconnect() end)
    end)

    return true
end

-- ============================================================
-- BOTÕES
-- ============================================================
fireBtn.MouseButton1Click:Connect(function()
    if not selectedBlock or not selectedBlock.Parent then
        statusL.Text = "⚠ Selecione um bloco"
        statusL.TextColor3 = Color3.fromRGB(220, 120, 120)
        return
    end
    local target = getAimTarget()
    if target then
        targetLabel.Text = "Alvo: " .. target.Name
        targetLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
    else
        targetLabel.Text = "Alvo: direção"
        targetLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    end
    launchBlock(selectedBlock, target, false)
    statusL.Text = "🚀 Lançado!"
    statusL.TextColor3 = Color3.fromRGB(220, 160, 60)
end)

btnGiant.MouseButton1Click:Connect(function()
    if not selectedBlock or not selectedBlock.Parent then
        statusL.Text = "⚠ Selecione um bloco"
        statusL.TextColor3 = Color3.fromRGB(220, 120, 120)
        return
    end
    local target = getAimTarget()
    launchBlock(selectedBlock, target, true)
    statusL.Text = "💥 Gigante lançado!"
    statusL.TextColor3 = Color3.fromRGB(200, 120, 200)
end)

local rapidActive = false
local rapidConn = nil

btnRapid.MouseButton1Click:Connect(function()
    rapidActive = not rapidActive
    if rapidActive then
        btnRapid.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        btnRapid.Text = "⏹ Parar"
        statusL.Text = "⚡ Metralhadora ativa!"
        statusL.TextColor3 = Color3.fromRGB(220, 120, 120)
        rapidConn = task.spawn(function()
            while rapidActive do
                -- Pega um bloco aleatório da lista
                local char = LP.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local candidates = {}
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        pcall(function()
                            if canBeMissile(obj) then
                                local d = (obj.Position - root.Position).Magnitude
                                if d <= rangeValue then
                                    candidates[#candidates+1] = obj
                                end
                            end
                        end)
                    end
                    if #candidates > 0 then
                        local pick = candidates[math.random(1, #candidates)]
                        launchBlock(pick, getAimTarget(), false)
                    end
                end
                task.wait(0.18)
            end
        end)
    else
        btnRapid.BackgroundColor3 = Color3.fromRGB(180, 140, 40)
        btnRapid.Text = "⚡ Metralha"
        statusL.Text = "Metralhadora parada"
        statusL.TextColor3 = Color3.fromRGB(160, 180, 200)
        if rapidConn then
            task.cancel(rapidConn)
            rapidConn = nil
        end
    end
end)

btnSelect.MouseButton1Click:Connect(function()
    refreshBlocks()
    statusL.Text = "Lista atualizada (" .. rangeValue .. " studs)"
    statusL.TextColor3 = Color3.fromRGB(120, 200, 220)
end)

-- ============================================================
-- INICIALIZA
-- ============================================================
task.spawn(function()
    task.wait(1)
    refreshBlocks()
    print("[Missil] Pronto! Toque no 🚀")
end)

LP.CharacterAdded:Connect(function()
    task.wait(2)
    selectedBlock = nil
    rapidActive = false
    refreshBlocks()
end)