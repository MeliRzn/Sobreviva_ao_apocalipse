-- ============================================================
-- MOVER BLOCOS (REAL - REPLICA PRA TODOS) - v2 COMPACTO
-- ============================================================
print("[BlockMover] Iniciando...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then warn("[BlockMover] LocalPlayer nulo"); return end

local camera = Workspace.CurrentCamera
if not camera then
    repeat task.wait() until Workspace.CurrentCamera
    camera = Workspace.CurrentCamera
end
print("[BlockMover] Câmera OK")

-- ============================================================
-- PARENT DA GUI
-- ============================================================
local guiParent
do
    local ok, result = pcall(function() return gethui() end)
    if ok and result then guiParent = result
    else
        local ok2, core = pcall(function() return game:GetService("CoreGui") end)
        if ok2 and core then guiParent = core
        else guiParent = LocalPlayer:WaitForChild("PlayerGui") end
    end
end

for _, child in ipairs(guiParent:GetChildren()) do
    if child.Name == "BlockMoverReal" then child:Destroy() end
end

-- ============================================================
-- GUI COMPACTA
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlockMoverReal"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = guiParent

-- Botão toggle (menor)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 15, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 90, 160)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "🧱"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- Painel principal (compacto: 210x330)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 210, 0, 330)
mainFrame.Position = UDim2.new(0.5, -105, 0.5, -165)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Título (30px)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "🧱 Mover Blocos"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Fechar (26px)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -29, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)

-- Label raio
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(1, -16, 0, 16)
radiusLabel.Position = UDim2.new(0, 8, 0, 34)
radiusLabel.BackgroundTransparency = 1
radiusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
radiusLabel.Text = "Raio: 80 studs"
radiusLabel.Font = Enum.Font.Gotham
radiusLabel.TextSize = 10
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = mainFrame

-- Scroll (110px de altura)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -16, 0, 110)
scrollFrame.Position = UDim2.new(0, 8, 0, 52)
scrollFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 5
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFrame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 7)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 3)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- Botão atualizar
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.5, -11, 0, 24)
refreshBtn.Position = UDim2.new(0, 8, 0, 168)
refreshBtn.BackgroundColor3 = Color3.fromRGB(70, 90, 160)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Text = "🔄 Atualizar"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 11
refreshBtn.Parent = mainFrame
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)

-- Botão drag
local dragModeBtn = Instance.new("TextButton")
dragModeBtn.Size = UDim2.new(0.5, -11, 0, 24)
dragModeBtn.Position = UDim2.new(0.5, 3, 0, 168)
dragModeBtn.BackgroundColor3 = Color3.fromRGB(70, 90, 160)
dragModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dragModeBtn.Text = "✋ Arrastar"
dragModeBtn.Font = Enum.Font.GothamBold
dragModeBtn.TextSize = 11
dragModeBtn.Parent = mainFrame
Instance.new("UICorner", dragModeBtn).CornerRadius = UDim.new(0, 6)

-- Controles (3 colunas × 3 linhas, cada 60x24)
local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(1, -16, 0, 90)
controlsFrame.Position = UDim2.new(0, 8, 0, 198)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

local function makeCtrlBtn(text, x, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 60, 0, 24)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = color or Color3.fromRGB(55, 55, 75)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.Parent = controlsFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local step = 3
local btnFrente   = makeCtrlBtn("⬆ Frente", 0,   0)
local btnTras     = makeCtrlBtn("⬇ Trás",   65,  0)
local btnEsq      = makeCtrlBtn("⬅ Esq",    130, 0)
local btnDir      = makeCtrlBtn("➡ Dir",    0,   28)
local btnSubir    = makeCtrlBtn("⬆ Subir",  65,  28, Color3.fromRGB(60, 130, 60))
local btnDescer   = makeCtrlBtn("⬇ Descer", 130, 28, Color3.fromRGB(130, 70, 70))
local btnGirarEsq = makeCtrlBtn("↺ Girar",  0,   56, Color3.fromRGB(90, 80, 140))
local btnGirarDir = makeCtrlBtn("↻ Girar",  65,  56, Color3.fromRGB(90, 80, 140))
local btnTrazer   = makeCtrlBtn("🎯 Trazer", 130, 56, Color3.fromRGB(160, 120, 40))

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 16)
statusLabel.Position = UDim2.new(0, 8, 1, -20)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
statusLabel.Text = "Nenhum bloco"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

print("[BlockMover] GUI criada")

-- ============================================================
-- DRAG DA GUI
-- ============================================================
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

makeDraggable(mainFrame, title)

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- ============================================================
-- ESTADO
-- ============================================================
local selectedPart = nil
local selectedHighlight = nil
local partButtons = {}
local searchRadius = 80
local targetCFrame = nil
local holdConnection = nil

local function isMyOrPlayersPart(part)
    local char = LocalPlayer.Character
    if char and part:IsDescendantOf(char) then return true end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and part:IsDescendantOf(plr.Character) then
            return true
        end
    end
    return false
end

local function isMovable(part)
    if not part or not part.Parent then return false end
    if not part:IsA("BasePart") then return false end
    if part.Anchored then return false end
    if not part.CanCollide then return false end
    if part.Name == "HumanoidRootPart" then return false end
    if isMyOrPlayersPart(part) then return false end
    return true
end

local function grabOwnership(part)
    pcall(function() part:SetNetworkOwner(LocalPlayer) end)
    return part
end

local function clearHighlight()
    if selectedHighlight then
        selectedHighlight:Destroy()
        selectedHighlight = nil
    end
end

local function stopHolding()
    if holdConnection then
        pcall(function() holdConnection:Disconnect() end)
        holdConnection = nil
    end
    targetCFrame = nil
end

local function selectPart(part)
    stopHolding()
    selectedPart = nil

    if part then
        if not isMovable(part) then
            statusLabel.Text = "⚠ Bloco ancorado"
            statusLabel.TextColor3 = Color3.fromRGB(220, 120, 120)
            clearHighlight()
            return
        end

        selectedPart = grabOwnership(part)
        targetCFrame = selectedPart.CFrame

        clearHighlight()
        local hl = Instance.new("SelectionBox")
        hl.Adornee = selectedPart
        hl.Color3 = Color3.fromRGB(80, 180, 255)
        hl.LineThickness = 0.15
        hl.Transparency = 0.3
        hl.Parent = screenGui
        selectedHighlight = hl

        statusLabel.Text = "✔ " .. selectedPart.Name
        statusLabel.TextColor3 = Color3.fromRGB(120, 220, 120)

        holdConnection = RunService.RenderStepped:Connect(function()
            if selectedPart and selectedPart.Parent and targetCFrame then
                pcall(function()
                    selectedPart.CFrame = targetCFrame
                    if selectedPart.AssemblyLinearVelocity then
                        selectedPart.AssemblyLinearVelocity = Vector3.zero
                    end
                    if selectedPart.AssemblyAngularVelocity then
                        selectedPart.AssemblyAngularVelocity = Vector3.zero
                    end
                end)
            else
                stopHolding()
            end
        end)
    else
        clearHighlight()
        statusLabel.Text = "Nenhum bloco"
        statusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    end
end

-- ============================================================
-- LISTA
-- ============================================================
local function refreshList()
    for _, b in ipairs(partButtons) do
        pcall(function() b:Destroy() end)
    end
    partButtons = {}

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local origin = root.Position
    local found = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart")
            and not obj.Anchored
            and obj.CanCollide
            and not isMyOrPlayersPart(obj)
            and obj.Name ~= "HumanoidRootPart"
            then
                local dist = (obj.Position - origin).Magnitude
                if dist <= searchRadius then
                    table.insert(found, {part = obj, dist = dist})
                end
            end
        end)
    end

    table.sort(found, function(a, b) return a.dist < b.dist end)
    print("[BlockMover] Encontrados: " .. #found)

    if #found == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -6, 0, 24)
        empty.BackgroundTransparency = 1
        empty.Text = "Nada por perto"
        empty.TextColor3 = Color3.fromRGB(150, 150, 170)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 11
        empty.Parent = scrollFrame
        table.insert(partButtons, empty)
    end

    for i = 1, math.min(#found, 80) do
        local entry = found[i]
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Text = string.format("%s  (%.0fs)", entry.part.Name, entry.dist)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.Parent = scrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

        btn.MouseButton1Click:Connect(function()
            for _, other in ipairs(partButtons) do
                if other:IsA("TextButton") then
                    other.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            selectPart(entry.part)
        end)

        table.insert(partButtons, btn)
    end

    task.wait()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 6)
end

refreshBtn.MouseButton1Click:Connect(refreshList)

-- ============================================================
-- MOVIMENTOS
-- ============================================================
local function warnNoSelection()
    statusLabel.Text = "⚠ Selecione um bloco"
    statusLabel.TextColor3 = Color3.fromRGB(220, 120, 120)
end

local function moveBy(offset, rotateDeg)
    if not selectedPart or not selectedPart.Parent then
        warnNoSelection(); return
    end
    if rotateDeg then
        targetCFrame = targetCFrame * CFrame.Angles(0, math.rad(rotateDeg), 0)
    else
        targetCFrame = targetCFrame + offset
    end
end

btnFrente.MouseButton1Click:Connect(function() moveBy(Vector3.new(0, 0, -step)) end)
btnTras.MouseButton1Click:Connect(function() moveBy(Vector3.new(0, 0, step)) end)
btnEsq.MouseButton1Click:Connect(function() moveBy(Vector3.new(-step, 0, 0)) end)
btnDir.MouseButton1Click:Connect(function() moveBy(Vector3.new(step, 0, 0)) end)
btnSubir.MouseButton1Click:Connect(function() moveBy(Vector3.new(0, step, 0)) end)
btnDescer.MouseButton1Click:Connect(function() moveBy(Vector3.new(0, -step, 0)) end)
btnGirarEsq.MouseButton1Click:Connect(function() moveBy(nil, -15) end)
btnGirarDir.MouseButton1Click:Connect(function() moveBy(nil, 15) end)

btnTrazer.MouseButton1Click:Connect(function()
    if not selectedPart or not selectedPart.Parent then
        warnNoSelection(); return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    targetCFrame = root.CFrame * CFrame.new(0, 2, -6)
end)

-- ============================================================
-- MODO ARRASTAR (v2 - livre em qualquer direção)
-- ============================================================
local dragMode = false
local draggingPart = false
local planeNormal = nil
local planePoint = nil
local startTouchWorld = nil
local partStartCFrame = nil

dragModeBtn.MouseButton1Click:Connect(function()
    dragMode = not dragMode
    if dragMode then
        dragModeBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 40)
        dragModeBtn.Text = "✋ ON"
        statusLabel.Text = "Toque e mova o dedo (3D)"
        statusLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
    else
        dragModeBtn.BackgroundColor3 = Color3.fromRGB(70, 90, 160)
        dragModeBtn.Text = "✋ Arrastar"
        draggingPart = false
        if selectedPart then
            statusLabel.Text = "✔ " .. selectedPart.Name
        end
    end
end)

-- Raycast simples pra saber qual peça foi tocada
local function pickPart(screenPos)
    local unitRay = camera:ScreenPointToRay(screenPos.X, screenPos.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, params)
    if result then
        return result.Instance
    end
    return nil
end

-- Projeta o toque numa "parede invisível" virada pra câmera, que passa por planePoint.
-- Assim o bloco pode subir/descer acompanhando o dedo.
local function screenToCameraPlane(screenPos)
    local unitRay = camera:ScreenPointToRay(screenPos.X, screenPos.Y)
    local dir = unitRay.Direction
    local n = planeNormal
    local denom = dir:Dot(n)
    if math.abs(denom) < 1e-6 then return nil end
    local t = (planePoint - unitRay.Origin):Dot(n) / denom
    if t < 0 then return nil end
    return unitRay.Origin + dir * t
end

local function isOverGUI(pos)
    if mainFrame.Visible then
        local ap = mainFrame.AbsolutePosition
        local as = mainFrame.AbsoluteSize
        if pos.X >= ap.X and pos.X <= ap.X + as.X
        and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y then
            return true
        end
    end
    local ap = toggleBtn.AbsolutePosition
    local as = toggleBtn.AbsoluteSize
    if pos.X >= ap.X and pos.X <= ap.X + as.X
    and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y then
        return true
    end
    return false
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not dragMode then return end
    if input.UserInputType ~= Enum.UserInputType.Touch
    and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if isOverGUI(input.Position) then return end

    local hitPart = pickPart(input.Position)
    if hitPart and isMovable(hitPart) then
        selectPart(hitPart)
        draggingPart = true

        -- Define o plano perpendicular à câmera, passando pela posição do bloco
        planeNormal = camera.CFrame.LookVector
        planePoint = selectedPart.Position
        partStartCFrame = selectedPart.CFrame

        -- Ponto inicial do toque projetado no plano
        startTouchWorld = screenToCameraPlane(input.Position)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragMode or not draggingPart then return end
    if input.UserInputType ~= Enum.UserInputType.Touch
    and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    if not selectedPart or not selectedPart.Parent then
        draggingPart = false; return
    end

    -- Recalcula o plano conforme a câmera atual (gira junto)
    planeNormal = camera.CFrame.LookVector
    planePoint = partStartCFrame.Position

    local worldPoint = screenToCameraPlane(input.Position)
    if worldPoint and startTouchWorld then
        local delta = worldPoint - startTouchWorld
        targetCFrame = partStartCFrame + delta
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPart = false
    end
end)

-- ============================================================
-- INICIALIZA
-- ============================================================
task.spawn(function()
    task.wait(1)
    refreshList()
    print("[BlockMover] Pronto!")
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    selectPart(nil)
    refreshList()
end)

RunService.Heartbeat:Connect(function()
    if selectedPart and not selectedPart.Parent then
        selectPart(nil)
    end
end)