-- ============================================================
-- BONECO DOIDO v2 - FÍSICA REAL
-- ============================================================
print("[BonecoDoido] Carregando...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
if not LP then return end

-- GUI PARENT
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
    if c.Name == "BonecoDoido" then c:Destroy() end
end

local SG = Instance.new("ScreenGui")
SG.Name = "BonecoDoido"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.Parent = guiParent

-- Botão toggle
local tog = Instance.new("TextButton")
tog.Size = UDim2.new(0, 45, 0, 45)
tog.Position = UDim2.new(0, 15, 0.5, 40)
tog.BackgroundColor3 = Color3.fromRGB(140, 60, 160)
tog.TextColor3 = Color3.new(1,1,1)
tog.Text = "🌀"
tog.Font = Enum.Font.GothamBold
tog.TextSize = 20
tog.Parent = SG
Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)

-- Painel principal 220 x 360
local MF = Instance.new("Frame")
MF.Size = UDim2.new(0, 220, 0, 360)
MF.Position = UDim2.new(0.5, -110, 0.5, -180)
MF.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
MF.BorderSizePixel = 0
MF.Visible = false
MF.Active = true
MF.Parent = SG
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(60, 35, 80)
title.TextColor3 = Color3.new(1,1,1)
title.Text = "🌀 Boneco Doido v2"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = MF
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -29, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = MF
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)

-- Botão Doido + Reset
local btnCrazy = Instance.new("TextButton")
btnCrazy.Size = UDim2.new(0, 98, 0, 26)
btnCrazy.Position = UDim2.new(0, 8, 0, 34)
btnCrazy.BackgroundColor3 = Color3.fromRGB(90, 50, 130)
btnCrazy.TextColor3 = Color3.new(1,1,1)
btnCrazy.Text = "🌀 Doido"
btnCrazy.Font = Enum.Font.GothamBold
btnCrazy.TextSize = 11
btnCrazy.Parent = MF
Instance.new("UICorner", btnCrazy).CornerRadius = UDim.new(0, 6)

local btnReset = Instance.new("TextButton")
btnReset.Size = UDim2.new(0, 98, 0, 26)
btnReset.Position = UDim2.new(0, 114, 0, 34)
btnReset.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
btnReset.TextColor3 = Color3.new(1,1,1)
btnReset.Text = "🔄 Reset Tudo"
btnReset.Font = Enum.Font.GothamBold
btnReset.TextSize = 11
btnReset.Parent = MF
Instance.new("UICorner", btnReset).CornerRadius = UDim.new(0, 6)

-- Label física
local physLabel = Instance.new("TextLabel")
physLabel.Size = UDim2.new(1, -16, 0, 14)
physLabel.Position = UDim2.new(0, 8, 0, 64)
physLabel.BackgroundTransparency = 1
physLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
physLabel.Text = "Física do boneco:"
physLabel.Font = Enum.Font.Gotham
physLabel.TextSize = 10
physLabel.TextXAlignment = Enum.TextXAlignment.Left
physLabel.Parent = MF

-- 4 botões de física
local function mkPhysBtn(text, x, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 48, 0, 24)
    b.Position = UDim2.new(0, x, 0, 80)
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.Parent = MF
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local btnPhysNormal = mkPhysBtn("Normal", 8, Color3.fromRGB(55, 55, 75))
local btnPhysZero   = mkPhysBtn("SemFís", 60, Color3.fromRGB(70, 90, 160))
local btnPhysLeve   = mkPhysBtn("Leve", 112, Color3.fromRGB(60, 130, 60))
local btnPhysPesado = mkPhysBtn("Pesado", 164, Color3.fromRGB(150, 60, 60))

-- Label partes
local partLabel = Instance.new("TextLabel")
partLabel.Size = UDim2.new(1, -16, 0, 14)
partLabel.Position = UDim2.new(0, 8, 0, 108)
partLabel.BackgroundTransparency = 1
partLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
partLabel.Text = "Nome = física   +/- = tamanho"
partLabel.Font = Enum.Font.Gotham
partLabel.TextSize = 10
partLabel.TextXAlignment = Enum.TextXAlignment.Left
partLabel.Parent = MF

-- Scroll
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 0, 200)
scroll.Position = UDim2.new(0, 8, 0, 124)
scroll.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = MF
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 7)

local listL = Instance.new("UIListLayout")
listL.Padding = UDim.new(0, 3)
listL.SortOrder = Enum.SortOrder.LayoutOrder
listL.Parent = scroll

-- Status
local statusL = Instance.new("TextLabel")
statusL.Size = UDim2.new(1, -16, 0, 16)
statusL.Position = UDim2.new(0, 8, 1, -20)
statusL.BackgroundTransparency = 1
statusL.TextColor3 = Color3.fromRGB(160, 160, 180)
statusL.Text = "Pronto"
statusL.Font = Enum.Font.Gotham
statusL.TextSize = 10
statusL.TextXAlignment = Enum.TextXAlignment.Left
statusL.Parent = MF

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

-- ============================================================
-- HELPERS
-- ============================================================
local function getChar() return LP.Character end

local function getParts()
    local char = getChar()
    if not char then return {} end
    local list = {}
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then list[#list+1] = obj end
    end
    return list
end

local savedProps = {}   -- [part] = dados originais
local partState = {}    -- [part] = true se sem física

local function savePart(part)
    if savedProps[part] then return end
    local motors = {}
    for _, obj in ipairs(part.Parent:GetDescendants()) do
        if obj:IsA("Motor6D") and (obj.Part0 == part or obj.Part1 == part) then
            motors[#motors+1] = {m = obj, en = obj.Enabled}
        end
    end
    savedProps[part] = {
        size = part.Size,
        massless = part.Massless,
        cpp = part.CustomPhysicalProperties,
        cancollide = part.CanCollide,
        motors = motors,
    }
end

-- Remove física: desprende a parte (Motor6D off) + massless
-- NÃO mexe em CanCollide (isso era o bug que quebrava o boneco)
local function removePhysics(part)
    savePart(part)
    for _, entry in ipairs(savedProps[part].motors) do
        pcall(function() entry.m.Enabled = false end)
    end
    pcall(function() part.Massless = true end)
    partState[part] = true
end

local function restorePhysics(part)
    local s = savedProps[part]
    if not s then partState[part] = nil; return end
    pcall(function() part.Size = s.size end)
    pcall(function() part.Massless = s.massless end)
    pcall(function() part.CustomPhysicalProperties = s.cpp end)
    pcall(function() part.CanCollide = s.cancollide end)
    for _, entry in ipairs(s.motors) do
        pcall(function() entry.m.Enabled = entry.en end)
    end
    partState[part] = nil
end

local function growPart(part, factor)
    savePart(part)
    local s = part.Size
    local newSize = Vector3.new(
        math.clamp(s.X * factor, 0.1, 50),
        math.clamp(s.Y * factor, 0.1, 50),
        math.clamp(s.Z * factor, 0.1, 50)
    )
    pcall(function() part.Size = newSize end)
end

-- ============================================================
-- MODO DOIDO (não voa mais - fica tremendo/rodando no lugar)
-- ============================================================
local crazyActive = false
local crazyConns = {}
local gravityOrig = Workspace.Gravity

local function stopCrazy()
    crazyActive = false
    for _, c in ipairs(crazyConns) do
        pcall(function() c:Disconnect() end)
    end
    crazyConns = {}
    local char = getChar()
    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj.Name == "BonecoDoido_AV" then
                pcall(function() obj:Destroy() end)
            end
        end
    end
    pcall(function() Workspace.Gravity = gravityOrig end)
end

local function startCrazy()
    if crazyActive then return end
    crazyActive = true

    local char = getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    gravityOrig = Workspace.Gravity
    -- Reduz gravidade SÓ em 60% (não zera, senão voa)
    pcall(function() Workspace.Gravity = gravityOrig * 0.4 end)

    -- Giro
    local av = Instance.new("BodyAngularVelocity")
    av.Name = "BonecoDoido_AV"
    av.AngularVelocity = Vector3.new(3, 5, 3)
    av.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    av.P = 3000
    av.Parent = hrp

    -- Impulsos PEQUENOS e frequentes (não deixa voar)
    local accum = 0
    local conn = RunService.Heartbeat:Connect(function(dt)
        if not crazyActive then return end
        if not hrp.Parent then return end
        accum = accum + dt
        if accum > 0.12 then
            accum = 0
            pcall(function()
                hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + Vector3.new(
                    math.random(-5, 5),
                    math.random(-2, 4),
                    math.random(-5, 5)
                )
                av.AngularVelocity = Vector3.new(
                    math.random(-12, 12),
                    math.random(-12, 12),
                    math.random(-12, 12)
                )
            end)
        end
    end)
    crazyConns[#crazyConns+1] = conn
end

-- ============================================================
-- MODOS DE FÍSICA DO CORPO INTEIRO
-- ============================================================
local function resetPhys()
    local char = getChar()
    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj.Name == "BonecoDoido_BF" then
                pcall(function() obj:Destroy() end)
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end)
        end
        for part, s in pairs(savedProps) do
            if part and part.Parent then
                pcall(function() part.Massless = s.massless end)
                pcall(function() part.CustomPhysicalProperties = s.cpp end)
            end
        end
    end
    btnPhysNormal.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btnPhysZero.BackgroundColor3 = Color3.fromRGB(70, 90, 160)
    btnPhysLeve.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
    btnPhysPesado.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
end

local function applyPhys(mode)
    resetPhys()
    if mode == "normal" then
        btnPhysNormal.BackgroundColor3 = Color3.fromRGB(200, 140, 40)
        statusL.Text = "Física normal"
        statusL.TextColor3 = Color3.fromRGB(160, 160, 180)
        return
    end

    local char = getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp then return end

    if mode == "semfis" then
        -- Tira peso de todas as partes
        for _, part in ipairs(getParts()) do
            savePart(part)
            pcall(function() part.Massless = true end)
        end
        -- Força pra cima (counter-gravidade)
        local f = Instance.new("BodyForce")
        f.Name = "BonecoDoido_BF"
        f.Force = Vector3.new(0, 5000, 0)
        f.Parent = hrp

        btnPhysZero.BackgroundColor3 = Color3.fromRGB(200, 140, 40)
        statusL.Text = "Sem física (flutuando)"
        statusL.TextColor3 = Color3.fromRGB(120, 180, 240)
    elseif mode == "leve" then
        for _, part in ipairs(getParts()) do
            savePart(part)
            pcall(function()
                part.Massless = true
                part.CustomPhysicalProperties = PhysicalProperties.new(0.1, 0.3, 0.1, 0.5, 0.5)
            end)
        end
        if hum then
            pcall(function()
                hum.WalkSpeed = 30
                hum.JumpPower = 120
            end)
        end
        btnPhysLeve.BackgroundColor3 = Color3.fromRGB(200, 140, 40)
        statusL.Text = "Leve (rápido e pulante)"
        statusL.TextColor3 = Color3.fromRGB(120, 220, 120)
    elseif mode == "pesado" then
        for _, part in ipairs(getParts()) do
            savePart(part)
            pcall(function()
                part.CustomPhysicalProperties = PhysicalProperties.new(20, 0.5, 0.5, 1, 1)
            end)
        end
        if hum then
            pcall(function()
                hum.WalkSpeed = 6
                hum.JumpPower = 12
            end)
        end
        btnPhysPesado.BackgroundColor3 = Color3.fromRGB(200, 140, 40)
        statusL.Text = "Pesado (lento e duro)"
        statusL.TextColor3 = Color3.fromRGB(220, 120, 120)
    end
end

-- ============================================================
-- LISTA DE PARTES (com + / -)
-- ============================================================
local partRows = {}

local function refreshParts()
    for _, r in ipairs(partRows) do
        pcall(function() r:Destroy() end)
    end
    partRows = {}

    local parts = getParts()
    table.sort(parts, function(a,b) return a.Name < b.Name end)

    if #parts == 0 then
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -6, 0, 24)
        l.BackgroundTransparency = 1
        l.Text = "Sem personagem"
        l.TextColor3 = Color3.fromRGB(150, 150, 170)
        l.Font = Enum.Font.Gotham
        l.TextSize = 11
        l.Parent = scroll
        partRows[#partRows+1] = l
    end

    for _, part in ipairs(parts) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, 26)
        row.BackgroundTransparency = 1
        row.Parent = scroll
        partRows[#partRows+1] = row

        local nameBtn = Instance.new("TextButton")
        nameBtn.Size = UDim2.new(0, 122, 1, 0)
        nameBtn.Position = UDim2.new(0, 0, 0, 0)
        nameBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        nameBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        nameBtn.Text = part.Name
        nameBtn.Font = Enum.Font.Gotham
        nameBtn.TextSize = 10
        nameBtn.TextTruncate = Enum.TextTruncate.AtEnd
        nameBtn.Parent = row
        Instance.new("UICorner", nameBtn).CornerRadius = UDim.new(0, 5)

        if partState[part] then
            nameBtn.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
            nameBtn.Text = part.Name .. " ⚠"
        end

        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 28, 1, 0)
        plusBtn.Position = UDim2.new(0, 126, 0, 0)
        plusBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
        plusBtn.TextColor3 = Color3.new(1,1,1)
        plusBtn.Text = "+"
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.TextSize = 13
        plusBtn.Parent = row
        Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 5)

        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 28, 1, 0)
        minusBtn.Position = UDim2.new(0, 158, 0, 0)
        minusBtn.BackgroundColor3 = Color3.fromRGB(130, 60, 60)
        minusBtn.TextColor3 = Color3.new(1,1,1)
        minusBtn.Text = "−"
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.TextSize = 13
        minusBtn.Parent = row
        Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 5)

        nameBtn.MouseButton1Click:Connect(function()
            if not part.Parent then return end
            if partState[part] then
                restorePhysics(part)
                nameBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
                nameBtn.Text = part.Name
            else
                removePhysics(part)
                nameBtn.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
                nameBtn.Text = part.Name .. " ⚠"
            end
        end)

        plusBtn.MouseButton1Click:Connect(function()
            if not part.Parent then return end
            growPart(part, 1.25)
            nameBtn.Text = string.format("%s (%.1f)", part.Name, part.Size.X)
        end)

        minusBtn.MouseButton1Click:Connect(function()
            if not part.Parent then return end
            growPart(part, 0.8)
            nameBtn.Text = string.format("%s (%.1f)", part.Name, part.Size.X)
        end)
    end

    task.wait()
    scroll.CanvasSize = UDim2.new(0, 0, 0, listL.AbsoluteContentSize.Y + 6)
end

-- ============================================================
-- BOTÕES
-- ============================================================
btnCrazy.MouseButton1Click:Connect(function()
    if crazyActive then
        stopCrazy()
        btnCrazy.BackgroundColor3 = Color3.fromRGB(90, 50, 130)
        btnCrazy.Text = "🌀 Doido"
        statusL.Text = "Doido desligado"
        statusL.TextColor3 = Color3.fromRGB(160, 160, 180)
    else
        startCrazy()
        btnCrazy.BackgroundColor3 = Color3.fromRGB(200, 100, 40)
        btnCrazy.Text = "🌀 ON"
        statusL.Text = "Doido ativo (tremendo)"
        statusL.TextColor3 = Color3.fromRGB(220, 140, 100)
    end
end)

btnReset.MouseButton1Click:Connect(function()
    stopCrazy()
    resetPhys()
    for part, _ in pairs(partState) do
        if part and part.Parent then
            restorePhysics(part)
        end
    end
    partState = {}
    for part, s in pairs(savedProps) do
        if part and part.Parent then
            pcall(function() part.Size = s.size end)
        end
    end
    btnCrazy.BackgroundColor3 = Color3.fromRGB(90, 50, 130)
    btnCrazy.Text = "🌀 Doido"
    statusL.Text = "Tudo resetado ✔"
    statusL.TextColor3 = Color3.fromRGB(120, 220, 120)
    refreshParts()
end)

btnPhysNormal.MouseButton1Click:Connect(function() applyPhys("normal") end)
btnPhysZero.MouseButton1Click:Connect(function() applyPhys("semfis") end)
btnPhysLeve.MouseButton1Click:Connect(function() applyPhys("leve") end)
btnPhysPesado.MouseButton1Click:Connect(function() applyPhys("pesado") end)

-- ============================================================
-- INICIALIZA
-- ============================================================
task.spawn(function()
    task.wait(1)
    refreshParts()
    print("[BonecoDoido] Pronto!")
end)

LP.CharacterAdded:Connect(function()
    task.wait(2)
    stopCrazy()
    resetPhys()
    savedProps = {}
    partState = {}
    crazyActive = false
    refreshParts()
end)