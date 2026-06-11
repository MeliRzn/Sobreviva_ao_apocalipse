--[[
    🎯 SURVIVE APOCALYPSE FARM - UI Final
    Com Minimizar + Anti-Puxão no Teleporte
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Load Linoria UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Toggles = Library.Toggles or getgenv().Toggles
local Options = Library.Options or getgenv().Options

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
local Window, FarmTab, KillAuraTab

local farmItems = {
    "Fuel","Bandage","Knife","Crowbar","Pistol","Revolver","Grenade","Flashbang",
    "Bear Trap","Tear Gas","Battery","Chips","Beans","Scrap","Screws",
    "Bloxy Cola","Bloxiade","Shells","Long Ammo","Medium Ammo","Pistol Ammo"
}

local collectedLabel, backpackLabel, rangeLabel, swingLabel

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

            if #targets == 0 then return end

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
-- LINORIA UI
-- ============================================
local function setupLinoriaUI()
    Window = Library:CreateWindow({
        Title = "SA Farm + Kill Aura",
        Center = true,
        AutoShow = true,
        Size = UDim2.fromOffset(620, 520),
    })

    FarmTab = Window:AddTab("Farm")
    KillAuraTab = Window:AddTab("Kill Aura")

    local farmGroup = FarmTab:AddLeftGroupbox("Farm")
    local statusGroup = FarmTab:AddRightGroupbox("Status")
    local auraGroup = KillAuraTab:AddLeftGroupbox("Kill Aura")
    local auraInfoGroup = KillAuraTab:AddRightGroupbox("Info")

    farmGroup:AddDropdown("SelectedFarmItem", {
        Values = farmItems,
        Default = 1,
        Text = "Item",
        Callback = function(value)
            selectedItem = value
        end,
    })

    farmGroup:AddSlider("FlySpeed", {
        Text = "Fly Speed",
        Default = flySpeed,
        Min = 10,
        Max = 200,
        Rounding = 0,
        Callback = function(value)
            flySpeed = value
            updateUI()
        end,
    })

    farmGroup:AddButton({ Text = "Start Farm (Voo)", Func = function() startVooFarm(selectedItem) end })
    farmGroup:AddButton({ Text = "Teleportar ao Item", Func = function() teleportToItem(selectedItem) end })
    farmGroup:AddButton({ Text = "Teleportar Proximo", Func = function() teleportToNext() end })
    farmGroup:AddButton({ Text = "Voltar para Base", Func = function() teleportToBase() end })
    farmGroup:AddButton({ Text = "Parar Farm", Func = function() stopFarm() end })

    collectedLabel = statusGroup:AddLabel("Coletados: 0")
    backpackLabel = statusGroup:AddLabel("Mochila: 0 | Vel: " .. flySpeed)

    auraGroup:AddToggle("KillAuraEnabled", {
        Text = "Enable Kill Aura",
        Default = killAuraEnabled,
        Callback = function(value)
            killAuraEnabled = value
            if value then
                startKillAura()
            else
                stopKillAura()
            end
        end,
    })

    auraGroup:AddToggle("KillAuraAutoEquip", {
        Text = "Auto-Equip Weapon",
        Default = killAuraAutoEquip,
        Callback = function(value)
            killAuraAutoEquip = value
        end,
    })

    auraGroup:AddToggle("KillAuraExtendedRange", {
        Text = "Extended Range (+20)",
        Default = killAuraExtendedRange,
        Callback = function(value)
            killAuraExtendedRange = value
        end,
    })

    auraGroup:AddSlider("KillAuraRange", {
        Text = "Range",
        Default = killAuraRange,
        Min = 2,
        Max = 100,
        Rounding = 0,
        Suffix = " studs",
        Callback = function(value)
            killAuraRange = value
            updateUI()
        end,
    })

    auraGroup:AddSlider("KillAuraSwingRate", {
        Text = "Swing Delay",
        Default = killAuraSwingRate,
        Min = 0.1,
        Max = 1,
        Rounding = 2,
        Suffix = "s",
        Callback = function(value)
            killAuraSwingRate = value
            updateUI()
        end,
    })

    auraGroup:AddDropdown("KillAuraPriority", {
        Values = {"Nearest", "Lowest HP", "Highest HP"},
        Default = 1,
        Text = "Priority",
        Callback = function(value)
            killAuraPriority = value
        end,
    })

    rangeLabel = auraInfoGroup:AddLabel("Range: " .. killAuraRange .. " studs")
    swingLabel = auraInfoGroup:AddLabel("Swing Delay: " .. killAuraSwingRate .. "s")
    auraInfoGroup:AddLabel("Extended Range soma +20 studs quando ligado.", true)
    auraInfoGroup:AddLabel("Auto-Equip tenta equipar a arma mais rapida da mochila.", true)

    updateUI()
end

setupLinoriaUI()

-- Atualizar UI
spawn(function() while true do updateUI(); task.wait(2) end end)

print("SA Farm + Kill Aura carregado com Linoria UI")
print("Anti-Puxao ativado no teleporte")
