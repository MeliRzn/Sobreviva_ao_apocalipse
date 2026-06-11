--[[
    🎯 SURVIVE APOCALYPSE FARM - UI Final
    Com Minimizar + Anti-Puxão no Teleporte
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

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
-- ANTI-PUXÃO PARA TELEPORTE
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
-- UI
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "SAFarm"
gui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 550)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
mainFrame.Draggable = true
mainFrame.Active = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Botão de expandir (quando minimizado)
local expandBtn = Instance.new("TextButton")
expandBtn.Size = UDim2.new(0, 40, 0, 40)
expandBtn.Position = UDim2.new(0.93, 0, 0.5, 0)
expandBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
expandBtn.Text = "🎯"
expandBtn.TextSize = 20
expandBtn.Visible = false
expandBtn.Parent = gui
expandBtn.Draggable = true
Instance.new("UICorner", expandBtn).CornerRadius = UDim.new(0, 10)

-- Título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🎯 Survive Apocalypse Farm"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 15
titleText.Parent = titleBar

-- Botão minimizar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 30)
minimizeBtn.Text = "–"
minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Painel esquerdo
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 170, 1, -40)
leftPanel.Position = UDim2.new(0, 0, 0, 40)
leftPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
leftPanel.Parent = mainFrame

local leftTitle = Instance.new("TextLabel")
leftTitle.Size = UDim2.new(1, 0, 0, 28)
leftTitle.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
leftTitle.Text = "📦 Itens"
leftTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
leftTitle.Font = Enum.Font.GothamBold
leftTitle.TextSize = 12
leftTitle.Parent = leftPanel

local itemScroll = Instance.new("ScrollingFrame")
itemScroll.Size = UDim2.new(1, -10, 1, -32)
itemScroll.Position = UDim2.new(0, 5, 0, 32)
itemScroll.BackgroundTransparency = 1
itemScroll.BorderSizePixel = 0
itemScroll.ScrollBarThickness = 3
itemScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 130, 250)
itemScroll.Parent = leftPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = itemScroll
listLayout.Padding = UDim.new(0, 2)

local farmItems = {
    "Fuel","Bandage","Knife","Crowbar","Pistol","Revolver","Grenade","Flashbang",
    "Bear Trap","Tear Gas","Battery","Chips","Beans","Scrap","Screws",
    "Bloxy Cola","Bloxiade","Shells","Long Ammo","Medium Ammo","Pistol Ammo"
}

local itemButtons = {}

for _, itemName in ipairs(farmItems) do
    local itemBtn = Instance.new("TextButton")
    itemBtn.Size = UDim2.new(1, 0, 0, 30)
    itemBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    itemBtn.Text = itemName
    itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    itemBtn.Font = Enum.Font.Gotham
    itemBtn.TextSize = 12
    itemBtn.Parent = itemScroll
    Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 5)
    
    itemBtn.MouseButton1Click:Connect(function()
        for _, btn in ipairs(itemButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        end
        itemBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 80)
        selectedItem = itemName
    end)
    
    table.insert(itemButtons, itemBtn)
end

itemScroll.CanvasSize = UDim2.new(0, 0, 0, #farmItems * 32)

-- Painel direito
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -175, 1, -40)
rightPanel.Position = UDim2.new(0, 175, 0, 40)
rightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
rightPanel.Parent = mainFrame

-- Status
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -20, 0, 70)
statusFrame.Position = UDim2.new(0, 10, 0, 10)
statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statusFrame.Parent = rightPanel
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 8)

local collectedLabel = Instance.new("TextLabel")
collectedLabel.Size = UDim2.new(1, -20, 0, 25)
collectedLabel.Position = UDim2.new(0, 10, 0, 10)
collectedLabel.BackgroundTransparency = 1
collectedLabel.Text = "📦 Coletados: 0"
collectedLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
collectedLabel.Font = Enum.Font.GothamBold
collectedLabel.TextSize = 13
collectedLabel.TextXAlignment = Enum.TextXAlignment.Left
collectedLabel.Parent = statusFrame

local backpackLabel = Instance.new("TextLabel")
backpackLabel.Size = UDim2.new(1, -20, 0, 25)
backpackLabel.Position = UDim2.new(0, 10, 0, 38)
backpackLabel.BackgroundTransparency = 1
backpackLabel.Text = "🎒 Mochila: 0 | ⚡ Vel: 33"
backpackLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
backpackLabel.Font = Enum.Font.Gotham
backpackLabel.TextSize = 11
backpackLabel.TextXAlignment = Enum.TextXAlignment.Left
backpackLabel.Parent = statusFrame

-- Botões
local btnVoo = Instance.new("TextButton")
btnVoo.Size = UDim2.new(1, -20, 0, 38)
btnVoo.Position = UDim2.new(0, 10, 0, 90)
btnVoo.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
btnVoo.Text = "🕊️ INICIAR FARM (VOO)"
btnVoo.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVoo.Font = Enum.Font.GothamBold
btnVoo.TextSize = 13
btnVoo.Parent = rightPanel
Instance.new("UICorner", btnVoo).CornerRadius = UDim.new(0, 8)

local btnTeleport = Instance.new("TextButton")
btnTeleport.Size = UDim2.new(1, -20, 0, 38)
btnTeleport.Position = UDim2.new(0, 10, 0, 135)
btnTeleport.BackgroundColor3 = Color3.fromRGB(70, 130, 250)
btnTeleport.Text = "⚡ TELEPORTAR AO ITEM"
btnTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTeleport.Font = Enum.Font.GothamBold
btnTeleport.TextSize = 13
btnTeleport.Parent = rightPanel
Instance.new("UICorner", btnTeleport).CornerRadius = UDim.new(0, 8)

local btnNextTeleport = Instance.new("TextButton")
btnNextTeleport.Size = UDim2.new(1, -20, 0, 33)
btnNextTeleport.Position = UDim2.new(0, 10, 0, 180)
btnNextTeleport.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
btnNextTeleport.Text = "🔄 TELEPORTAR PRÓXIMO"
btnNextTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNextTeleport.Font = Enum.Font.GothamBold
btnNextTeleport.TextSize = 12
btnNextTeleport.Parent = rightPanel
Instance.new("UICorner", btnNextTeleport).CornerRadius = UDim.new(0, 6)

local btnBase = Instance.new("TextButton")
btnBase.Size = UDim2.new(0.47, 0, 0, 33)
btnBase.Position = UDim2.new(0, 10, 0, 220)
btnBase.BackgroundColor3 = Color3.fromRGB(255, 150, 30)
btnBase.Text = "🏠 BASE"
btnBase.TextColor3 = Color3.fromRGB(255, 255, 255)
btnBase.Font = Enum.Font.GothamBold
btnBase.TextSize = 12
btnBase.Parent = rightPanel
Instance.new("UICorner", btnBase).CornerRadius = UDim.new(0, 6)

local btnStop = Instance.new("TextButton")
btnStop.Size = UDim2.new(0.47, 0, 0, 33)
btnStop.Position = UDim2.new(0.53, -10, 0, 220)
btnStop.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
btnStop.Text = "⏹️ PARAR"
btnStop.TextColor3 = Color3.fromRGB(255, 255, 255)
btnStop.Font = Enum.Font.GothamBold
btnStop.TextSize = 12
btnStop.Parent = rightPanel
Instance.new("UICorner", btnStop).CornerRadius = UDim.new(0, 6)

-- Velocidade
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 260)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ Velocidade: 33"
speedLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 11
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = rightPanel

local btnSpeedUp = Instance.new("TextButton")
btnSpeedUp.Size = UDim2.new(0, 40, 0, 25)
btnSpeedUp.Position = UDim2.new(0, 10, 0, 283)
btnSpeedUp.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
btnSpeedUp.Text = "+10"
btnSpeedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSpeedUp.Font = Enum.Font.GothamBold
btnSpeedUp.TextSize = 12
btnSpeedUp.Parent = rightPanel
Instance.new("UICorner", btnSpeedUp).CornerRadius = UDim.new(0, 5)

local btnSpeedDown = Instance.new("TextButton")
btnSpeedDown.Size = UDim2.new(0, 40, 0, 25)
btnSpeedDown.Position = UDim2.new(0, 55, 0, 283)
btnSpeedDown.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
btnSpeedDown.Text = "-10"
btnSpeedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSpeedDown.Font = Enum.Font.GothamBold
btnSpeedDown.TextSize = 12
btnSpeedDown.Parent = rightPanel
Instance.new("UICorner", btnSpeedDown).CornerRadius = UDim.new(0, 5)

-- Kill Aura Section
local killAuraFrame = Instance.new("Frame")
killAuraFrame.Size = UDim2.new(1, -20, 0, 200)
killAuraFrame.Position = UDim2.new(0, 10, 0, 320)
killAuraFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
killAuraFrame.Parent = rightPanel
Instance.new("UICorner", killAuraFrame).CornerRadius = UDim.new(0, 8)

local killAuraTitle = Instance.new("TextLabel")
killAuraTitle.Size = UDim2.new(1, -20, 0, 25)
killAuraTitle.Position = UDim2.new(0, 10, 0, 10)
killAuraTitle.BackgroundTransparency = 1
killAuraTitle.Text = "⚔️ Kill Aura"
killAuraTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
killAuraTitle.Font = Enum.Font.GothamBold
killAuraTitle.TextSize = 13
killAuraTitle.TextXAlignment = Enum.TextXAlignment.Left
killAuraTitle.Parent = killAuraFrame

local btnKillAura = Instance.new("TextButton")
btnKillAura.Size = UDim2.new(1, -20, 0, 30)
btnKillAura.Position = UDim2.new(0, 10, 0, 40)
btnKillAura.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnKillAura.Text = "⚔️ ATIVAR KILL AURA"
btnKillAura.TextColor3 = Color3.fromRGB(255, 255, 255)
btnKillAura.Font = Enum.Font.GothamBold
btnKillAura.TextSize = 12
btnKillAura.Parent = killAuraFrame
Instance.new("UICorner", btnKillAura).CornerRadius = UDim.new(0, 6)

local btnAutoEquip = Instance.new("TextButton")
btnAutoEquip.Size = UDim2.new(0.47, 0, 0, 28)
btnAutoEquip.Position = UDim2.new(0, 10, 0, 80)
btnAutoEquip.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
btnAutoEquip.Text = "🔫 Auto-Equip: OFF"
btnAutoEquip.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoEquip.Font = Enum.Font.Gotham
btnAutoEquip.TextSize = 10
btnAutoEquip.Parent = killAuraFrame
Instance.new("UICorner", btnAutoEquip).CornerRadius = UDim.new(0, 5)

local btnExtendedRange = Instance.new("TextButton")
btnExtendedRange.Size = UDim2.new(0.47, 0, 0, 28)
btnExtendedRange.Position = UDim2.new(0.53, -10, 0, 80)
btnExtendedRange.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
btnExtendedRange.Text = "📏 Extended: ON"
btnExtendedRange.TextColor3 = Color3.fromRGB(255, 255, 255)
btnExtendedRange.Font = Enum.Font.Gotham
btnExtendedRange.TextSize = 10
btnExtendedRange.Parent = killAuraFrame
Instance.new("UICorner", btnExtendedRange).CornerRadius = UDim.new(0, 5)

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(1, -20, 0, 20)
rangeLabel.Position = UDim2.new(0, 10, 0, 120)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "📏 Range: 6 studs"
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 10
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = killAuraFrame

local btnRangeUp = Instance.new("TextButton")
btnRangeUp.Size = UDim2.new(0, 35, 0, 22)
btnRangeUp.Position = UDim2.new(0, 10, 0, 145)
btnRangeUp.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
btnRangeUp.Text = "+2"
btnRangeUp.TextColor3 = Color3.fromRGB(255, 255, 255)
btnRangeUp.Font = Enum.Font.GothamBold
btnRangeUp.TextSize = 11
btnRangeUp.Parent = killAuraFrame
Instance.new("UICorner", btnRangeUp).CornerRadius = UDim.new(0, 4)

local btnRangeDown = Instance.new("TextButton")
btnRangeDown.Size = UDim2.new(0, 35, 0, 22)
btnRangeDown.Position = UDim2.new(0, 50, 0, 145)
btnRangeDown.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnRangeDown.Text = "-2"
btnRangeDown.TextColor3 = Color3.fromRGB(255, 255, 255)
btnRangeDown.Font = Enum.Font.GothamBold
btnRangeDown.TextSize = 11
btnRangeDown.Parent = killAuraFrame
Instance.new("UICorner", btnRangeDown).CornerRadius = UDim.new(0, 4)

local priorityLabel = Instance.new("TextLabel")
priorityLabel.Size = UDim2.new(0, 100, 0, 22)
priorityLabel.Position = UDim2.new(0, 95, 0, 145)
priorityLabel.BackgroundTransparency = 1
priorityLabel.Text = "Priority: Nearest"
priorityLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
priorityLabel.Font = Enum.Font.Gotham
priorityLabel.TextSize = 10
priorityLabel.TextXAlignment = Enum.TextXAlignment.Left
priorityLabel.Parent = killAuraFrame

local btnPriority = Instance.new("TextButton")
btnPriority.Size = UDim2.new(0, 80, 0, 22)
btnPriority.Position = UDim2.new(0, 200, 0, 145)
btnPriority.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
btnPriority.Text = "Change"
btnPriority.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPriority.Font = Enum.Font.Gotham
btnPriority.TextSize = 10
btnPriority.Parent = killAuraFrame
Instance.new("UICorner", btnPriority).CornerRadius = UDim.new(0, 4)

local swingLabel = Instance.new("TextLabel")
swingLabel.Size = UDim2.new(1, -20, 0, 20)
swingLabel.Position = UDim2.new(0, 10, 0, 175)
swingLabel.BackgroundTransparency = 1
swingLabel.Text = "⏱️ Swing Delay: 0.5s"
swingLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
swingLabel.Font = Enum.Font.Gotham
swingLabel.TextSize = 10
swingLabel.TextXAlignment = Enum.TextXAlignment.Left
swingLabel.Parent = killAuraFrame

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
    collectedLabel.Text = "📦 Coletados: " .. totalCollected
    backpackLabel.Text = "🎒 Mochila: " .. getBackpackCount() .. " | ⚡ Vel: " .. flySpeed
    speedLabel.Text = "⚡ Velocidade: " .. flySpeed
    swingLabel.Text = "⏱️ Swing Delay: " .. killAuraSwingRate .. "s"
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

-- Eventos
btnVoo.MouseButton1Click:Connect(function() startVooFarm(selectedItem) end)
btnTeleport.MouseButton1Click:Connect(function() teleportToItem(selectedItem) end)
btnNextTeleport.MouseButton1Click:Connect(teleportToNext)
btnBase.MouseButton1Click:Connect(teleportToBase)
btnStop.MouseButton1Click:Connect(stopFarm)
closeBtn.MouseButton1Click:Connect(function() stopFarm(); stopKillAura(); gui:Destroy() end)

-- Kill Aura Events
btnKillAura.MouseButton1Click:Connect(function()
    killAuraEnabled = not killAuraEnabled
    if killAuraEnabled then
        btnKillAura.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        btnKillAura.Text = "⚔️ DESATIVAR KILL AURA"
        startKillAura()
    else
        btnKillAura.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnKillAura.Text = "⚔️ ATIVAR KILL AURA"
        stopKillAura()
    end
end)

btnAutoEquip.MouseButton1Click:Connect(function()
    killAuraAutoEquip = not killAuraAutoEquip
    if killAuraAutoEquip then
        btnAutoEquip.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        btnAutoEquip.Text = "🔫 Auto-Equip: ON"
    else
        btnAutoEquip.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btnAutoEquip.Text = "🔫 Auto-Equip: OFF"
    end
end)

btnExtendedRange.MouseButton1Click:Connect(function()
    killAuraExtendedRange = not killAuraExtendedRange
    if killAuraExtendedRange then
        btnExtendedRange.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
        btnExtendedRange.Text = "📏 Extended: +20"
    else
        btnExtendedRange.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btnExtendedRange.Text = "📏 Extended: OFF"
    end
end)

btnRangeUp.MouseButton1Click:Connect(function()
    killAuraRange = killAuraRange + 10
    if killAuraRange >= 1000 then
        rangeLabel.Text = "📏 Range: ∞ (Unlimited)"
    else
        rangeLabel.Text = "📏 Range: " .. killAuraRange .. " studs"
    end
end)

btnRangeDown.MouseButton1Click:Connect(function()
    killAuraRange = math.max(killAuraRange - 10, 2)
    if killAuraRange >= 1000 then
        rangeLabel.Text = "📏 Range: ∞ (Unlimited)"
    else
        rangeLabel.Text = "📏 Range: " .. killAuraRange .. " studs"
    end
end)

local priorities = {"Nearest", "Lowest HP", "Highest HP"}
local currentPriorityIndex = 1

btnPriority.MouseButton1Click:Connect(function()
    currentPriorityIndex = currentPriorityIndex % 3 + 1
    killAuraPriority = priorities[currentPriorityIndex]
    priorityLabel.Text = "Priority: " .. killAuraPriority
end)

-- Minimizar/Expandir
minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    expandBtn.Visible = true
end)

expandBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    expandBtn.Visible = false
end)

btnSpeedUp.MouseButton1Click:Connect(function()
    flySpeed = math.min(flySpeed + 10, 200)
    updateUI()
end)

btnSpeedDown.MouseButton1Click:Connect(function()
    flySpeed = math.max(flySpeed - 10, 10)
    updateUI()
end)

-- Atualizar UI
spawn(function() while true do updateUI(); task.wait(2) end end)

print("✅ Survive Apocalypse Farm carregado!")
print("🛡️ Anti-Puxão ativado no teleporte")
