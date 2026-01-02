--========================================
-- 🎣 AUTO FISHING NO MINIGAME + RAYFIELD
-- Custom CAST & REEL delay (Potion Bite friendly)
-- 1 Reel = 1 Fish
--========================================

-- Rayfield (Sirius)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--================ CONFIG ================
local AUTO_FISH = false

-- default (bisa diubah via slider)
local CAST_DELAY_MIN = 1.5
local CAST_DELAY_MAX = 2.0

local REEL_DELAY_MIN = 0.4   -- cocok potion bite 1s
local REEL_DELAY_MAX = 0.8

local SESSION_UPDATE_INTERVAL = 5
--=======================================

-- STATE
local lastCast = 0
local isReeling = false
local SESSION_ID = nil
local stats = {casts=0, catches=0, misses=0}

-- REMOTES
local throwRemote = ReplicatedStorage:FindFirstChild("Fishing_RemoteThrow")
local fishingFolder = ReplicatedStorage:FindFirstChild("Fishing")

if not throwRemote or not fishingFolder then
    warn("Fishing remote tidak ditemukan")
    return
end

local ToServer = fishingFolder:WaitForChild("ToServer")
local ToClient = fishingFolder:WaitForChild("ToClient")

--================ SESSION ID ================
local function UpdateSessionID()
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        local id = obj.Name:match("FishingRod_%d+_(%x+%-%x+%-%x+%-%x+%-%x+)_MinigameEnd")
        if id then
            SESSION_ID = id
            return
        end
    end
end

task.spawn(function()
    while true do
        UpdateSessionID()
        task.wait(SESSION_UPDATE_INTERVAL)
    end
end)

--================ RAYFIELD UI ================
local Window = Rayfield:CreateWindow({
    Name = "🎣 Auto Fishing (No Minigame)",
    LoadingTitle = "Auto Fishing",
    LoadingSubtitle = "Potion Bite Ready",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "AutoFishing_NoMini"
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateToggle({
    Name = "Enable Auto Fishing",
    CurrentValue = AUTO_FISH,
    Callback = function(v)
        AUTO_FISH = v
    end
})

MainTab:CreateSection("⏱️ Cast Delay")

MainTab:CreateSlider({
    Name = "Cast Delay (sec)",
    Range = {0.5, 5},
    Increment = 0.1,
    CurrentValue = 1.8,
    Callback = function(v)
        CAST_DELAY_MIN = math.max(0.3, v - 0.2)
        CAST_DELAY_MAX = v + 0.2
    end
})

MainTab:CreateSection("🎣 Reel Delay (Potion Bite 1s)")

MainTab:CreateSlider({
    Name = "Reel Delay (sec)",
    Range = {0.2, 3},
    Increment = 0.05,
    CurrentValue = 0.6,
    Callback = function(v)
        REEL_DELAY_MIN = math.max(0.2, v - 0.15)
        REEL_DELAY_MAX = v + 0.15
    end
})

MainTab:CreateSection("📊 Stats")

local StatsLabel = MainTab:CreateLabel("Casts: 0 | Fish: 0 | Miss: 0")

--================ AUTO REEL =================
local function AutoReel()
    local delayTime =
        math.random(REEL_DELAY_MIN*100, REEL_DELAY_MAX*100)/100
        + math.random(-10,10)/100 -- jitter ±0.1s

    task.delay(delayTime, function()
        if not isReeling or not SESSION_ID then return end

        ToServer.ReelFinished:FireServer({
            duration = math.random(1,3),
            result = "SUCCESS",
            insideRatio = math.random(80,90)/100
        }, SESSION_ID)
    end)
end

--================ AUTO CAST =================
RunService.RenderStepped:Connect(function()
    if not AUTO_FISH or isReeling or not SESSION_ID then return end

    local now = tick()
    local interval =
        math.random(CAST_DELAY_MIN*100, CAST_DELAY_MAX*100)/100

    if now - lastCast >= interval then
        lastCast = now
        isReeling = true
        stats.casts += 1

        -- cast pakai power + session
        throwRemote:FireServer(
            math.random(35,55)/100,
            SESSION_ID
        )

        AutoReel()
    end

    StatsLabel:Set(
        string.format(
            "Casts: %d | Fish: %d | Miss: %d",
            stats.casts, stats.catches, stats.misses
        )
    )
end)

--================ RESULT =================
ToClient:WaitForChild("Landed").OnClientEvent:Connect(function()
    stats.catches += 1
    isReeling = false
end)

ToClient:WaitForChild("NoBite").OnClientEvent:Connect(function()
    stats.misses += 1
    isReeling = false
end)

Rayfield:Notify({
    Title = "Auto Fishing Ready",
    Content = "Potion Bite 1s supported",
    Duration = 4
})

print("✅ Auto Fishing (No Minigame) Loaded")
