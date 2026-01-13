--==================================================
-- 🎣 AUTO FISHING (NO STARTBITE)
-- CAST → DELAY → ReelFinished
-- 1 REEL = 1 FISH (STABLE)
--==================================================

-- Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Player
local LocalPlayer = Players.LocalPlayer

-- Remotes
local ThrowRemote = ReplicatedStorage:WaitForChild("Fishing_RemoteThrow")
local Fishing = ReplicatedStorage:WaitForChild("Fishing")
local ToClient = Fishing:WaitForChild("ToClient")
local ToServer = Fishing:WaitForChild("ToServer")

--================ CONFIG =================
local AUTO_FISH = false
local CAST_MIN = 1.8
local CAST_MAX = 2.4
local REEL_DELAY_MIN = 4
local REEL_DELAY_MAX = 5
local SESSION_SCAN_INTERVAL = 5
--========================================

-- State
local SESSION_ID = nil
local lastCast = 0
local isReeling = false

local stats = {casts = 0, catches = 0, misses = 0}

--================ SESSION SCAN =================
local function UpdateSession()
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
        UpdateSession()
        task.wait(SESSION_SCAN_INTERVAL)
    end
end)

--================ UI =================
local Window = Rayfield:CreateWindow({
    Name = "🎣 Auto Fishing GET FISH",
    LoadingTitle = "Auto Fishing",
    LoadingSubtitle = "CAST → ReelFinished",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateToggle({
    Name = "Enable Auto Fishing",
    CurrentValue = false,
    Callback = function(v)
        AUTO_FISH = v
    end
})

local StatsLabel = Tab:CreateLabel("Idle")

--================ AUTO CAST + AUTO REEL =================
RunService.RenderStepped:Connect(function()
    if not AUTO_FISH then return end
    if isReeling then return end
    if not SESSION_ID then return end

    local now = tick()
    local interval = math.random(CAST_MIN*100, CAST_MAX*100)/100

    if now - lastCast >= interval then
        lastCast = now
        isReeling = true
        stats.casts += 1

        -- THROW (power + session)
        --local power = math.random(80,100)/100
        local power = 100
        ThrowRemote:FireServer(power, SESSION_ID)

        -- DELAY → FINISH REEL
        local reelDelay =
            math.random(REEL_DELAY_MIN*100, REEL_DELAY_MAX*100)/100
            + math.random(-20,20)/100

        task.delay(reelDelay, function()
            if not isReeling then return end

            ToServer.ReelFinished:FireServer({
                duration = math.random(4.5,5),
                result = "SUCCESS",
                insideRatio = math.random(80,85)/100
            }, SESSION_ID)
        end)
    end

    StatsLabel:Set(
        string.format(
            "Casts: %d | Catches: %d | Miss: %d",
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

--================ READY =================
Rayfield:Notify({
    Title = "Auto Fishing Ready",
    Content = "StartBite tidak digunakan",
    Duration = 3
})

print("✅ Auto Fishing Loaded")
