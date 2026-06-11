--[[
    SURVIVE APOCALYPSE FARM - UI Final
    Com minimizar e anti-puxao no teleporte
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Remotes
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local pickUpItemRemote = Remotes and Remotes:FindFirstChild("Interaction") and Remotes.Interaction:FindFirstChild("PickUpItem")
local adjustBackpackRemote = Remotes and Remotes:FindFirstChild("Tools") and Remotes.Tools:FindFirstChild("AdjustBackpack")

local droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")

local blacklist = {
    ["Chips"]=true, ["Carrot"]=true, ["Bloxiade"]=true, ["Beans"]=true, ["MRE"]=true, ["Bloxy Cola"]=true,
    ["Nuclear Fuel"]=true, ["Refined Fuel"]=true, ["Fuel"]=true,
    ["Power Armor Arm"]=true, ["Power Armor Core"]=true, ["Radio Tower Part"]=true,
    ["AC"]=true, ["Battery"]=true, ["Battery Pack"]=true, ["Bucket"]=true, ["Dumbell"]=true, ["Exhaust Pipe"]=true,
    ["Reactor Component"]=true, ["Refined Metal"]=true, ["Satellite Dish"]=true, ["Scrap"]=true, ["Screws"]=true,
    ["Spatula"]=true, ["Tray"]=true, ["TV"]=true, ["Watch"]=true, ["Zombie Heart"]=true,
    ["Airstrike"]=true, ["Attack Order"]=true, ["Call of the Dead"]=true, ["Summon Brute"]=true,
    ["Summon Zombies"]=true, ["Taunt"]=true, ["The Future"]=true, ["The Past"]=true, ["The Present"]=true,
}

pcall(function() if setsimulationradius then setsimulationradius(2048, 2048) end end)

local function getItemMainPart(item)
    if item.PrimaryPart then return item.PrimaryPart end
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

local flySpeed = 33
local isFarming = false
local totalCollected = 0
local basePosition = nil
local selectedItem = "Fuel"

-- ============================================
-- KILL AURA VARIABLES
-- ============================================
local killAuraConn = nil
local killAuraLastSwing = 0
local killAuraCurrentTarget = nil
local killAuraTargetDistance = nil
local killAuraEnabled = false
local killAuraAutoEquip = false
local killAuraShowIndicator = true
local killAuraExtendedRange = true
local killAuraRange = 6
local killAuraSwingRate = 0.5
local killAuraPriority = "Nearest"
local charactersFolder = Workspace:FindFirstChild("Characters")

-- ============================================
-- UI STATE
-- ============================================
local UI = {
    ScreenGui = nil,
    Main = nil,
    Dock = nil,
    Tabs = {},
    Pages = {},
    ActiveTab = nil,
    Minimized = false,
}

local farmItems = {
    "Fuel","Bandage","Knife","Crowbar","Pistol","Revolver","Grenade","Flashbang",
    "Bear Trap","Tear Gas","Battery","Chips","Beans","Scrap","Screws",
    "Bloxy Cola","Bloxiade","Shells","Long Ammo","Medium Ammo","Pistol Ammo"
}

local collectedLabel, backpackLabel, rangeLabel, swingLabel
local targetLabel, distanceLabel
local itemDropdownButton, itemDropdownList, itemDropdownValueLabel
local flySpeedLabel
local killAuraToggleButton, autoEquipToggleButton, extendedRangeToggleButton
local rangeValueLabel, swingValueLabel, priorityValueLabel

-- ============================================
-- ANTI-PUXAO PARA TELEPORTE
-- ============================================
local antiPullActive = false
local antiPullConn = nil

local function enableAntiPull()
    if antiPullConn then antiPullConn:Disconnect() end
    antiPullActive = true
    antiPullConn = RunService.Heartbeat:Connect(function()
        if not antiPullActive then
            antiPullConn:Disconnect()
            antiPullConn = nil
            return
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.zero
            char.HumanoidRootPart.RotVelocity = Vector3.zero
        end
    end)
end

local function disableAntiPull()
    antiPullActive = false
    if antiPullConn then
        antiPullConn:Disconnect()
        antiPullConn = nil
    end
end

-- ============================================
-- FUNÇÕES
-- ============================================

-- ============================================
-- KILL AURA FUNCTIONS
-- ============================================
local mobNames = {"Runner", "Crawler", "Riot", "Zombie", "Brute", "Spitter", "Boss"}

-- Weapon swing speeds (seconds between attacks)
local weaponSwingSpeeds = {
    ["Knife"] = 0.25,
    ["Katana"] = 0.3,
    ["Crowbar"] = 0.35,
    ["Bat"] = 0.45,
    ["Spiked Bat"] = 0.45,
    ["Hatchet"] = 0.4,
    ["Scythe"] = 0.4,
    ["Spear"] = 0.4,
    ["Fire Axe"] = 0.55,
    ["Sledgehammer"] = 0.6,
    ["Chainsaw"] = 0.35,
    ["Riot Shield"] = 0.5,
}

local function getWeaponSwingSpeed()
    local char = LocalPlayer.Character
    if not char then return 0.5 end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return 0.5 end
    
    local toolName = tool.Name
    
    if weaponSwingSpeeds[toolName] then
        return weaponSwingSpeeds[toolName]
    end
    
    for weaponName, speed in pairs(weaponSwingSpeeds) do
        if string.find(toolName:lower(), weaponName:lower()) then
            return speed
        end
    end
    
    return 0.5
end

local function findTargetsInRange(range)
    local char = LocalPlayer.Character
    if not char then return {} end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    if not charactersFolder then return {} end

    local playerCharSet = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            playerCharSet[p.Character] = true
        end
    end

    local targets = {}
    local myPos = hrp.Position

    for _, mob in ipairs(charactersFolder:GetChildren()) do
        if mob == char then continue end
        if playerCharSet[mob] then continue end

        local mobHRP = mob:FindFirstChild("HumanoidRootPart")
        local mobHum = mob:FindFirstChildOfClass("Humanoid")
        if not mobHRP or not mobHum then continue end
        if mobHum.Health <= 0 then continue end
        local dist = (mobHRP.Position - myPos).Magnitude
        if dist <= range then
            table.insert(targets, {
                mob = mob,
                dist = dist,
                health = mobHum.Health,
                maxHealth = mobHum.MaxHealth,
            })
        end
    end

    if killAuraPriority == "Nearest" then
        table.sort(targets, function(a, b) return a.dist < b.dist end)
    elseif killAuraPriority == "Lowest HP" then
        table.sort(targets, function(a, b) return a.health < b.health end)
    elseif killAuraPriority == "Highest HP" then
        table.sort(targets, function(a, b) return a.health > b.health end)
    end

    return targets
end

local function autoEquipWeapon()
    local char = LocalPlayer.Character
    if not char then return false end
    if char:FindFirstChildOfClass("Tool") then return true end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end

    local bestTool = nil
    local bestSpeed = math.huge

    for _, tool in ipairs(backpack:GetChildren()) do
        if not tool:IsA("Tool") then continue end
        if not (tool:FindFirstChild("Swing") or tool:FindFirstChild("HitTargets") or tool:FindFirstChild("RemoteClick")) then continue end
        local speed = weaponSwingSpeeds[tool.Name] or 0.5
        for wName, s in pairs(weaponSwingSpeeds) do
            if string.find(tool.Name:lower(), wName:lower()) then speed = s break end
        end
        if speed < bestSpeed then
            bestSpeed = speed
            bestTool = tool
        end
    end

    if bestTool then
        pcall(function() bestTool.Parent = char end)
        return true
    end
    return false
end

local function stopKillAura()
    if killAuraConn then
        killAuraConn:Disconnect()
        killAuraConn = nil
    end
    killAuraLastSwing = 0
    killAuraCurrentTarget = nil
    killAuraTargetDistance = nil
    pcall(function()
        if setsimulationradius then setsimulationradius(50, 300) end
    end)
end

local function startKillAura()
    stopKillAura()

    pcall(function()
        if setsimulationradius then setsimulationradius(1000, 1000) end
    end)

    killAuraConn = RunService.Heartbeat:Connect(function()
        if not killAuraEnabled then
            killAuraCurrentTarget = nil
            return
        end

        local success, err = pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local tool = char:FindFirstChildOfClass("Tool")
            if not tool and killAuraAutoEquip then
                autoEquipWeapon()
                tool = char:FindFirstChildOfClass("Tool")
            end

            if not tool then
                killAuraCurrentTarget = nil
                return
            end

            local swing = tool:FindFirstChild("Swing")
            local hitTargets = tool:FindFirstChild("HitTargets")
            local remoteClick = tool:FindFirstChild("RemoteClick")

            local baseRange = killAuraRange
            local useExtendedRange = killAuraExtendedRange
            local attackRange = useExtendedRange and (baseRange + 20) or baseRange

            local targets = findTargetsInRange(attackRange)
            killAuraCurrentTarget = targets[1] and targets[1].mob or nil
            killAuraTargetDistance = targets[1] and targets[1].dist or nil

            if #targets == 0 then
                killAuraCurrentTarget = nil
                killAuraTargetDistance = nil
                return
            end

            local weaponSpeed = getWeaponSwingSpeed()
            local userSwingRate = killAuraSwingRate
            local effectiveSwingRate = math.max(weaponSpeed, userSwingRate)
            local now = tick()
            if now - killAuraLastSwing < effectiveSwingRate then return end

            local mobModels = {}
            for _, t in ipairs(targets) do
                table.insert(mobModels, t.mob)
            end

            local attackSuccess = false

            if swing and hitTargets then
                local s1, e1 = pcall(function() swing:FireServer() end)
                if s1 then
                    killAuraLastSwing = now
                    attackSuccess = true
                    local s2, e2 = pcall(function() hitTargets:FireServer(mobModels) end)
                    if not s2 then warn("[KillAura] HitTargets error: " .. tostring(e2)) end
                else
                    warn("[KillAura] Swing error: " .. tostring(e1))
                end
            elseif remoteClick then
                local s, e = pcall(function() remoteClick:FireServer(targets[1].mob) end)
                attackSuccess = s
                if not s then warn("[KillAura] RemoteClick error: " .. tostring(e)) end
            end

            if attackSuccess and killAuraLastSwing ~= now then
                killAuraLastSwing = now
            end
        end)

        if not success then
            warn("[KillAura] Error: " .. tostring(err))
        end
    end)
end
local function collectItem(item)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local mainPart = item.PrimaryPart or getItemMainPart(item)
    local isBlacklisted = blacklist[item.Name] or false
    
    if not isBlacklisted then
        pcall(function() if pickUpItemRemote then pickUpItemRemote:FireServer(item) end end)
    end
    pcall(function() if adjustBackpackRemote then adjustBackpackRemote:FireServer(item) end end)
    
    if mainPart then
        pcall(function()
            if firetouchinterest then
                firetouchinterest(hrp, mainPart, 0)
                firetouchinterest(hrp, mainPart, 1)
            end
        end)
    end
    
    pcall(function()
        if fireproximityprompt then
            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then fireproximityprompt(prompt) end
        end
    end)
end

local function getItemPos(item)
    local pos = nil
    pcall(function()
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            if handle then pos = handle.Position end
        elseif item:IsA("Model") then
            pos = item:GetPivot().Position
        elseif item:IsA("BasePart") then
            pos = item.Position
        end
    end)
    return pos
end

local function getBackpackCount()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return 0 end
    local count = 0
    for _, child in ipairs(backpack:GetChildren()) do
        if child:IsA("Tool") then count = count + 1 end
    end
    return count
end

local function updateUI()
    local function setLabel(label, text)
        if not label then return end
        if label.SetText then
            label:SetText(text)
        elseif label.Set then
            label:Set(text)
        elseif label.Text ~= nil then
            label.Text = text
        end
    end

    setLabel(collectedLabel, "Coletados: " .. totalCollected)
    setLabel(backpackLabel, "Mochila: " .. getBackpackCount() .. " | Vel: " .. flySpeed)
    setLabel(rangeLabel, "Range: " .. killAuraRange .. " studs")
    setLabel(swingLabel, "Swing Delay: " .. killAuraSwingRate .. "s")
    setLabel(targetLabel, "Current Target: " .. (killAuraCurrentTarget and killAuraCurrentTarget.Name or "None"))
    setLabel(distanceLabel, "Target Distance: " .. (killAuraTargetDistance and string.format("%.1f", killAuraTargetDistance) or "-"))
end

local function getNearestItem(itemName)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local myPos = hrp.Position
    local nearest = nil
    local nearestDist = math.huge
    
    if not droppedItemsFolder then return nil end
    
    for _, item in ipairs(droppedItemsFolder:GetChildren()) do
        if item.Name:lower():find(itemName:lower()) then
            local pos = getItemPos(item)
            if pos then
                local dist = (pos - myPos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = {item = item, distance = dist, position = pos}
                end
            end
        end
    end
    
    return nearest
end

-- Voo
local function flyToPos(targetPos, speed)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not char or not hrp or not isFarming then
            conn:Disconnect()
            if humanoid then humanoid.PlatformStand = false end
            return
        end
        
        local currentPos = hrp.Position
        local direction = (targetPos - currentPos)
        local distance = direction.Magnitude
        
        if distance < 3 then
            conn:Disconnect()
            if humanoid then humanoid.PlatformStand = false end
            hrp.Velocity = Vector3.zero
            return
        end
        
        local moveDir = direction.Unit
        local moveSpeed = math.min(speed, distance)
        hrp.Velocity = moveDir * moveSpeed + Vector3.new(0, 5, 0)
        hrp.CFrame = CFrame.lookAt(currentPos, targetPos)
    end)
    
    while conn.Connected and isFarming do task.wait() end
end

local function startVooFarm(itemName)
    if isFarming then return end
    isFarming = true
    totalCollected = 0
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        basePosition = char.HumanoidRootPart.Position
    end
    
    spawn(function()
        while isFarming do
            local target = getNearestItem(itemName)
            
            if not target then
                isFarming = false
                break
            end
            
            if getBackpackCount() >= 10 then
                isFarming = false
                break
            end
            
            flyToPos(target.position + Vector3.new(0, 5, 0), flySpeed)
            
            if not isFarming then break end
            
            task.wait(0.2)
            collectItem(target.item)
            task.wait(0.1)
            collectItem(target.item)
            
            totalCollected = totalCollected + 1
            updateUI()
            
            task.wait(0.3)
        end
        
        isFarming = false
        if basePosition then
            flyToPos(basePosition + Vector3.new(0, 5, 0), flySpeed)
        end
        updateUI()
    end)
end

-- Teleporte COM ANTI-PUXÃO
local currentTeleportItem = nil

local function teleportToItem(itemName)
    local target = getNearestItem(itemName)
    if not target then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not basePosition then basePosition = hrp.Position end
    currentTeleportItem = {itemName = itemName}
    
    -- ATIVAR ANTI-PUXÃO antes do teleporte
    enableAntiPull()
    
    -- Teletransportar
    hrp.CFrame = CFrame.new(target.position + Vector3.new(0, 3, 0))
    
    -- Manter anti-puxão por 1 segundo para evitar ser puxado de volta
    task.wait(0.5)
    
    -- Coletar
    collectItem(target.item)
    task.wait(0.15)
    collectItem(target.item)
    
    totalCollected = totalCollected + 1
    updateUI()
    
    -- Desativar anti-puxão após coletar
    task.wait(0.5)
    disableAntiPull()
end

local function teleportToNext()
    if not currentTeleportItem then return end
    teleportToItem(currentTeleportItem.itemName)
end

local function teleportToBase()
    if not basePosition then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    enableAntiPull()
    hrp.CFrame = CFrame.new(basePosition)
    task.wait(0.5)
    disableAntiPull()
end

local function stopFarm()
    isFarming = false
    disableAntiPull()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
end

-- ============================================
-- MELI UI
-- ============================================
local colors = {
    Bg = Color3.fromRGB(14, 16, 21),
    Panel = Color3.fromRGB(21, 24, 31),
    Panel2 = Color3.fromRGB(28, 32, 41),
    Panel3 = Color3.fromRGB(34, 39, 50),
    Stroke = Color3.fromRGB(52, 58, 72),
    Text = Color3.fromRGB(242, 245, 248),
    Muted = Color3.fromRGB(170, 178, 190),
    Accent = Color3.fromRGB(75, 193, 255),
    Accent2 = Color3.fromRGB(88, 214, 160),
    Danger = Color3.fromRGB(255, 92, 92),
    Warning = Color3.fromRGB(255, 179, 71),
}

local mobileMode = UserInputService.TouchEnabled

local function clamp(v, minV, maxV)
    if v < minV then return minV end
    if v > maxV then return maxV end
    return v
end

local function round(n)
    return math.floor(n + 0.5)
end

local function new(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

local function addCorner(parent, radius)
    return new("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent,
    })
end

local function addStroke(parent, color, thickness)
    return new("UIStroke", {
        Color = color or colors.Stroke,
        Thickness = thickness or 1,
        Transparency = 0.15,
        Parent = parent,
    })
end

local function addPadding(parent, x, y)
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, x or 10),
        PaddingRight = UDim.new(0, x or 10),
        PaddingTop = UDim.new(0, y or 10),
        PaddingBottom = UDim.new(0, y or 10),
        Parent = parent,
    })
end

local function makeIcon(parent, kind, color)
    local icon = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(16, 16),
        Parent = parent,
    })

    if kind == "close" then
        for _, rot in ipairs({45, -45}) do
            new("Frame", {
                BackgroundColor3 = color or colors.Text,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(14, 2),
                Rotation = rot,
                Parent = icon,
            })
        end
    elseif kind == "min" then
        new("Frame", {
            BackgroundColor3 = color or colors.Text,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(14, 2),
            Parent = icon,
        })
    elseif kind == "menu" then
        for i = 1, 3 do
            new("Frame", {
                BackgroundColor3 = color or colors.Text,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(2, (i - 1) * 5 + 1),
                Size = UDim2.fromOffset(12, 2),
                Parent = icon,
            })
        end
    elseif kind == "chevron" then
        for _, rot in ipairs({45, -45}) do
            new("Frame", {
                BackgroundColor3 = color or colors.Muted,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(7, 2),
                Rotation = rot,
                Parent = icon,
            })
        end
    end

    return icon
end

local function getWindowSize()
    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize or Vector2.new(960, 540)
    if mobileMode then
        return UDim2.fromOffset(
            clamp(round(vp.X * 0.92), 320, 470),
            clamp(round(vp.Y * 0.82), 430, 660)
        )
    end
    return UDim2.fromOffset(580, 500)
end

local function setVisible(frame, visible)
    if frame then
        frame.Visible = visible
    end
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart
    local startPos
    local dragOffset
    local anchor

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        dragging = true
        dragStart = input.Position
        startPos = frame.AbsolutePosition
        dragOffset = input.Position - frame.AbsolutePosition
        anchor = frame.AnchorPoint
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local delta = input.Position - dragStart
        local camera = workspace.CurrentCamera
        local vp = camera and camera.ViewportSize or Vector2.new(960, 540)
        local topLeftX = clamp(startPos.X + delta.X - dragOffset.X, 0, math.max(0, vp.X - frame.AbsoluteSize.X))
        local topLeftY = clamp(startPos.Y + delta.Y - dragOffset.Y, 0, math.max(0, vp.Y - frame.AbsoluteSize.Y))
        frame.Position = UDim2.fromOffset(
            topLeftX + (frame.AbsoluteSize.X * anchor.X),
            topLeftY + (frame.AbsoluteSize.Y * anchor.Y)
        )
    end)
end

local function buildPage(parent, name)
    local page = new("ScrollingFrame", {
        Name = name .. "Page",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = colors.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = parent,
    })

    addPadding(page, 6, 6)

    new("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })

    return page
end

local function buildSection(parent, title, subtitle)
    local section = new("Frame", {
        BackgroundColor3 = colors.Panel,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = parent,
    })
    addCorner(section, 10)
    addStroke(section)
    addPadding(section, 10, 10)

    local layout = new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = section,
    })

    local header = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = colors.Text,
        TextSize = mobileMode and 14 or 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, mobileMode and 18 or 20),
        Parent = section,
    })
    if subtitle and subtitle ~= "" then
        new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = subtitle,
            TextColor3 = colors.Muted,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 28),
            Parent = section,
        })
    end

    return section
end

local function makeRow(parent, height)
    local row = new("Frame", {
        BackgroundColor3 = colors.Panel2,
        BorderSizePixel = 0,
        Active = true,
        Size = UDim2.new(1, 0, 0, height or 42),
        Parent = parent,
    })
    addCorner(row, 8)
    addStroke(row, colors.Stroke, 1)
    addPadding(row, 10, 8)
    return row
end

local function createButton(parent, text, callback, danger)
    local btn = new("TextButton", {
        BackgroundColor3 = danger and colors.Danger or colors.Panel3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, mobileMode and 42 or 40),
        Text = "",
        Parent = parent,
    })
    addCorner(btn, 8)
    addStroke(btn, danger and colors.Danger or colors.Stroke, 1)

    local accent = new("Frame", {
        BackgroundColor3 = danger and colors.Danger or colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = btn,
    })
    addCorner(accent, 8)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = colors.Text,
        TextSize = mobileMode and 13 or 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -26, 1, 0),
        Parent = btn,
    })

    btn.MouseButton1Click:Connect(function()
        task.spawn(callback)
    end)

    return btn
end

local function createLabel(parent, text, height)
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = colors.Text,
        TextSize = mobileMode and 12 or 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, height or 18),
        Parent = parent,
    })

    function label:SetText(textValue)
        self.Text = textValue
    end

    return label
end

local function createToggle(parent, text, defaultValue, callback)
    local state = defaultValue and true or false
    local row = makeRow(parent, mobileMode and 44 or 42)
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = colors.Text,
        TextSize = mobileMode and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -60, 1, 0),
        Parent = row,
    })

    local switch = new("Frame", {
        BackgroundColor3 = colors.Panel3,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(42, 22),
        Parent = row,
    })
    addCorner(switch, 11)
    addStroke(switch, colors.Stroke, 1)

    local knob = new("Frame", {
        BackgroundColor3 = colors.Text,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 3, 0.5, -7),
        Size = UDim2.fromOffset(14, 14),
        Parent = switch,
    })
    addCorner(knob, 7)

    local function render()
        switch.BackgroundColor3 = state and colors.Accent2 or colors.Panel3
        knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    end

    local function setValue(value, fire)
        state = value and true or false
        render()
        if fire ~= false then
            callback(state)
        end
    end

    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setValue(not state)
        end
    end)

    render()
    callback(state)

    return {
        SetValue = setValue,
        GetValue = function()
            return state
        end,
    }
end

local function createSlider(parent, text, minValue, maxValue, defaultValue, rounding, suffix, callback)
    local value = defaultValue
    local drag = false
    local row = makeRow(parent, mobileMode and 54 or 52)

    local top = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = row,
    })

    local title = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = colors.Text,
        TextSize = mobileMode and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -64, 1, 0),
        Parent = top,
    })

    local valueLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(value) .. (suffix or ""),
        TextColor3 = colors.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 1),
        Size = UDim2.new(0, 60, 1, 0),
        Parent = top,
    })

    local track = new("Frame", {
        BackgroundColor3 = colors.Panel3,
        BorderSizePixel = 0,
        Active = true,
        Position = UDim2.new(0, 0, 0, 28),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = row,
    })
    addCorner(track, 5)
    addStroke(track, colors.Stroke, 1)

    local fill = new("Frame", {
        BackgroundColor3 = colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = track,
    })
    addCorner(fill, 5)

    local function setValue(rawValue, fire)
        local decimals = rounding or 0
        local n = clamp(rawValue, minValue, maxValue)
        if decimals == 0 then
            n = round(n)
        else
            local mult = 10 ^ decimals
            n = math.floor(n * mult + 0.5) / mult
        end
        value = n
        local alpha = (value - minValue) / (maxValue - minValue)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        valueLabel.Text = tostring(value) .. (suffix or "")
        if fire ~= false then
            callback(value)
        end
    end

    local function fromInput(input)
        local x = clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        setValue(minValue + ((maxValue - minValue) * x))
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            fromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not drag then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            fromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    setValue(defaultValue, true)

    return {
        SetValue = setValue,
        GetValue = function()
            return value
        end,
    }
end

local function createDropdown(parent, text, options, defaultValue, callback)
    local row = makeRow(parent, 42)
    local open = false
    local value = defaultValue
    local rebuild

    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = colors.Text,
        TextSize = mobileMode and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -130, 1, 0),
        Parent = row,
    })

    local valueLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(value),
        TextColor3 = colors.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -26, 0.5, 0),
        Size = UDim2.new(0, 86, 1, 0),
        Parent = row,
    })

    local arrow = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Parent = row,
    })
    makeIcon(arrow, "chevron", colors.Muted)

    local list = new("Frame", {
        BackgroundColor3 = colors.Panel2,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = parent,
    })
    addCorner(list, 8)
    addStroke(list)
    addPadding(list, 8, 8)

    local listLayout = new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })

    local function setValue(newValue)
        value = newValue
        valueLabel.Text = tostring(value)
        rebuild()
        callback(value)
    end

    local function close()
        open = false
        list.Visible = false
        row.ZIndex = 1
    end

    local function openList()
        open = true
        list.Visible = true
        row.ZIndex = 2
    end

    rebuild = function()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, option in ipairs(options) do
            local optionButton = new("TextButton", {
                BackgroundColor3 = option == value and colors.Accent or colors.Panel3,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Size = UDim2.new(1, 0, 0, 32),
                Text = "",
                Parent = list,
            })
            addCorner(optionButton, 7)

            new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = option,
                TextColor3 = colors.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Parent = optionButton,
            })

            optionButton.MouseButton1Click:Connect(function()
                setValue(option)
                close()
            end)
        end
    end

    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if open then
                close()
            else
                openList()
            end
        end
    end)

    setValue(value)

    return {
        SetValue = setValue,
        GetValue = function()
            return value
        end,
        Refresh = rebuild,
    }
end

local function buildMeliUI()
    UI.ScreenGui = new("ScreenGui", {
        Name = "MeliUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Parent = game:GetService("CoreGui"),
    })

    local size = getWindowSize()
    UI.Main = new("Frame", {
        Name = "Main",
        BackgroundColor3 = colors.Bg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = size,
        Parent = UI.ScreenGui,
    })
    addCorner(UI.Main, 12)
    addStroke(UI.Main, colors.Stroke, 1)

    local topBar = new("Frame", {
        BackgroundColor3 = colors.Panel,
        BorderSizePixel = 0,
        Active = true,
        Size = UDim2.new(1, 0, 0, mobileMode and 44 or 46),
        Parent = UI.Main,
    })
    addCorner(topBar, 12)
    addStroke(topBar, colors.Stroke, 1)

    local title = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = "Meli UI",
        TextColor3 = colors.Text,
        TextSize = mobileMode and 15 or 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Parent = topBar,
    })

    local subtitle = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Farm and combat controls",
        TextColor3 = colors.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 14, 0, mobileMode and 20 or 22),
        Size = UDim2.new(1, -120, 0, 16),
        Parent = topBar,
    })

    local dragZone = new("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = true,
        Size = UDim2.new(1, -90, 1, 0),
        Parent = topBar,
    })

    local closeBtn = new("TextButton", {
        BackgroundColor3 = colors.Panel3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        Text = "",
        Parent = topBar,
    })
    addCorner(closeBtn, 8)
    addStroke(closeBtn, colors.Danger, 1)
    makeIcon(closeBtn, "close", colors.Text)

    local minimizeBtn = new("TextButton", {
        BackgroundColor3 = colors.Panel3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -44, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        Text = "",
        Parent = topBar,
    })
    addCorner(minimizeBtn, 8)
    addStroke(minimizeBtn, colors.Stroke, 1)
    makeIcon(minimizeBtn, "min", colors.Text)

    local tabBar = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, mobileMode and 52 or 54),
        Size = UDim2.new(1, -20, 0, 38),
        Parent = UI.Main,
    })

    local tabLayout = new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabBar,
    })

    local function makeTabButton(name)
        local btn = new("TextButton", {
            BackgroundColor3 = colors.Panel2,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Size = UDim2.new(0.5, -4, 1, 0),
            Text = "",
            Parent = tabBar,
        })
        addCorner(btn, 9)
        addStroke(btn, colors.Stroke, 1)

        local accent = new("Frame", {
            BackgroundColor3 = colors.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, 0),
            Parent = btn,
        })
        addCorner(accent, 8)

        local label = new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextColor3 = colors.Text,
            TextSize = mobileMode and 12 or 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Parent = btn,
        })

        return {
            Button = btn,
            SetActive = function(active)
                btn.BackgroundColor3 = active and colors.Panel3 or colors.Panel2
                accent.BackgroundColor3 = active and colors.Accent2 or colors.Accent
                label.TextColor3 = active and colors.Text or colors.Muted
            end,
        }
    end

    local content = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, mobileMode and 96 or 100),
        Size = UDim2.new(1, -20, 1, mobileMode and -104 or -108),
        Parent = UI.Main,
    })

    local farmPage = buildPage(content, "Farm")
    local killPage = buildPage(content, "KillAura")
    UI.Pages.Farm = farmPage
    UI.Pages.KillAura = killPage

    local tabs = {
        Farm = makeTabButton("Farm"),
        KillAura = makeTabButton("Kill Aura"),
    }
    UI.Tabs = tabs

    local function showTab(tabName)
        UI.ActiveTab = tabName
        for name, page in pairs(UI.Pages) do
            page.Visible = name == tabName
        end
        for name, tab in pairs(UI.Tabs) do
            tab.SetActive(name == tabName)
        end
    end

    tabs.Farm.Button.MouseButton1Click:Connect(function()
        showTab("Farm")
    end)
    tabs.KillAura.Button.MouseButton1Click:Connect(function()
        showTab("KillAura")
    end)

    local farmSection = buildSection(farmPage, "Farm", "Choose an item and run the farm or teleport tools.")
    local farmControls = buildSection(farmPage, "Controls")
    local farmStatus = buildSection(farmPage, "Status")

    local killSection = buildSection(killPage, "Kill Aura", "Combat controls and values for the current target.")
    local killStatus = buildSection(killPage, "Info")

    local farmDropdown = createDropdown(farmControls, "Selected Item", farmItems, selectedItem, function(value)
        selectedItem = value
    end)
    itemDropdownButton = farmDropdown

    local speedSlider = createSlider(farmControls, "Fly Speed", 10, 200, flySpeed, 0, "", function(value)
        flySpeed = value
        updateUI()
    end)
    flySpeedLabel = speedSlider

    createButton(farmControls, "Start Farm", function() startVooFarm(selectedItem) end)
    createButton(farmControls, "Teleport to Item", function() teleportToItem(selectedItem) end)
    createButton(farmControls, "Teleport Next", function() teleportToNext() end)
    createButton(farmControls, "Return to Base", function() teleportToBase() end)
    createButton(farmControls, "Stop Farm", function() stopFarm() end, true)

    collectedLabel = createLabel(farmStatus, "Collected: 0", 18)
    backpackLabel = createLabel(farmStatus, "Backpack: 0 | Speed: " .. flySpeed, 18)
    createLabel(farmStatus, "The window stays compact so it fits mobile screens better.", 32)

    local killToggle = createToggle(killSection, "Enable Kill Aura", killAuraEnabled, function(value)
        killAuraEnabled = value
        if value then
            startKillAura()
        else
            stopKillAura()
        end
    end)
    killAuraToggleButton = killToggle

    local autoEquipToggle = createToggle(killSection, "Auto-Equip Weapon", killAuraAutoEquip, function(value)
        killAuraAutoEquip = value
    end)
    autoEquipToggleButton = autoEquipToggle

    createToggle(killSection, "Show Target Indicator", killAuraShowIndicator, function(value)
        killAuraShowIndicator = value
    end)

    local extendedRangeToggle = createToggle(killSection, "Extended Range (+20)", killAuraExtendedRange, function(value)
        killAuraExtendedRange = value
    end)
    extendedRangeToggleButton = extendedRangeToggle

    local rangeSlider = createSlider(killSection, "Range", 2, 100, killAuraRange, 0, " studs", function(value)
        killAuraRange = value
        updateUI()
    end)
    rangeLabel = createLabel(killStatus, "Range: " .. killAuraRange .. " studs", 18)

    local swingSlider = createSlider(killSection, "Swing Delay", 0.1, 1, killAuraSwingRate, 2, "s", function(value)
        killAuraSwingRate = value
        updateUI()
    end)
    swingLabel = createLabel(killStatus, "Swing Delay: " .. killAuraSwingRate .. "s", 18)

    local priorityDropdown = createDropdown(killSection, "Priority", {"Nearest", "Lowest HP", "Highest HP"}, killAuraPriority, function(value)
        killAuraPriority = value
    end)
    createLabel(killStatus, "Priority controls the target order.", 18)
    targetLabel = createLabel(killStatus, "Current Target: None", 18)
    distanceLabel = createLabel(killStatus, "Target Distance: -", 18)

    createLabel(killStatus, "The combat code stays untouched; only the UI changed.", 34)

    local function minimize()
        UI.Minimized = true
        setVisible(UI.Main, false)
        setVisible(UI.Dock, true)
    end

    local function restore()
        UI.Minimized = false
        setVisible(UI.Dock, false)
        setVisible(UI.Main, true)
    end

    closeBtn.MouseButton1Click:Connect(function()
        stopFarm()
        stopKillAura()
        if UI.ScreenGui then
            UI.ScreenGui:Destroy()
        end
    end)

    minimizeBtn.MouseButton1Click:Connect(minimize)

    UI.Dock = new("TextButton", {
        BackgroundColor3 = colors.Panel,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Visible = false,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.fromOffset(110, 36),
        Text = "",
        Parent = UI.ScreenGui,
    })
    addCorner(UI.Dock, 10)
    addStroke(UI.Dock, colors.Stroke, 1)

    local dockMenu = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, -8),
        Size = UDim2.fromOffset(16, 16),
        Parent = UI.Dock,
    })
    makeIcon(dockMenu, "menu", colors.Text)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = "Meli UI",
        TextColor3 = colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Parent = UI.Dock,
    })

    UI.Dock.MouseButton1Click:Connect(restore)
    makeDraggable(UI.Main, dragZone)
    makeDraggable(UI.Dock, UI.Dock)

    showTab("Farm")
    updateUI()
end

buildMeliUI()

task.spawn(function()
    while true do
        updateUI()
        task.wait(2)
    end
end)

print("Meli UI loaded")
print("Anti-pull enabled for teleports")
